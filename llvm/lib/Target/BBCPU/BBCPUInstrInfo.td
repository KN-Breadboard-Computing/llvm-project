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

//===----------------------------------------------------------------------===//
// Operand and SDNode transformation definitions
//===----------------------------------------------------------------------===//

def MemOperandClass : AsmOperandClass {
    let Name = "Mem";
}

def imm8 : Operand<i8> {
    let EncoderMethod = "encodeImm<MCFixupKind::FK_Data_1, 1>";
}

def mem : Operand<i16> {
    let ParserMatchClass = MemOperandClass;
    let OperandType = "OPERAND_MEMORY";
    let MIOperandInfo = (ops i16imm);
    let EncoderMethod = "encodeImm<MCFixupKind::FK_Data_2, 1>";
}

//===----------------------------------------------------------------------===//
// Opcode and Instruction definitions
//===----------------------------------------------------------------------===//

// Following opcodes names and values match those defined in the manual
// (see `instruction-opcodes.json` in the `computer` repository)
class BBCPUOpcode<bits<8> val> {
    bits<8> Value = val;
}

def OPC_NOP : BBCPUOpcode<0b00000000>;
// OPC_MOVAB
// OPC_MOVBA
def OPC_MOVAIMM : BBCPUOpcode<0b00000011>; // 0x03
def OPC_MOVBIMM : BBCPUOpcode<0b00000100>; // 0x04
def OPC_MOVAABS : BBCPUOpcode<0b00000101>; // 0x05
// OPC_MOVBABS
// OPC_MOVABSA
// OPC_MOVABSB
// OPC_MOVABSIMM
// OPC_MOVAF
// OPC_MOVBF
// OPC_PUSHA
// OPC_PUSHB
// OPC_PUSHIMM
// OPC_POPA
// OPC_POPB
// OPC_POPABS
// OPC_JMPABS
def OPC_ADDA : BBCPUOpcode<0b00100000>; // 0x20
def OPC_ADDB : BBCPUOpcode<0b00100001>; // 0x21
// OPC_ADDABS
// OPC_SUBABA
// OPC_SUBABB
// OPC_SUBABAABS
// OPC_SUBBAA
// OPC_SUBBAB
// OPC_SUBBASABS
// OPC_ORA
// OPC_ORB
// OPC_ORABS
// OPC_ANDA
// OPC_ANDB
// OPC_ANDABS
// OPC_NEGAA
// OPC_NEGAB
// OPC_NEGAABS
// OPC_NEGBA
// OPC_NEGBB
// OPC_NEGBABS
// OPC_INVAA
// OPC_INVAB
// OPC_INVAABS
// OPC_INVBA
// OPC_INVBB
// OPC_INCBABS
// OPC_SHRAA
// OPC_SHRAB
// OPC_SHRAABS
// OPC_SHRBA
// OPC_SHRBB
// OPC_SHRBABS
// OPC_SHLAA
// OPC_SHLAB
// OPC_SHLAABS
// OPC_CMPAB
// OPC_CMPBA
def OPC_HALT : BBCPUOpcode<0b11111111>;

class BBCPUInstr<dag outs, dag ins, string opcodestr, string argstr, list<dag> pattern> : Instruction {
    let Namespace = "BBCPU";

    field bits<24> Inst;
    let Size = 1;

    bits<8> Opcode = 0;
    let Inst{7-0} = Opcode;

    dag OutOperandList = outs;
    dag InOperandList = ins;
    let AsmString = opcodestr # " " # argstr;
    let Pattern = pattern;
}

class BBCPUNoopInstr<BBCPUOpcode opcode, string opcodestr>
    : BBCPUInstr<(outs), (ins), opcodestr, "", []> {
  let Opcode = opcode.Value;
}

class BBCPURegImmInstr<BBCPUOpcode opcode, dag outs, dag ins, string opcodestr, string argstr>
    : BBCPUInstr<outs, ins, opcodestr, argstr, []> {
  bits<1> dst;
  bits<8> imm;

  let Size = 2;

  let Opcode = opcode.Value;
  let Inst{15-8} = imm;
}

class BBCPUTernaryRegInstr<BBCPUOpcode opcode, dag outs, dag ins, string opcodestr, string argstr>
    : BBCPUInstr<outs, ins, opcodestr, argstr, []> {
  bits<1> src0;
  bits<1> src1;
  bits<1> dst;

  let Opcode = opcode.Value;
}

class BBCPURegMemInstr<BBCPUOpcode opcode, dag outs, dag ins, string opcodestr, string argstr>
    : BBCPUInstr<outs, ins, opcodestr, argstr, []> {
  bits<1> dst;
  bits<16> imm;

  let Size = 3;

  let Opcode = opcode.Value;
  let Inst{23-8} = imm;
}

def NOP : BBCPUNoopInstr<OPC_NOP, "nop">;
def MOVAIMM : BBCPURegImmInstr<OPC_MOVAIMM, (outs RA:$dst), (ins imm8:$imm), "mov", "$dst, $imm">;
def MOVBIMM : BBCPURegImmInstr<OPC_MOVBIMM, (outs RB:$dst), (ins imm8:$imm), "mov", "$dst, $imm">;
def MOVAABS : BBCPURegMemInstr<OPC_MOVAABS, (outs RA:$dst), (ins mem:$imm), "mov", "$dst, $imm">;
def ADDA : BBCPUTernaryRegInstr<OPC_ADDA, (outs RA:$dst), (ins GPR:$src0, GPR:$src1), "add", "$dst, $src0, $src1">;
def ADDB : BBCPUTernaryRegInstr<OPC_ADDB, (outs RB:$dst), (ins GPR:$src0, GPR:$src1), "add", "$dst, $src0, $src1">;
def HALT : BBCPUNoopInstr<OPC_HALT, "halt">;
