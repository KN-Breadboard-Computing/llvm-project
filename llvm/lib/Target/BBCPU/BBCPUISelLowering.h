//===-- BBCPUISelLowering.h - BBCPU DAG lowering interface --------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that BBCPU uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BBCPU_BBCPUISELLOWERING_H
#define LLVM_LIB_TARGET_BBCPU_BBCPUISELLOWERING_H

#include "BBCPU.h"
#include "BBCPUInstrInfo.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/TargetLowering.h"

namespace llvm {

class BBCPUSubtarget;

namespace BBCPUISD {
enum NodeType : unsigned {
  FIRST_NUMBER = ISD::BUILTIN_OP_END,

  // Return with a glue operand. Operand 0 is the chain operand.
  RET_GLUE,

  // Calls a function.  Operand 0 is the chain operand and operand 1
  // is the target address.  The arguments start at operand 2.
  // There is an optional glue operand at the end.
  CALL,

  // Bit-field instructions.
  CLR,
  SET,
  EXT,
  EXTU,
  MAK,
  ROT,
  FF1,
  FF0,
};
} // end namespace BBCPUISD

class BBCPUTargetLowering : public TargetLowering {
  const BBCPUSubtarget &Subtarget;

public:
  explicit BBCPUTargetLowering(const TargetMachine &TM,
                              const BBCPUSubtarget &STI);

  // Override TargetLowering methods.
  bool hasAndNot(SDValue X) const override { return true; }
  const char *getTargetNodeName(unsigned Opcode) const override;

  SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

  SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const override;

  // Override required hooks.
  SDValue LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv,
                               bool IsVarArg,
                               const SmallVectorImpl<ISD::InputArg> &Ins,
                               const SDLoc &DL, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals) const override;

  SDValue LowerReturn(SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
                      const SmallVectorImpl<ISD::OutputArg> &Outs,
                      const SmallVectorImpl<SDValue> &OutVals, const SDLoc &DL,
                      SelectionDAG &DAG) const override;

  SDValue LowerCall(CallLoweringInfo &CLI,
                    SmallVectorImpl<SDValue> &InVals) const override;
};

} // end namespace llvm

#endif
