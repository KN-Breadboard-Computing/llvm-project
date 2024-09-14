//===-- BBCPUISelLowering.cpp - BBCPU DAG lowering
// implementation -----===//
//
// Part of the LLVM Project, under the Apache License
// v2.0 with LLVM Exceptions. See
// https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH
// LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the BBCPUTargetLowering class.
//
//===----------------------------------------------------------------------===//

#include "BBCPUISelLowering.h"
#include "BBCPUSubtarget.h"
#include "MCTargetDesc/BBCPUMCTargetDesc.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include <cstdint>

using namespace llvm;

#define DEBUG_TYPE "BBCPU-lower"

// If I is a shifted mask, set the size (Width) and the
// first bit of the mask (Offset), and return true. For
// example, if I is 0x003e, (Width, Offset) = (5, 1).
static bool isShiftedMask(uint64_t I, uint64_t &Width,
                          uint64_t &Offset) {
  if (!isShiftedMask_64(I))
    return false;

  Width = llvm::popcount(I);
  Offset = llvm::countr_zero(I);
  return true;
}

BBCPUTargetLowering::BBCPUTargetLowering(
    const TargetMachine &TM, const BBCPUSubtarget &STI)
    : TargetLowering(TM), Subtarget(STI) {
  addRegisterClass(MVT::i16, &BBCPU::GPR16RegClass);

  // Compute derived properties from the register
  // classes
  computeRegisterProperties(
      Subtarget.getRegisterInfo());

  // Set up special registers.
  setStackPointerRegisterToSaveRestore(BBCPU::R3);

  // How we extend i1 boolean values.
  setBooleanContents(ZeroOrOneBooleanContent);

  setMinFunctionAlignment(Align(2));

  setOperationAction(ISD::AND, MVT::i16, Legal);
  setOperationAction(ISD::OR, MVT::i16, Legal);
  setOperationAction(ISD::XOR, MVT::i16, Legal);

  setOperationAction(ISD::CTPOP, MVT::i16, Expand);

  // Special DAG combiner for bit-field operations.
  setTargetDAGCombine(ISD::AND);
  setTargetDAGCombine(ISD::OR);
  setTargetDAGCombine(ISD::SHL);
}

SDValue BBCPUTargetLowering::LowerOperation(
    SDValue Op, SelectionDAG &DAG) const {
  // TODO Implement for ops not covered by patterns in
  // .td files.
  /*
    switch (Op.getOpcode())
    {
    case ISD::SHL:          return lowerShiftLeft(Op,
    DAG);
    }
  */
  return SDValue();
}

namespace {
SDValue performANDCombine(
    SDNode *N, TargetLowering::DAGCombinerInfo &DCI) {
  SelectionDAG &DAG = DCI.DAG;
  SDValue FirstOperand = N->getOperand(0);
  unsigned FirstOperandOpc = FirstOperand.getOpcode();
  // Second operand of and must be a constant.
  ConstantSDNode *Mask =
      dyn_cast<ConstantSDNode>(N->getOperand(1));
  if (!Mask)
    return SDValue();
  EVT ValTy = N->getValueType(0);
  SDLoc DL(N);

  SDValue NewOperand;
  unsigned Opc;

  uint64_t Offset;
  uint64_t MaskWidth, MaskOffset;
  if (isShiftedMask(Mask->getZExtValue(), MaskWidth,
                    MaskOffset)) {
    if (FirstOperandOpc == ISD::SRL ||
        FirstOperandOpc == ISD::SRA) {
      // Pattern match:
      // $dst = and (srl/sra $src, offset), (2**width -
      // 1)
      // => EXTU $dst, $src, width<offset>

      // The second operand of the shift must be an
      // immediate.
      ConstantSDNode *ShiftAmt =
          dyn_cast<ConstantSDNode>(
              FirstOperand.getOperand(1));
      if (!(ShiftAmt))
        return SDValue();

      Offset = ShiftAmt->getZExtValue();

      // Return if the shifted mask does not start at
      // bit 0 or the sum of its width and offset
      // exceeds the word's size.
      if (MaskOffset != 0 ||
          Offset + MaskWidth > ValTy.getSizeInBits())
        return SDValue();

      Opc = BBCPUISD::EXTU;
      NewOperand = FirstOperand.getOperand(0);
    } else
      return SDValue();
  } else if (isShiftedMask(
                 ~Mask->getZExtValue() &
                     ((0x1ULL
                       << ValTy.getSizeInBits()) -
                      1),
                 MaskWidth, MaskOffset)) {
    // Pattern match:
    // $dst = and $src, ~((2**width - 1) << offset)
    // => CLR $dst, $src, width<offset>
    Opc = BBCPUISD::CLR;
    NewOperand = FirstOperand;
    Offset = MaskOffset;
  } else
    return SDValue();
  return DAG.getNode(
      Opc, DL, ValTy, NewOperand,
      DAG.getConstant(MaskWidth << 4 | Offset, DL,
                      MVT::i16));
}

SDValue
performORCombine(SDNode *N,
                 TargetLowering::DAGCombinerInfo &DCI) {
  SelectionDAG &DAG = DCI.DAG;
  uint64_t Width, Offset;

  // Second operand of or must be a constant shifted
  // mask.
  ConstantSDNode *Mask =
      dyn_cast<ConstantSDNode>(N->getOperand(1));
  if (!Mask || !isShiftedMask(Mask->getZExtValue(),
                              Width, Offset))
    return SDValue();

  // Pattern match:
  // $dst = or $src, ((2**width - 1) << offset
  // => SET $dst, $src, width<offset>
  EVT ValTy = N->getValueType(0);
  SDLoc DL(N);
  return DAG.getNode(
      BBCPUISD::SET, DL, ValTy, N->getOperand(0),
      DAG.getConstant(Width << 4 | Offset, DL,
                      MVT::i16));
}

SDValue performSHLCombine(
    SDNode *N, TargetLowering::DAGCombinerInfo &DCI) {
  // Pattern match:
  // $dst = shl (and $src, (2**width - 1)), offset
  // => MAK $dst, $src, width<offset>
  SelectionDAG &DAG = DCI.DAG;
  SDValue FirstOperand = N->getOperand(0);
  unsigned FirstOperandOpc = FirstOperand.getOpcode();
  // First operdns shl must be and, second operand must
  // a constant.
  ConstantSDNode *ShiftAmt =
      dyn_cast<ConstantSDNode>(N->getOperand(1));
  if (!ShiftAmt || FirstOperandOpc != ISD::AND)
    return SDValue();
  EVT ValTy = N->getValueType(0);
  SDLoc DL(N);

  uint64_t Offset;
  uint64_t MaskWidth, MaskOffset;
  ConstantSDNode *Mask = dyn_cast<ConstantSDNode>(
      FirstOperand->getOperand(1));
  if (!Mask || !isShiftedMask(Mask->getZExtValue(),
                              MaskWidth, MaskOffset))
    return SDValue();

  // The second operand of the shift must be an
  // immediate.
  Offset = ShiftAmt->getZExtValue();

  // Return if the shifted mask does not start at bit 0
  // or the sum of its width and offset exceeds the
  // word's size.
  if (MaskOffset != 0 ||
      Offset + MaskWidth > ValTy.getSizeInBits())
    return SDValue();

  return DAG.getNode(
      BBCPUISD::MAK, DL, ValTy,
      FirstOperand.getOperand(0),
      DAG.getConstant(MaskWidth << 4 | Offset, DL,
                      MVT::i16));
}
} // namespace

SDValue BBCPUTargetLowering::PerformDAGCombine(
    SDNode *N, DAGCombinerInfo &DCI) const {
  if (DCI.isBeforeLegalizeOps())
    return SDValue();
  LLVM_DEBUG(dbgs() << "In PerformDAGCombine\n");

  // TODO: Match certain and/or/shift ops to ext/mak.
  unsigned Opc = N->getOpcode();

  switch (Opc) {
  default:
    break;
  case ISD::AND:
    return performANDCombine(N, DCI);
  case ISD::OR:
    return performORCombine(N, DCI);
  case ISD::SHL:
    return performSHLCombine(N, DCI);
  }

  return SDValue();
}

//===----------------------------------------------------------------------===//
// Calling conventions
//===----------------------------------------------------------------------===//

#include "BBCPUGenCallingConv.inc"

SDValue BBCPUTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv,
    bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins,
    const SDLoc &DL, SelectionDAG &DAG,
    SmallVectorImpl<SDValue> &InVals) const {

    MachineFunction &MF = DAG.getMachineFunction();
    MachineRegisterInfo &MRI = MF.getRegInfo();

    // Assign locations to all of the incoming arguments.
    SmallVector<CCValAssign, 16> ArgLocs;
    CCState CCInfo(CallConv, IsVarArg, MF, ArgLocs,
                  *DAG.getContext());
    CCInfo.AnalyzeFormalArguments(Ins, CC_BBCPU16);

    for (unsigned I = 0, E = ArgLocs.size(); I != E;
        ++I) {
      SDValue ArgValue;
      CCValAssign &VA = ArgLocs[I];
      EVT LocVT = VA.getLocVT();
      if (VA.isRegLoc()) {
        // Arguments passed in registers
        const TargetRegisterClass *RC;
        switch (LocVT.getSimpleVT().SimpleTy) {
        default:
          // Integers smaller than i64 should be promoted
          // to i32.
          llvm_unreachable("Unexpected argument type");
        case MVT::i16:
          RC = &BBCPU::GPR16RegClass;
          break;
        }

        Register VReg = MRI.createVirtualRegister(RC);
        MRI.addLiveIn(VA.getLocReg(), VReg);
        ArgValue =
            DAG.getCopyFromReg(Chain, DL, VReg, LocVT);

        // If this is an 8/16-bit value, it is really
        // passed promoted to 32 bits. Insert an
        // assert[sz]ext to capture this, then truncate to
        // the right size.
        if (VA.getLocInfo() == CCValAssign::SExt)
          ArgValue = DAG.getNode(
              ISD::AssertSext, DL, LocVT, ArgValue,
              DAG.getValueType(VA.getValVT()));
        else if (VA.getLocInfo() == CCValAssign::ZExt)
          ArgValue = DAG.getNode(
              ISD::AssertZext, DL, LocVT, ArgValue,
              DAG.getValueType(VA.getValVT()));

        if (VA.getLocInfo() != CCValAssign::Full)
          ArgValue = DAG.getNode(ISD::TRUNCATE, DL,
                                VA.getValVT(), ArgValue);

        InVals.push_back(ArgValue);
      } 
      else if(VA.isMemLoc()) {
        llvm_unreachable(
            "BBCPU - LowerFormalArguments - "
            "Memory argument not implemented");
      }
      else {
        assert(VA.isMemLoc() &&
              "Argument not register or memory");
        llvm_unreachable(
            "BBCPU - LowerFormalArguments - "
            "Memory argument not implemented");
      }
  }


  return Chain;
}

SDValue BBCPUTargetLowering::LowerReturn(
    SDValue Chain, CallingConv::ID CallConv,
    bool IsVarArg,
    const SmallVectorImpl<ISD::OutputArg> &Outs,
    const SmallVectorImpl<SDValue> &OutVals,
    const SDLoc &DL, SelectionDAG &DAG) const {

  // Assign locations to each returned value.
  SmallVector<CCValAssign, 16> RetLocs;
  CCState RetCCInfo(CallConv, IsVarArg,
                    DAG.getMachineFunction(), RetLocs,
                    *DAG.getContext());
  RetCCInfo.AnalyzeReturn(Outs, RetCC_BBCPU16);

  SDValue Glue;
  SmallVector<SDValue, 4> RetOps(1, Chain);
  for (unsigned I = 0, E = RetLocs.size(); I != E;
       ++I) {
    CCValAssign &VA = RetLocs[I];

    // Make the return register live on exit.
    assert(VA.isRegLoc() &&
           "Can only return in registers!");

    // Chain and glue the copies together.
    Register Reg = VA.getLocReg();
    Chain = DAG.getCopyToReg(Chain, DL, Reg, OutVals[I],
                             Glue);
    Glue = Chain.getValue(1);
    RetOps.push_back(
        DAG.getRegister(Reg, VA.getLocVT()));
  }

  // Update chain and glue.
  RetOps[0] = Chain;
  if (Glue.getNode())
    RetOps.push_back(Glue);

  return DAG.getNode(BBCPUISD::RET_GLUE, DL, MVT::Other,
                     RetOps);
}

SDValue BBCPUTargetLowering::LowerCall(
    CallLoweringInfo &CLI,
    SmallVectorImpl<SDValue> &InVals) const {
  llvm_unreachable(
      "BBCPU - LowerCall - Not Implemented");
}

const char *BBCPUTargetLowering::getTargetNodeName(
    unsigned Opcode) const {
  switch (Opcode) {
#define OPCODE(Opc)                                    \
  case Opc:                                            \
    return #Opc
    OPCODE(BBCPUISD::RET_GLUE);
    OPCODE(BBCPUISD::CALL);
    OPCODE(BBCPUISD::CLR);
    OPCODE(BBCPUISD::SET);
    OPCODE(BBCPUISD::EXT);
    OPCODE(BBCPUISD::EXTU);
    OPCODE(BBCPUISD::MAK);
    OPCODE(BBCPUISD::ROT);
    OPCODE(BBCPUISD::FF1);
    OPCODE(BBCPUISD::FF0);
#undef OPCODE
  default:
    return nullptr;
  }
}
