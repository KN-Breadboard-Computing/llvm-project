//===-- BBCPUInstrInfo.td - BBCPU Instruction defs ---------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the BBCPU instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

include "BBCPUInstrFormat.td"

// ---------------------------------------------------------------------------//
// Selection DAG Nodes.
// ---------------------------------------------------------------------------//

// Selection DAG types.

// These are target-independent nodes, but have target-specific formats.
//  These are target-independent nodes, but have target-specific formats.
//def SDT_BBCPUCallSeqStart : SDCallSeqStart<[SDTCisVT<0, i16>,
//                                            SDTCisVT<1, i16>]>;
//def SDT_BBCPUCallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i16>,
//                                          SDTCisVT<1, i16>]>;
def SDT_BBCPUCall         : SDTypeProfile<0, -1, [SDTCisVT<0, i16>]>;
//def SDT_BBCPUSetFlag      : SDTypeProfile<0,  2, [SDTCisSameAs<0, 1>]>;
//def SDT_BBCPUSelectCC     : SDTypeProfile<1,  3, [SDTCisSameAs<0, 1>,
//                                                  SDTCisSameAs<1, 2>]>;
//def SDT_BBCPUSetCC        : SDTypeProfile<1,  1, [SDTCisVT<0, i32>,
//                                                  SDTCisVT<1, i32>]>;
//def SDT_BBCPUBrCC         : SDTypeProfile<0,  2, [SDTCisVT<0, OtherVT>,
//                                                  SDTCisVT<1, i32>]>;
//def SDT_BBCPUAdjDynAlloc  : SDTypeProfile<1,  1, [SDTCisVT<0, i32>,
//                                                  SDTCisVT<1, i32>]>;

def Call             : SDNode<"BBCPUISD::CALL", SDT_BBCPUCall,
                              [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                               SDNPVariadic]>;
def RetGlue          : SDNode<"BBCPUISD::RET_GLUE", SDTNone,
                              [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
//def CallSeqStart     : SDNode<"ISD::CALLSEQ_START", SDT_BBCPUCallSeqStart,
//                              [SDNPHasChain, SDNPOutGlue]>;
//def CallSeqEnd       : SDNode<"ISD::CALLSEQ_END", SDT_BBCPUCallSeqEnd,
//                              [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;
//def BBCPUSetFlag     : SDNode<"BBCPUISD::SET_FLAG", SDT_BBCPUSetFlag,
//                              [SDNPOutGlue]>;
//def BBCPUSubbF       : SDNode<"BBCPUISD::SUBBF", SDT_BBCPUSetFlag,
//                              [SDNPOutGlue, SDNPInGlue]>;
//def BBCPUBrCC        : SDNode<"BBCPUISD::BR_CC", SDT_BBCPUBrCC,
//                              [SDNPHasChain, SDNPInGlue]>;
//def BBCPUSelectCC    : SDNode<"BBCPUISD::SELECT_CC", SDT_BBCPUSelectCC,
//                              [SDNPInGlue]>;
//def BBCPUSetCC       : SDNode<"BBCPUISD::SETCC", SDT_BBCPUSetCC,
//                              [SDNPInGlue]>;
//def BBCPUHi          : SDNode<"BBCPUISD::HI", SDTIntUnaryOp>;
//def BBCPULo          : SDNode<"BBCPUISD::LO", SDTIntUnaryOp>;
//def BBCPUSmall       : SDNode<"BBCPUISD::SMALL", SDTIntUnaryOp>;
//def BBCPUAdjDynAlloc : SDNode<"BBCPUISD::ADJDYNALLOC", SDT_BBCPUAdjDynAlloc>;


// Branch targets
def BrTargetAsmOperand : AsmOperandClass {
  let Name = "BrTarget";
}
def BrTarget   : Operand<OtherVT> {
  let ParserMatchClass = BrTargetAsmOperand;
  let EncoderMethod = "getBranchTargetOpValue";
  let DecoderMethod = "decodeBranch";
}

def CallTargetAsmOperand : AsmOperandClass {
  let Name = "CallTarget";
}
def CallTarget : Operand<i16> {
  let ParserMatchClass = CallTargetAsmOperand;
  let EncoderMethod = "getBranchTargetOpValue";
  let DecoderMethod = "decodeBranch";
}


// ---------------------------------------------------------------------------//
// Logic and arithmetic instructions.
// ---------------------------------------------------------------------------//

multiclass BinaryLogic<bits<5> opcode, bits<1> comm, string opcodeStr, SDNode opcodeNode> {
    let isCommutable = comm in
        def binaryLogicInstruction : RRR_AluAllRegs16<opcode, opcodeStr, [(set GPR16Opnd:$dst, (opcodeNode GPR16LowOpnd:$src1, GPR16LowOpnd:$src2))]>;
}

multiclass UnaryInstruction<bits<5> opcode, bits<2> fun, string opcodeStr, SDNode opcodeNode> {
    def unaryInstruction : RRF_AluAllRegs16<opcode, fun, opcodeStr, [(set GPR16Opnd:$dst, (opcodeNode GPR16Opnd:$src))]>;
}

//def InversionPattern : Pat<(xor GPR:$src, (i16 0xFFFF), (not GPR:$src))>;
//def NegationPattern : Pat<(sub (i16 0), GPR:$src), (neg GPR:$src)>;

defm AND : BinaryLogic<0b00100, 1, "and", and>;
defm XOR : BinaryLogic<0b00101, 1, "xor", xor>;
defm OR  : BinaryLogic<0b00110, 1, "or", or>;
defm ADD : BinaryLogic<0b00111, 1, "add", add>;
defm SUB : BinaryLogic<0b01000, 0, "sub", sub>;

//defm NOT : UnaryInstruction<0b00111, 0b01, "not", not> {
//    let Patterns = [InversionPattern];
//}

//defm NEG : UnaryInstruction<0b00111, 0b10, "neg", neg> {
//    let Patterns = [NegationPattern];
//}

// -------------------------------------------------- //
// Load instructions
// -------------------------------------------------- //

multiclass LoadRRR<bits<5> opcode> {
    //def loadRRR : RRR_LoadAllRegs32<opcode, [(set GPR16Opnd:$dst, (load (add (shl GPR32Opnd:$addr.sub_hi_hi, 16), GPR32Opnd:$addr.sub_hi_lo)))]>;
    def loadRRR : RRR_LoadAllRegs32<opcode, [(set (i16 GPR16Opnd:$dst), (load GPR32Opnd:$addr))]>;
    
}

defm LOADRRR : LoadRRR<0b01001>;


// -------------------------------------------------- //
// Store instructions
// -------------------------------------------------- //

multiclass StoreRRR<bits<5> opcode> {
    //def storeRRR : RRR_StoreAllRegs32<opcode, [(store (add (shl GPR32Opnd:$addr, 16), GPR32Opnd:$addr), GPR16Opnd:$dst)]>; 
    def storeRRR : RRR_StoreAllRegs32<opcode, [(store (i16 GPR16Opnd:$dst), GPR32Opnd:$addr)]>; 
}

defm STORERRR : StoreRRR<0b01010>;


// -------------------------------------------------- //
// BRANCH instructions
// -------------------------------------------------- //

let isBranch = 1, isBarrier = 1, isTerminator = 1, hasDelaySlot = 1 in {
  let isIndirectBranch = 1 in {
    def JR : RRF_JumpRegs16<0b01011, 0b00, "bt\t$addr", [(brind GPR32Opnd:$addr)]>;
  }
}



// ---------------------------------------------------------------------------//
// Call, Ret instruction.
// ---------------------------------------------------------------------------//

let isCall = 1, hasDelaySlot = 1, isCodeGenOnly = 1, Defs = [RCA] in {
    def CALL : Pseudo<(outs), (ins CallTarget:$addr), "", []>;
    //def CALLR : Pseudo<(outs), (ins GPR32Opnd:$src), "", [(Call GPR32Opnd:$src)]>;
}

let isReturn = 1, isTerminator = 1, hasDelaySlot = 1, isBarrier = 1, Uses = [RCA] in {
    def RET : Pseudo<(outs), (ins), "ld\t-4[%fp], %pc ! return", [(RetGlue)]> { let PostEncoderMethod = ""; }
}


def : Pat<(Call tglobaladdr:$dst), (CALL tglobaladdr:$dst)>;
def : Pat<(Call texternalsym:$dst), (CALL texternalsym:$dst)>;
