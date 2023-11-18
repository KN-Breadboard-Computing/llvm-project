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
// (see https://kn-breadboard-computing.github.io/processor-instructions.html)
class BBCPUOpcode<bits<8> val> {
    bits<8> Value = val;
}

def OPC_NOP : BBCPUOpcode<0b00000000>;
def OPC_MOVAB : BBCPUOpcode<0b00000001>;
def OPC_MOVBA : BBCPUOpcode<0b00000010>;
def OPC_MOVAF : BBCPUOpcode<0b00000011>;
def OPC_MOVBF : BBCPUOpcode<0b00000100>;
def OPC_MOVATH : BBCPUOpcode<0b00000101>;
def OPC_MOVBTH : BBCPUOpcode<0b00000110>;
def OPC_MOVATL : BBCPUOpcode<0b00000111>;
def OPC_MOVBTL : BBCPUOpcode<0b00001000>;
def OPC_MOVTHA : BBCPUOpcode<0b00001001>;
def OPC_MOVTHB : BBCPUOpcode<0b00001010>;
def OPC_MOVTLA : BBCPUOpcode<0b00001011>;
def OPC_MOVTLB : BBCPUOpcode<0b00001100>;
def OPC_MOVAIMM : BBCPUOpcode<0b00001101>; // 0x03
def OPC_MOVBIMM : BBCPUOpcode<0b00001110>; // 0x04
def OPC_MOVAABS : BBCPUOpcode<0b00001111>; // 0x05
def OPC_MOVBABS : BBCPUOpcode<0b00010000>;
def OPC_MOVABSA : BBCPUOpcode<0b00010001>;
def OPC_MOVABSB : BBCPUOpcode<0b00010010>;
def OPC_MOVABSIMM : BBCPUOpcode<0b00010011>;
// OPC_NEGAA
// OPC_NEGAB
// OPC_NEGAMEM
// OPC_NEGBA
// OPC_NEGBB
// OPC_NEGBMEM
def OPC_ADDA : BBCPUOpcode<0b00010111>; // 0x17
def OPC_ADDB : BBCPUOpcode<0b00011000>; // 0x18
// OPC_ADDMEM
// OPC_SUBABA
// OPC_SUBABB
// OPC_SUBABMEM
// OPC_SUBBAA
// OPC_SUBBAB
// OPC_SUBBAMEM
// OPC_MULA2MEM
// OPC_MULB2A
// OPC_MULB2B
// OPC_MULB2MEM
// OPC_DIVA2A
// OPC_DIVA2B
// OPC_DIVA2MEM
// OPC_DIVB2A
// OPC_DIVB2B
// OPC_INVAA
// OPC_INVAB
// OPC_INVAMEM
// OPC_INVBA
// OPC_INVBB
// OPC_INVBMEM
// OPC_ORA
// OPC_ORB
// OPC_ORMEM
// OPC_ANDA
// OPC_ANDB
// OPC_ANDMEM
// OPC_XORA
// OPC_XORB
// OPC_XORMEM
// OPC_SHRAA
// OPC_SHRAB
// OPC_SHRAMEM
// OPC_SHRBA
// OPC_SHRBB
// OPC_SHRBMEM
// OPC_SHLAA
// OPC_SHLAB
// OPC_SHLAMEM
// OPC_SHLBA
// OPC_SHLBB
// OPC_SHLBMEM
// OPC_CMPAB
// OPC_CMPBA
// OPC_CMPTHTL
// OPC_CMPTTLTH
// OPC_CMPATH
// OPC_CMPTHA
// OPC_CMPATL
// OPC_CMPTLA
// OPC_CMPBTH
// OPC_CMPTHB
// OPC_CMPBTL
// OPC_CMPTLB
// OPC_JMPIMM
// OPC_JMPS
// OPC_JMPNS
// OPC_JMPP
// OPC_JMPNP
// OPC_JMPZ
// OPC_JMPZ
// OPC_JMPNZ
// OPC_JMPC
// OPC_JMPNC
// OPC_JMPO
// OPC_JMPNO
// OPC_JMPFUN
// OPC_JMPRET
// OPC_PUSHA
// OPC_PUSHB
// OPC_PUSHTH
// OPC_PUSHTL
// OPC_PUSHIMM
// OPC_PUSHABS
// OPC_POPA
// OPC_POPB
// OPC_POPTH
// OPC_POPTL
// OPC_POPMEM
// OPC_SKIP
def OPC_HALT : BBCPUOpcode<0b11111111>;

class BBCPUInstr<dag outs, dag ins, string opcodestr, string argstr, list<dag> pattern> : Instruction {
    let Namespace = "BBCPU";

    field bits<32> Inst;
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

class BBCPUTernaryRegInstr<BBCPUOpcode opcode, dag outs, dag ins, string opcodestr, string argstr>
    : BBCPUInstr<outs, ins, opcodestr, argstr, []> {
  bits<1> src0;
  bits<1> src1;
  bits<1> dst;

  let Opcode = opcode.Value;
}

class BBCPUBinaryRegInstr<BBCPUOpcode opcode, Register dst, Register src, string opcodestr, string argstr>
    : BBCPUInstr<(outs), (ins), opcodestr, argstr, []> {
  let Defs = [dst];
  let Uses = [src];

  let Opcode = opcode.Value;
}

class BBCPURegImmInstr<BBCPUOpcode opcode, Register dst, string opcodestr, string argstr>
    : BBCPUInstr<(outs), (ins imm8:$imm), opcodestr, argstr, []> {
  let Defs = [dst];

  bits<8> imm;

  let Size = 2;

  let Opcode = opcode.Value;
  let Inst{15-8} = imm;
}

class BBCPURegMemInstr<BBCPUOpcode opcode, Register dst, string opcodestr, string argstr>
    : BBCPUInstr<(outs), (ins mem:$imm), opcodestr, argstr, []> {
  let Defs = [dst];
  let Uses = [T]

  bits<16> imm;

  let Size = 3;

  let Opcode = opcode.Value;
  let Inst{23-8} = imm;
}

class BBCPUMemRegInstr<BBCPUOpcode opcode, Register src, string opcodestr, string argstr>
    : BBCPUInstr<(outs mem:$imm), (ins), opcodestr, argstr, []> {
  let Uses = [src, T];

  bits<16> imm;

  let Size = 3;

  let Opcode = opcode.Value;
  let Inst{23-8} = imm;
}

def NOP : BBCPUNoopInstr<OPC_NOP, "nop">;
def MOVAB : BBCPUBinaryRegInstr<OPC_MOVAB, A, B, "mov", "a, b">;
def MOVBA : BBCPUBinaryRegInstr<OPC_MOVBA, B, A, "mov", "b, a">;
def MOVAF : BBCPUBinaryRegInstr<OPC_MOVAF, A, F, "mov", "a, f">;
def MOVBF : BBCPUBinaryRegInstr<OPC_MOVBF, B, F, "mov", "b, f">;
def MOVATH : BBCPUBinaryRegInstr<OPC_MOVATH, A, TH, "mov", "a, th">;
def MOVBTH : BBCPUBinaryRegInstr<OPC_MOVBTH, B, TH, "mov", "b, th">;
def MOVATL : BBCPUBinaryRegInstr<OPC_MOVATL, A, TL, "mov", "a, tl">;
def MOVBTL : BBCPUBinaryRegInstr<OPC_MOVBTL, B, TL, "mov", "b, tl">;
def MOVTHA : BBCPUBinaryRegInstr<OPC_MOVTHA, TH, A, "mov", "th, a">;
def MOVTHB : BBCPUBinaryRegInstr<OPC_MOVTHB, TH, B, "mov", "th, b">;
def MOVTLA : BBCPUBinaryRegInstr<OPC_MOVTLA, TL, A, "mov", "tl, a">;
def MOVTLB : BBCPUBinaryRegInstr<OPC_MOVTLB, TL, B, "mov", "tl, b">;
def MOVAIMM : BBCPURegImmInstr<OPC_MOVAIMM, A, "mov", "a, $imm">;
def MOVBIMM : BBCPURegImmInstr<OPC_MOVBIMM, B, "mov", "b, $imm">;
def MOVAABS : BBCPURegMemInstr<OPC_MOVAABS, A, "mov", "a, $imm">;
def MOVBABS : BBCPURegMemInstr<OPC_MOVBABS, B, "mov", "b, $imm">;
def MOVABSA : BBCPUMemRegInstr<OPC_MOVABSA, A, "mov", "$imm, a">;
def MOVABSB : BBCPUMemRegInstr<OPC_MOVABSB, B, "mov", "$imm, b">;
def MOVABSIMM : BBCPUInstr<(outs mem:$dst), (ins imm8:$src), "mov", "$dst, $src", []> {
  bits<8> src;
  bits<16> dst;

  let Size = 4;
  let Opcode = OPC_MOVABSIMM.Value;
  let Uses = [T];

  let Inst{23-8} = dst;
  let Inst{31-24} = src;
}

def ADDA : BBCPUTernaryRegInstr<OPC_ADDA, (outs RA:$dst), (ins GPR:$src0, GPR:$src1), "add", "$dst, $src0, $src1">;
def ADDB : BBCPUTernaryRegInstr<OPC_ADDB, (outs RB:$dst), (ins GPR:$src0, GPR:$src1), "add", "$dst, $src0, $src1">;
def HALT : BBCPUNoopInstr<OPC_HALT, "halt">;
