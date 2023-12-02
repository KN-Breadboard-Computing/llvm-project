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
// (see https://kn-breadboard-computing.github.io/proc-instr/)
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
def OPC_MOVAIMM : BBCPUOpcode<0b00001101>;
def OPC_MOVBIMM : BBCPUOpcode<0b00001110>;
def OPC_MOVTHIMM : BBCPUOpcode<0b00001111>;
def OPC_MOVTLIMM : BBCPUOpcode<0b00010000>;
def OPC_MOVAABS : BBCPUOpcode<0b00010001>;
def OPC_MOVAABSZP : BBCPUOpcode<0b0010010>;
def OPC_MOVBABS : BBCPUOpcode<0b00010011>;
def OPC_MOVBABSZP : BBCPUOpcode<0b00010100>;
def OPC_MOVABSA : BBCPUOpcode<0b00010101>;
def OPC_MOVABSAZP : BBCPUOpcode<0b00010110>;
def OPC_MOVABSB : BBCPUOpcode<0b00010111>;
def OPC_MOVABSBZP : BBCPUOpcode<0b00011000>;
def OPC_MOVABSIMM : BBCPUOpcode<0b00011001>;
def OPC_MOVABSIMMZP : BBCPUOpcode<0b00011010>;
def OPC_MOVATTMPA : BBCPUOpcode<0b00011011>;
def OPC_MOVATTMPB : BBCPUOpcode<0b00011100>;
def OPC_MOVATAB : BBCPUOpcode<0b00011101>;
def OPC_MOVATBA : BBCPUOpcode<0b00011110>;
def OPC_MOVATTHA : BBCPUOpcode<0b00011111>;
def OPC_MOVATTHB : BBCPUOpcode<0b00100000>;
def OPC_MOVATTLA : BBCPUOpcode<0b00100001>;
def OPC_MOVATTLB : BBCPUOpcode<0b00100010>;
def OPC_MOVATTLTH : BBCPUOpcode<0b00100011>;
def OPC_MOVATTHTL : BBCPUOpcode<0b00100100>;
def OPC_MOVATTMPIMM : BBCPUOpcode<0b00100101>;
def OPC_MOVATTMPHIMM : BBCPUOpcode<0b00100110>;
def OPC_MOVATTMPLIMM : BBCPUOpcode<0b00100111>;
def OPC_MOVATAIMM : BBCPUOpcode<0b00101000>;
def OPC_MOVATBIMM : BBCPUOpcode<0b00101001>;
def OPC_NEGAA : BBCPUOpcode<0b00101010>;
def OPC_NEGAB : BBCPUOpcode<0b00101011>;
def OPC_NEGAMEM : BBCPUOpcode<0b00101100>;
def OPC_NEGAMEMZP : BBCPUOpcode<0b00101101>;
def OPC_NEGASTC : BBCPUOpcode<0b00101110>;
def OPC_NEGBA : BBCPUOpcode<0b00101111>;
def OPC_NEGBB : BBCPUOpcode<0b00110000>;
def OPC_NEGBMEM : BBCPUOpcode<0b00110001>;
def OPC_NEGBMEMZP : BBCPUOpcode<0b00110010>;
def OPC_NEGBSTC : BBCPUOpcode<0b0011011>;
def OPC_ADDA : BBCPUOpcode<0b00110100>;
def OPC_ADDB : BBCPUOpcode<0b00110101>;
def OPC_ADDMEM : BBCPUOpcode<0b00110110>;
def OPC_ADDMEMZP : BBCPUOpcode<0b00110111>;
def OPC_ADDSTC : BBCPUOpcode<0b00111000>;
def OPC_SUBABA : BBCPUOpcode<0b00111001>;
def OPC_SUBABB : BBCPUOpcode<0b00111010>;
def OPC_SUBABMEM : BBCPUOpcode<0b00111011>;
def OPC_SUBABMEMZP : BBCPUOpcode<0b00111100>;
def OPC_SUBABSTC : BBCPUOpcode<0b00111101>;
def OPC_SUBBAA : BBCPUOpcode<0b00111110>;
def OPC_SUBBAB : BBCPUOpcode<0b00111111>;
def OPC_SUBBAMEM : BBCPUOpcode<0b01000000>;
def OPC_SUBBAMEMZP : BBCPUOpcode<0b01000001>;
def OPC_SUBBASTC : BBCPUOpcode<0b01000010>;
def OPC_MULA2A : BBCPUOpcode<0b01000011>;
def OPC_MULA2B : BBCPUOpcode<0b01000100>;
def OPC_MULA2MEM : BBCPUOpcode<0b01000101>;
def OPC_MULA2MEMZP : BBCPUOpcode<0b01000110>;
def OPC_MULA2STC : BBCPUOpcode<0b01000111>;
def OPC_MULB2A : BBCPUOpcode<0b01001000>;
def OPC_MULB2B : BBCPUOpcode<0b01001001>;
def OPC_MULB2MEM : BBCPUOpcode<0b01001010>;
def OPC_MULB2MEMZP : BBCPUOpcode<0b01001011>;
def OPC_MULB2STC : BBCPUOpcode<0b01001100>;
def OPC_DIVA2A : BBCPUOpcode<0b01001101>;
def OPC_DIVA2B : BBCPUOpcode<0b01001110>;
def OPC_DIVA2MEM : BBCPUOpcode<0b01001111>;
def OPC_DIVA2MEMZP : BBCPUOpcode<0b01010000>;
def OPC_DIVA2STC : BBCPUOpcode<0b01010001>;
def OPC_DIVB2A : BBCPUOpcode<0b01010010>;
def OPC_DIVB2B : BBCPUOpcode<0b01010011>;
def OPC_DIVB2MEM : BBCPUOpcode<0b01010100>;
def OPC_DIVB2MEMZP : BBCPUOpcode<0b01010101>;
def OPC_DIVB2STC : BBCPUOpcode<0b01010110>;
def OPC_INVAA : BBCPUOpcode<0b01010111>;
def OPC_INVAB : BBCPUOpcode<0b01011000>;
def OPC_INVAMEM : BBCPUOpcode<0b01011001>;
def OPC_INVAMEMZP : BBCPUOpcode<0b01011010>;
def OPC_INVASTC : BBCPUOpcode<0b01011011>;
def OPC_INVBA : BBCPUOpcode<0b01011100>;
def OPC_INVBB : BBCPUOpcode<0b01011101>;
def OPC_INVBMEM : BBCPUOpcode<0b01011110>;
def OPC_INVBMEMZP : BBCPUOpcode<0b01011111>;
def OPC_INVBSTC : BBCPUOpcode<0b01100000>;
def OPC_ORA : BBCPUOpcode<0b01100001>;
def OPC_ORB : BBCPUOpcode<0b01100010>;
def OPC_ORMEM : BBCPUOpcode<0b01100011>;
def OPC_ORMEMZP : BBCPUOpcode<0b01100100>;
def OPC_ORSTC : BBCPUOpcode<0b01100101>;
def OPC_ANDA : BBCPUOpcode<0b01100110>;
def OPC_ANDB : BBCPUOpcode<0b01100111>;
def OPC_ANDMEM : BBCPUOpcode<0b01101000>;
def OPC_ANDMEMZP : BBCPUOpcode<0b01101001>;
def OPC_ANDSTC : BBCPUOpcode<0b01101010>;
def OPC_XORA : BBCPUOpcode<0b01101011>;
def OPC_XORB : BBCPUOpcode<0b01101100>;
def OPC_XORMEM : BBCPUOpcode<0b01101101>;
def OPC_XORMEMZP : BBCPUOpcode<0b01101110>;
def OPC_XORMEMSTC : BBCPUOpcode<0b01101111>;
def OPC_SHRAA : BBCPUOpcode<0b01110000>;
def OPC_SHRAB : BBCPUOpcode<0b01110001>;
def OPC_SHRAMEM : BBCPUOpcode<0b01110010>;
def OPC_SHRAMEMZP : BBCPUOpcode<0b01110011>;
def OPC_SHRASTC : BBCPUOpcode<0b011101000>;
def OPC_SHRBA : BBCPUOpcode<0b01110101>;
def OPC_SHRBB : BBCPUOpcode<0b01110110>;
def OPC_SHRBMEM : BBCPUOpcode<0b01110111>;
def OPC_SHRMEMZP : BBCPUOpcode<0b01111000>;
def OPC_SHRBSTC : BBCPUOpcode<0b01111001>;
def OPC_SHLAA : BBCPUOpcode<0b01111010>;
def OPC_SHLAB : BBCPUOpcode<0b01111011>;
def OPC_SHLAMEM : BBCPUOpcode<0b01111100>;
def OPC_SHLAMEMZP : BBCPUOpcode<0b01111101>;
def OPC_SHLASTC : BBCPUOpcode<0b01111110>;
def OPC_SHLBA : BBCPUOpcode<0b01111111>;
def OPC_SHLBB : BBCPUOpcode<0b10000000>;
def OPC_SHLBMEM : BBCPUOpcode<0b10000001>;
def OPC_SHLBMEMZP : BBCPUOpcode<0b1000010>;
def OPC_SHLBSTC : BBCPUOpcode<0b10000011>;
def OPC_INCA : BBCPUOpcode<0b10001111>;
def OPC_INCB : BBCPUOpcode<0b10010000>;
def OPC_INCTMP : BBCPUOpcode<0b10010010>;
def OPC_INCTH : BBCPUOpcode<0b10010010>;
def OPC_INCTL : BBCPUOpcode<0b10010011>;
def OPC_DECA : BBCPUOpcode<0b10010100>;
def OPC_DECB : BBCPUOpcode<0b10010101>;
def OPC_DECTMP : BBCPUOpcode<0b10010110>;
def OPC_DECTH : BBCPUOpcode<0b10010111>;
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

class BBCPUBinaryRegInstr<BBCPUOpcode opcode, Register dst, Register src, string opcodestr, string argstr>
    : BBCPUInstr<(outs), (ins), opcodestr, argstr, []> {
  let Defs = [dst];
  let Uses = [src];

  let Opcode = opcode.Value;
}

class BBCPUTernaryRegInstr<BBCPUOpcode opcode, Register dst, Register src1, Register src2,
  string opcodestr, string argstr> : BBCPUInstr<(outs), (ins), opcodestr, argstr, []> {
  let Defs = [dst];
  let Uses = [src1, src2];

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
  let Uses = [T];

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

class BBCPUMemBinaryRegInstr<BBCPUOpcode opcode, Register src1, Register src2, string opcodestr, string argstr>
    : BBCPUInstr<(outs mem:$imm), (ins), opcodestr, argstr, []> {
  let Uses = [src1, src2, T];

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

def NEGAA : BBCPUBinaryRegInstr<OPC_NEGAA, A, A, "neg", "a, a">;
def NEGAB : BBCPUBinaryRegInstr<OPC_NEGAB, B, A, "neg", "b, a">;
def NEGAMEM : BBCPUMemRegInstr<OPC_NEGAMEM, A, "neg", "$imm, a">;
def NEGBA : BBCPUBinaryRegInstr<OPC_NEGBA, A, B, "neg", "a, b">;
def NEGBB : BBCPUBinaryRegInstr<OPC_NEGBB, B, B, "neg", "b, b">;
def NEGBMEM : BBCPUMemRegInstr<OPC_NEGBMEM, B, "neg", "$imm, b">;
// TODO: Maybe operands here should be swappable with each other for ADDA, ADDB
def ADDA : BBCPUTernaryRegInstr<OPC_ADDA, A, A, B, "add", "a, a, b">;
def ADDB : BBCPUTernaryRegInstr<OPC_ADDB, B, A, B, "add", "b, a, b">;
def ADDMEM : BBCPUMemBinaryRegInstr<OPC_ADDMEM, A, B, "add", "$imm, a, b">;
def SUBABA : BBCPUTernaryRegInstr<OPC_SUBABA, A, A, B, "sub", "a, a, b">;
def SUBABB : BBCPUTernaryRegInstr<OPC_SUBABB, B, A, B, "sub", "b, a, b">;
def SUBABMEM : BBCPUMemBinaryRegInstr<OPC_SUBABMEM, A, B, "sub", "$imm, a, b">;
def SUBBAA : BBCPUTernaryRegInstr<OPC_SUBBAA, A, B, A, "sub", "a, b, a">;
def SUBBAB : BBCPUTernaryRegInstr<OPC_SUBBAB, B, B, A, "sub", "b, b, a">;
def SUBBAMEM : BBCPUMemBinaryRegInstr<OPC_SUBBAMEM, B, A, "sub", "$imm, b, a">;
def MULA2A : BBCPUBinaryRegInstr<OPC_MULA2A, A, A, "mul2", "a, a">;
def MULA2B : BBCPUBinaryRegInstr<OPC_MULA2B, B, A, "mul2", "b, a">;
def MULA2MEM : BBCPUMemRegInstr<OPC_MULA2MEM, A, "mul2", "$imm, a">;
def MULB2A : BBCPUBinaryRegInstr<OPC_MULB2A, A, B, "mul2", "a, b">;
def MULB2B : BBCPUBinaryRegInstr<OPC_MULB2B, B, B, "mul2", "b, b">;
def MULB2MEM : BBCPUMemRegInstr<OPC_MULB2MEM, B, "mul2", "$imm, b">;
def DIVA2A : BBCPUBinaryRegInstr<OPC_DIVA2A, A, A, "div2", "a, a">;
def DIVA2B : BBCPUBinaryRegInstr<OPC_DIVA2B, B, A, "div2", "b, a">;
def DIVA2MEM : BBCPUMemRegInstr<OPC_DIVA2MEM, A, "div2", "$imm, a">;
def DIVB2A : BBCPUBinaryRegInstr<OPC_DIVB2A, A, B, "div2", "a, b">;
def DIVB2B : BBCPUBinaryRegInstr<OPC_DIVB2B, B, B, "div2", "b, b">;
def DIVB2MEM : BBCPUMemRegInstr<OPC_DIVB2MEM, B, "div2", "$imm, b">;
def INVAA : BBCPUBinaryRegInstr<OPC_INVAA, A, A, "inv", "a, a">;
def INVAB : BBCPUBinaryRegInstr<OPC_INVAB, B, A, "inv", "b, a">;
def INVAMEM : BBCPUMemRegInstr<OPC_INVAMEM, A, "inv", "$imm, a">;
def INVBA : BBCPUBinaryRegInstr<OPC_INVBA, A, B, "inv", "a, b">;
def INVBB : BBCPUBinaryRegInstr<OPC_INVBB, B, B, "inv", "b, b">;
def INVBMEM : BBCPUMemRegInstr<OPC_INVBMEM, B, "inv", "$imm, b">;
// TODO: Maybe operands here should be swappable with each other for Boolean operations
def ORA : BBCPUTernaryRegInstr<OPC_ORA, A, A, B, "or", "a, a, b">;
def ORB : BBCPUTernaryRegInstr<OPC_ORB, B, A, B, "or", "b, a, b">;
def ORMEM : BBCPUMemBinaryRegInstr<OPC_ORMEM, A, B, "or", "$imm, a, b">;
def ANDA : BBCPUTernaryRegInstr<OPC_ANDA, A, A, B, "and", "a, a, b">;
def ANDB : BBCPUTernaryRegInstr<OPC_ANDB, B, A, B, "and", "b, a, b">;
def ANDMEM : BBCPUMemBinaryRegInstr<OPC_ANDMEM, A, B, "and", "$imm, a, b">;
def XORA : BBCPUTernaryRegInstr<OPC_XORA, A, A, B, "xor", "a, a, b">;
def XORB : BBCPUTernaryRegInstr<OPC_XORB, B, A, B, "xor", "b, a, b">;
def XORMEM : BBCPUMemBinaryRegInstr<OPC_XORMEM, A, B, "xor", "$imm, a, b">;
def SHRAA : BBCPUBinaryRegInstr<OPC_SHRAA, A, A, "shr", "a, a">;
def SHRAB : BBCPUBinaryRegInstr<OPC_SHRAB, B, A, "shr", "b, a">;
def SHRAMEM : BBCPUMemRegInstr<OPC_SHRAMEM, A, "shr", "$imm, a">;
def SHRBA : BBCPUBinaryRegInstr<OPC_SHRBA, A, B, "shr", "a, b">;
def SHRBB : BBCPUBinaryRegInstr<OPC_SHRBB, B, B, "shr", "b, b">;
def SHRBMEM : BBCPUMemRegInstr<OPC_SHRBMEM, B, "shr", "$imm, b">;
def SHLAA : BBCPUBinaryRegInstr<OPC_SHLAA, A, A, "shl", "a, a">;
def SHLAB : BBCPUBinaryRegInstr<OPC_SHLAB, B, A, "shl", "b, a">;
def SHLAMEM : BBCPUMemRegInstr<OPC_SHLAMEM, A, "shl", "$imm, a">;
def SHLBA : BBCPUBinaryRegInstr<OPC_SHLBA, A, B, "shl", "a, b">;
def SHLBB : BBCPUBinaryRegInstr<OPC_SHLBB, B, B, "shl", "b, b">;
def SHLBMEM : BBCPUMemRegInstr<OPC_SHLBMEM, B, "shl", "$imm, b">;



def HALT : BBCPUNoopInstr<OPC_HALT, "halt">;
