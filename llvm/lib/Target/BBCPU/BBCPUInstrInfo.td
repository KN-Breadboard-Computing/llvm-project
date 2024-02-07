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

def MemZeroPageOperandClass : AsmOperandClass {
  let Name = "MemZeroPage";
}

def IndexedRegOperandClass : AsmOperandClass {
  let Name = "IndexedReg";
}

def StackOperandClass : AsmOperandClass {
  let Name = "Stack";
}

def imm8 : Operand<i8> {
    let EncoderMethod = "encodeImm<MCFixupKind::FK_Data_1, 1>";
}

def imm16 : Operand<i16> {
    let EncoderMethod = "encodeImm<MCFixupKind::FK_Data_2, 1>";
}

def mem : Operand<i16> {
    let ParserMatchClass = MemOperandClass;
    let OperandType = "OPERAND_MEMORY";
    let MIOperandInfo = (ops i16imm);
    let EncoderMethod = "encodeImm<MCFixupKind::FK_Data_2, 1>";
}

def memzp : Operand<i8> {
    let ParserMatchClass = MemZeroPageOperandClass;
    let OperandType = "OPERAND_MEMORY";
    let MIOperandInfo = (ops i8imm);
    let EncoderMethod = "encodeImm<MCFixupKind::FK_Data_1, 1>";
}

def relimm8 : Operand<i8> {
    let EncoderMethod = "encodeImm<MCFixupKind::FK_PCRel_1, 1>";
}

class IndexedReg<Register reg> : Operand<OtherVT> {
  field Register Reg = reg;

  let OperandType = "OPERAND_REGISTER";
  let ParserMatchClass = IndexedRegOperandClass;
}

def stc : Operand<i8> {
  let ParserMatchClass = StackOperandClass;
  let OperandType = "OPERAND_MEMORY";
  let MIOperandInfo = (ops i8imm);
}

//===----------------------------------------------------------------------===//
// Opcode and Instruction definitions
//===----------------------------------------------------------------------===//

// Following opcodes names and values match those defined in the manual
// (see https://kn-breadboard-computing.github.io/proc-instr/)
class BBCPUOpcode<bits<8> val> {
    bits<8> Value = val;
}

def OPC_MOVAB : BBCPUOpcode<0b00000001>;
def OPC_MOVATH : BBCPUOpcode<0b00000010>;
def OPC_MOVATL : BBCPUOpcode<0b00000011>;
def OPC_MOVAF : BBCPUOpcode<0b00000100>;
def OPC_MOVBA : BBCPUOpcode<0b00000101>;
def OPC_MOVBTH : BBCPUOpcode<0b00000110>;
def OPC_MOVBTL : BBCPUOpcode<0b00000111>;
def OPC_MOVBF : BBCPUOpcode<0b00001000>;
def OPC_MOVTHA : BBCPUOpcode<0b00001001>;
def OPC_MOVTHB : BBCPUOpcode<0b00001010>;
def OPC_MOVTHTL : BBCPUOpcode<0b00001011>;
def OPC_MOVTHF : BBCPUOpcode<0b00001100>;
def OPC_MOVTLA : BBCPUOpcode<0b00001101>;
def OPC_MOVTLB : BBCPUOpcode<0b00001110>;
def OPC_MOVTLTH : BBCPUOpcode<0b00001111>;
def OPC_MOVTLF : BBCPUOpcode<0b00010000>;
def OPC_MOVAIMM : BBCPUOpcode<0b00010001>;
def OPC_MOVBIMM : BBCPUOpcode<0b00010010>;
def OPC_MOVTHIMM : BBCPUOpcode<0b00010011>;
def OPC_MOVTLIMM : BBCPUOpcode<0b00010100>;
def OPC_MOVAABS : BBCPUOpcode<0b00010101>;
def OPC_MOVAABSZP : BBCPUOpcode<0b00010110>;
def OPC_MOVBABS : BBCPUOpcode<0b00010111>;
def OPC_MOVBABSZP : BBCPUOpcode<0b00011000>;
def OPC_MOVATABSA : BBCPUOpcode<0b00011001>;
def OPC_MOVATABSAZP : BBCPUOpcode<0b00011010>;
def OPC_MOVATABSB : BBCPUOpcode<0b00011011>;
def OPC_MOVATABSBZP : BBCPUOpcode<0b00011100>;
def OPC_MOVATABSIMM : BBCPUOpcode<0b00011101>;
def OPC_MOVATABSIMMZP : BBCPUOpcode<0b00011110>;
def OPC_MOVATTA : BBCPUOpcode<0b00011111>;
def OPC_MOVATTB : BBCPUOpcode<0b00100000>;
def OPC_MOVATAB : BBCPUOpcode<0b00100001>;
def OPC_MOVATATH : BBCPUOpcode<0b00100010>;
def OPC_MOVATATL : BBCPUOpcode<0b00100011>;
def OPC_MOVATBA : BBCPUOpcode<0b00100100>;
def OPC_MOVATBTH : BBCPUOpcode<0b00100101>;
def OPC_MOVATBTL : BBCPUOpcode<0b00100110>;
def OPC_MOVATTHA : BBCPUOpcode<0b00100111>;
def OPC_MOVATTHB : BBCPUOpcode<0b00101000>;
def OPC_MOVATTHTL : BBCPUOpcode<0b00101001>;
def OPC_MOVATTLA : BBCPUOpcode<0b00101010>;
def OPC_MOVATTLB : BBCPUOpcode<0b00101011>;
def OPC_MOVATTLTH : BBCPUOpcode<0b00101100>;
def OPC_MOVATTIMM : BBCPUOpcode<0b00101101>;
def OPC_MOVATAIMM : BBCPUOpcode<0b00101110>;
def OPC_MOVATBIMM : BBCPUOpcode<0b00101111>;
def OPC_MOVATTHIMM : BBCPUOpcode<0b00110000>;
def OPC_MOVATTLIMM : BBCPUOpcode<0b00110001>;
def OPC_NEGAA : BBCPUOpcode<0b00110010>;
def OPC_NEGAB : BBCPUOpcode<0b00110011>;
def OPC_NEGBA : BBCPUOpcode<0b00110100>;
def OPC_NEGBB : BBCPUOpcode<0b00110101>;
def OPC_NEGMEMA : BBCPUOpcode<0b00110110>;
def OPC_NEGMEMB : BBCPUOpcode<0b00110111>;
def OPC_NEGMEMZPA : BBCPUOpcode<0b00111000>;
def OPC_NEGMEMZPB : BBCPUOpcode<0b00111001>;
def OPC_NEGSTCA : BBCPUOpcode<0b00111010>;
def OPC_NEGSTCB : BBCPUOpcode<0b00111011>;
def OPC_ADDA : BBCPUOpcode<0b00111100>;
def OPC_ADDB : BBCPUOpcode<0b00111101>;
def OPC_ADDMEM : BBCPUOpcode<0b00111110>;
def OPC_ADDMEMZP : BBCPUOpcode<0b00111111>;
def OPC_ADDSTC : BBCPUOpcode<0b01000000>;
def OPC_SUBAAB : BBCPUOpcode<0b01000001>;
def OPC_SUBABA : BBCPUOpcode<0b01000010>;
def OPC_SUBBAB : BBCPUOpcode<0b01000011>;
def OPC_SUBBBA : BBCPUOpcode<0b01000100>;
def OPC_SUBMEMAB : BBCPUOpcode<0b01000101>;
def OPC_SUBMEMBA : BBCPUOpcode<0b01000110>;
def OPC_SUBMEMZPAB : BBCPUOpcode<0b01000111>;
def OPC_SUBMEMZPBA : BBCPUOpcode<0b01001000>;
def OPC_SUBSTCAB : BBCPUOpcode<0b01001001>;
def OPC_SUBSTCBA : BBCPUOpcode<0b01001010>;
def OPC_DIV2AA : BBCPUOpcode<0b01001011>;
def OPC_DIV2AB : BBCPUOpcode<0b01001100>;
def OPC_DIV2BA : BBCPUOpcode<0b01001101>;
def OPC_DIV2BB : BBCPUOpcode<0b01001110>;
def OPC_DIV2MEMA : BBCPUOpcode<0b01001111>;
def OPC_DIV2MEMB : BBCPUOpcode<0b01010000>;
def OPC_DIV2MEMZPA : BBCPUOpcode<0b01010001>;
def OPC_DIV2MEMZPB : BBCPUOpcode<0b01010010>;
def OPC_DIV2STCA : BBCPUOpcode<0b01010011>;
def OPC_DIV2STCB : BBCPUOpcode<0b01010100>;
def OPC_INVAA : BBCPUOpcode<0b01010101>;
def OPC_INVAB : BBCPUOpcode<0b01010110>;
def OPC_INVBA : BBCPUOpcode<0b01010111>;
def OPC_INVBB : BBCPUOpcode<0b01011000>;
def OPC_INVMEMA : BBCPUOpcode<0b01011001>;
def OPC_INVMEMB : BBCPUOpcode<0b01011010>;
def OPC_INVMEMZPA : BBCPUOpcode<0b01011011>;
def OPC_INVMEMZPB : BBCPUOpcode<0b01011100>;
def OPC_INVSTCA : BBCPUOpcode<0b01011101>;
def OPC_INVSTCB : BBCPUOpcode<0b01011110>;
def OPC_ORA : BBCPUOpcode<0b01011111>;
def OPC_ORB : BBCPUOpcode<0b01100000>;
def OPC_ORMEM : BBCPUOpcode<0b01100001>;
def OPC_ORMEMZP : BBCPUOpcode<0b01100010>;
def OPC_ORSTC : BBCPUOpcode<0b01100011>;
def OPC_ANDA : BBCPUOpcode<0b01100100>;
def OPC_ANDB : BBCPUOpcode<0b01100101>;
def OPC_ANDMEM : BBCPUOpcode<0b01100110>;
def OPC_ANDMEMZP : BBCPUOpcode<0b01100111>;
def OPC_ANDSTC : BBCPUOpcode<0b01101000>;
def OPC_XORA : BBCPUOpcode<0b01101001>;
def OPC_XORB : BBCPUOpcode<0b01101010>;
def OPC_XORMEM : BBCPUOpcode<0b01101011>;
def OPC_XORMEMZP : BBCPUOpcode<0b01101100>;
def OPC_XORSTC : BBCPUOpcode<0b01101101>;
def OPC_SHRAA : BBCPUOpcode<0b01101110>;
def OPC_SHRAB : BBCPUOpcode<0b01101111>;
def OPC_SHRBA : BBCPUOpcode<0b01110000>;
def OPC_SHRBB : BBCPUOpcode<0b01110001>;
def OPC_SHRMEMA : BBCPUOpcode<0b01110010>;
def OPC_SHRMEMB : BBCPUOpcode<0b01110011>;
def OPC_SHRMEMZPA : BBCPUOpcode<0b01110100>;
def OPC_SHRMEMZPB : BBCPUOpcode<0b01110101>;
def OPC_SHRSTCA : BBCPUOpcode<0b01110110>;
def OPC_SHRSTCB : BBCPUOpcode<0b01110111>;
def OPC_SHLAA : BBCPUOpcode<0b01111000>;
def OPC_SHLAB : BBCPUOpcode<0b01111001>;
def OPC_SHLBA : BBCPUOpcode<0b01111010>;
def OPC_SHLBB : BBCPUOpcode<0b01111011>;
def OPC_SHLMEMA : BBCPUOpcode<0b01111100>;
def OPC_SHLMEMB : BBCPUOpcode<0b01111101>;
def OPC_SHLMEMZPA : BBCPUOpcode<0b01111110>;
def OPC_SHLMEMZPB : BBCPUOpcode<0b01111111>;
def OPC_SHLSTCA : BBCPUOpcode<0b10000000>;
def OPC_SHLSTCB : BBCPUOpcode<0b10000001>;
def OPC_CMPAB : BBCPUOpcode<0b10000010>;
def OPC_CMPBA : BBCPUOpcode<0b10000011>;
def OPC_CMPTHTL : BBCPUOpcode<0b10000100>;
def OPC_CMPTLTH : BBCPUOpcode<0b10000101>;
def OPC_CMPTHA : BBCPUOpcode<0b10000110>;
def OPC_CMPATH : BBCPUOpcode<0b10000111>;
def OPC_CMPTHB : BBCPUOpcode<0b10001000>;
def OPC_CMPBTH : BBCPUOpcode<0b10001001>;
def OPC_CMPTLA : BBCPUOpcode<0b10001010>;
def OPC_CMPATL : BBCPUOpcode<0b10001011>;
def OPC_CMPTLB : BBCPUOpcode<0b10001100>;
def OPC_CMPBTL : BBCPUOpcode<0b10001101>;
def OPC_CLRA : BBCPUOpcode<0b10001110>;
def OPC_CLRB : BBCPUOpcode<0b10001111>;
def OPC_CLRTH : BBCPUOpcode<0b10010000>;
def OPC_CLRTL : BBCPUOpcode<0b10010001>;
def OPC_CLRT : BBCPUOpcode<0b10010010>;
def OPC_INCA : BBCPUOpcode<0b10010011>;
def OPC_INCB : BBCPUOpcode<0b10010100>;
def OPC_INCT : BBCPUOpcode<0b10010101>;
def OPC_DECA : BBCPUOpcode<0b10010110>;
def OPC_DECB : BBCPUOpcode<0b10010111>;
def OPC_DECT : BBCPUOpcode<0b10011000>;
def OPC_JMPIMM : BBCPUOpcode<0b10011001>;
def OPC_JMPIMMS : BBCPUOpcode<0b10011010>;
def OPC_JMPIMMNS : BBCPUOpcode<0b10011011>;
def OPC_JMPIMMTS : BBCPUOpcode<0b10011100>;
def OPC_JMPIMMTNS : BBCPUOpcode<0b10011101>;
def OPC_JMPIMMP : BBCPUOpcode<0b10011110>;
def OPC_JMPIMMNP : BBCPUOpcode<0b10011111>;
def OPC_JMPIMMTP : BBCPUOpcode<0b10100000>;
def OPC_JMPIMMTNP : BBCPUOpcode<0b10100001>;
def OPC_JMPIMMZ : BBCPUOpcode<0b10100010>;
def OPC_JMPIMMNZ : BBCPUOpcode<0b10100011>;
def OPC_JMPIMMTZ : BBCPUOpcode<0b10100100>;
def OPC_JMPIMMTNZ : BBCPUOpcode<0b10100101>;
def OPC_JMPIMMC : BBCPUOpcode<0b10100110>;
def OPC_JMPIMMNC : BBCPUOpcode<0b10100111>;
def OPC_JMPIMMTC : BBCPUOpcode<0b10101000>;
def OPC_JMPIMMTNC : BBCPUOpcode<0b10101001>;
def OPC_JMPIMMO : BBCPUOpcode<0b10101010>;
def OPC_JMPIMMNO : BBCPUOpcode<0b10101011>;
def OPC_JMPIMMTO : BBCPUOpcode<0b10101100>;
def OPC_JMPIMMTNO : BBCPUOpcode<0b10101101>;
def OPC_JMPREL : BBCPUOpcode<0b10101110>;
def OPC_JMPRELS : BBCPUOpcode<0b10101111>;
def OPC_JMPRELNS : BBCPUOpcode<0b10110000>;
def OPC_JMPRELTLS : BBCPUOpcode<0b10110001>;
def OPC_JMPRELTLNS : BBCPUOpcode<0b10110010>;
def OPC_JMPRELP : BBCPUOpcode<0b10110011>;
def OPC_JMPRELNP : BBCPUOpcode<0b10110100>;
def OPC_JMPRELTLP : BBCPUOpcode<0b10110101>;
def OPC_JMPRELTLNP : BBCPUOpcode<0b10110110>;
def OPC_JMPRELZ : BBCPUOpcode<0b10110111>;
def OPC_JMPRELNZ : BBCPUOpcode<0b10111000>;
def OPC_JMPRELTLZ : BBCPUOpcode<0b10111001>;
def OPC_JMPRELTLNZ : BBCPUOpcode<0b10111010>;
def OPC_JMPRELC : BBCPUOpcode<0b10111011>;
def OPC_JMPRELNC : BBCPUOpcode<0b10111100>;
def OPC_JMPRELTLC : BBCPUOpcode<0b10111101>;
def OPC_JMPRELTLNC : BBCPUOpcode<0b10111110>;
def OPC_JMPRELO : BBCPUOpcode<0b10111111>;
def OPC_JMPRELNO : BBCPUOpcode<0b11000000>;
def OPC_JMPRELTLO : BBCPUOpcode<0b11000001>;
def OPC_JMPRELTLNO : BBCPUOpcode<0b11000010>;
def OPC_JMPRELFUN : BBCPUOpcode<0b11000011>;
def OPC_JMPRELRET : BBCPUOpcode<0b11000100>;
def OPC_PUSHA : BBCPUOpcode<0b11000101>;
def OPC_PUSHB : BBCPUOpcode<0b11000110>;
def OPC_PUSHTH : BBCPUOpcode<0b11000111>;
def OPC_PUSHTL : BBCPUOpcode<0b11001000>;
def OPC_PUSHT : BBCPUOpcode<0b11001001>;
def OPC_PUSHIMM : BBCPUOpcode<0b11001010>;
def OPC_PUSHABS : BBCPUOpcode<0b11001011>;
def OPC_PUSHABSZP : BBCPUOpcode<0b11001100>;
def OPC_POPA : BBCPUOpcode<0b11001101>;
def OPC_POPB : BBCPUOpcode<0b11001110>;
def OPC_POPTH : BBCPUOpcode<0b11001111>;
def OPC_POPTL : BBCPUOpcode<0b11010000>;
def OPC_POPT : BBCPUOpcode<0b11010001>;
def OPC_POPMEM : BBCPUOpcode<0b11010010>;
def OPC_POPMEMZP : BBCPUOpcode<0b11010011>;
def OPC_NOP : BBCPUOpcode<0b11010100>;
def OPC_SKIP : BBCPUOpcode<0b11010101>;
def OPC_SKIP1 : BBCPUOpcode<0b11010110>;
def OPC_SKIP2 : BBCPUOpcode<0b11010111>;
def OPC_HALT : BBCPUOpcode<0b11011000>;

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

class BBCPURegInstr<BBCPUOpcode opcode, Register dst, dag ins, string opcodestr, string argstr>
  : BBCPUInstr<(outs), ins, opcodestr, argstr, []> {
  let Defs = [dst];

  let Opcode = opcode.Value;
}

class BBCPUSRegInstr<BBCPUOpcode opcode, Register src, string opcodestr>
    : BBCPUInstr<(outs), (ins), opcodestr, src.AsmName, []> {
  let Uses = [src];

  let Opcode = opcode.Value;
}

class BBCPUDRegInstr<BBCPUOpcode opcode, Register dst, string opcodestr>
    : BBCPUInstr<(outs), (ins), opcodestr, dst.AsmName, []> {
  let Defs = [dst];

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

class BBCPUMemInstr<BBCPUOpcode opcode, dag ins, string opcodestr, string argstr>
    : BBCPUInstr<(outs mem:$imm), ins, opcodestr, argstr, []> {
  let Uses = [T];

  bits<16> imm;

  let Size = 3;

  let Opcode = opcode.Value;
  let Inst{23-8} = imm;
}

class BBCPUMemZPInstr<BBCPUOpcode opcode, dag ins, string opcodestr, string argstr>
    : BBCPUInstr<(outs memzp:$imm), ins, opcodestr, argstr, []> {
  let Uses = [T];

  bits<8> imm;

  let Size = 2;

  let Opcode = opcode.Value;
  let Inst{15-8} = imm;
}

class BBCPUSMemInstr<BBCPUOpcode opcode, string opcodestr>
    : BBCPUInstr<(outs), (ins mem:$imm), opcodestr, "$imm", []> {
  let Uses = [T];

  bits<16> imm;

  let Size = 3;

  let Opcode = opcode.Value;
  let Inst{23-8} = imm;
}

class BBCPUSMemZPInstr<BBCPUOpcode opcode, string opcodestr>
    : BBCPUInstr<(outs), (ins memzp:$imm), opcodestr, "$imm", []> {
  let Uses = [T];

  bits<8> imm;

  let Size = 2;

  let Opcode = opcode.Value;
  let Inst{15-8} = imm;
}

class BBCPURegMemZPInstr<BBCPUOpcode opcode, Register dst, string opcodestr, string argstr>
    : BBCPUInstr<(outs), (ins memzp:$imm), opcodestr, argstr, []> {
  let Defs = [dst];
  let Uses = [T];

  bits<8> imm;

  let Size = 2;

  let Opcode = opcode.Value;
  let Inst{15-8} = imm;
}

class BBCPUMemRegInstr<BBCPUOpcode opcode, Register src, string opcodestr, string argstr>
    : BBCPUInstr<(outs mem:$imm), (ins), opcodestr, argstr, []> {
  let Uses = [src, T];

  bits<16> imm;

  let Size = 3;

  let Opcode = opcode.Value;
  let Inst{23-8} = imm;
}

class BBCPUMemZPRegInstr<BBCPUOpcode opcode, Register src, string opcodestr, string argstr>
    : BBCPUInstr<(outs memzp:$imm), (ins), opcodestr, argstr, []> {
  let Uses = [src, T];

  bits<8> imm;

  let Size = 2;

  let Opcode = opcode.Value;
  let Inst{15-8} = imm;
}

class BBCPUMemBinaryRegInstr<BBCPUOpcode opcode, Register src1, Register src2, string opcodestr, string argstr>
    : BBCPUInstr<(outs mem:$imm), (ins), opcodestr, argstr, []> {
  let Uses = [src1, src2, T];

  bits<16> imm;

  let Size = 3;

  let Opcode = opcode.Value;
  let Inst{23-8} = imm;
}

foreach reg = [A, B, TL, TH, T] in {
  def Indexed#reg#RegOpClass : AsmOperandClass {
    let Name = !strconcat("Indexed", reg.AsmName, "Reg");
    let RenderMethod = "addIndexedRegOperands";
    let PredicateMethod = "isIndexedRegOf<BBCPU::" # reg # ">";
    let SuperClasses = [IndexedRegOperandClass];
  }

  def AT_#reg : IndexedReg<reg> {
    let ParserMatchClass = !cast<AsmOperandClass>("Indexed" # reg # "RegOpClass");
  }
}

class BBCPUIndexedRegInstr<BBCPUOpcode opcode, IndexedReg dst, Register src, string opcodestr>
  : BBCPUInstr<(outs dst:$dst), (ins), opcodestr, !strconcat("$dst, ", src.AsmName), []> {
  IndexedReg dst;
  let Uses = [src, T];

  let Opcode = opcode.Value;
}

class BBCPUIndexedImmInstr<BBCPUOpcode opcode, IndexedReg dst, string opcodestr>
  : BBCPUInstr<(outs dst:$dst), (ins imm8:$imm), opcodestr, "$dst, $imm", []> {
  IndexedReg dst;
  bits<8> imm;

  let Uses = [T];

  let Size = 2;
  let Opcode = opcode.Value;
  let Inst{15-8} = imm;
}

class BBCPUStcRegInstr<BBCPUOpcode opcode, Register src, string opcodestr>
  : BBCPUInstr<(outs stc:$dst), (ins), opcodestr, !strconcat("$dst, ", src.AsmName), []> {
  let Uses = [src];

  let Opcode = opcode.Value;
}

class BBCPUJmpImmInstr<BBCPUOpcode opcode, string opcodestr>
  : BBCPUInstr<(outs), (ins imm16:$imm), opcodestr, "$imm", []> {
  bits<16> imm;

  let Size = 3;
  let Opcode = opcode.Value;
  let Inst{23-8} = imm;
}

class BBCPUJmpRegInstr<BBCPUOpcode opcode, Register src, string opcodestr>
  : BBCPUInstr<(outs), (ins), opcodestr, src.AsmName, []> {
  let Opcode = opcode.Value;
}

class BBCPURelJmpImmInstr<BBCPUOpcode opcode, string opcodestr>
  : BBCPUInstr<(outs), (ins relimm8:$imm), opcodestr, "$imm", []> {
  let Uses = [A, B];
  bits<8> imm;

  let Size = 2;
  let Opcode = opcode.Value;
  let Inst{15-8} = imm;
}

class BBCPURelJmpRegInstr<BBCPUOpcode opcode, Register src, string opcodestr>
  : BBCPUInstr<(outs), (ins), opcodestr, src.AsmName, []> {
  let Uses = [A, B];
  let Opcode = opcode.Value;
}

class BBCPUImmInstr<BBCPUOpcode opcode, string opcodestr>
  : BBCPUInstr<(outs), (ins imm8:$imm), opcodestr, "$imm", []> {
  bits<8> imm;

  let Size = 2;
  let Opcode = opcode.Value;
  let Inst{15-8} = imm;
}

class BBCPUStcInstr<BBCPUOpcode opcode, dag ins, string opcodestr, string argstr>
  : BBCPUInstr<(outs stc:$dst), ins, opcodestr, argstr, []> {
  let Opcode = opcode.Value;
}

class BBCPUCmpInstr<BBCPUOpcode opcode, Register r1, Register r2>
  : BBCPUInstr<(outs), (ins), "cmp", !strconcat(r1.AsmName, ", ", r2.AsmName), []> {
  let Uses = [r1, r2, A, B];

  let Opcode = opcode.Value;
}

def NOP : BBCPUNoopInstr<OPC_NOP, "nop">;
def MOVAB : BBCPUBinaryRegInstr<OPC_MOVAB, A, B, "mov", "a, b">;
def MOVATH : BBCPUBinaryRegInstr<OPC_MOVATH, A, TH, "mov", "a, th">;
def MOVATL : BBCPUBinaryRegInstr<OPC_MOVATL, A, TL, "mov", "a, tl">;
def MOVAF : BBCPUBinaryRegInstr<OPC_MOVAF, A, F, "mov", "a, f">;
def MOVBA : BBCPUBinaryRegInstr<OPC_MOVBA, B, A, "mov", "b, a">;
def MOVBTH : BBCPUBinaryRegInstr<OPC_MOVBTH, B, TH, "mov", "b, th">;
def MOVBTL : BBCPUBinaryRegInstr<OPC_MOVBTL, B, TL, "mov", "b, tl">;
def MOVBF : BBCPUBinaryRegInstr<OPC_MOVBF, B, F, "mov", "b, f">;
def MOVTHA : BBCPUBinaryRegInstr<OPC_MOVTHA, TH, A, "mov", "th, a">;
def MOVTHB : BBCPUBinaryRegInstr<OPC_MOVTHB, TH, B, "mov", "th, b">;
def MOVTHTL : BBCPUBinaryRegInstr<OPC_MOVTHTL, TH, TL, "mov", "th, tl">;
def MOVTHF : BBCPUBinaryRegInstr<OPC_MOVTHF, TH, F, "mov", "th, f">;
def MOVTLA : BBCPUBinaryRegInstr<OPC_MOVTLA, TL, A, "mov", "tl, a">;
def MOVTLB : BBCPUBinaryRegInstr<OPC_MOVTLB, TL, B, "mov", "tl, b">;
def MOVTLTH : BBCPUBinaryRegInstr<OPC_MOVTLTH, TL, TH, "mov", "tl, th">;
def MOVTLF : BBCPUBinaryRegInstr<OPC_MOVTLF, TL, F, "mov", "tl, f">;
def MOVAIMM : BBCPURegImmInstr<OPC_MOVAIMM, A, "mov", "a, $imm">;
def MOVBIMM : BBCPURegImmInstr<OPC_MOVBIMM, B, "mov", "b, $imm">;
def MOVTHIMM : BBCPURegImmInstr<OPC_MOVTHIMM, TH, "mov", "th, $imm">;
def MOVTLIMM : BBCPURegImmInstr<OPC_MOVTLIMM, TL, "mov", "tl, $imm">;
def MOVAABS : BBCPURegMemInstr<OPC_MOVAABS, A, "mov", "a, $imm">;
def MOVAABSZP : BBCPURegMemZPInstr<OPC_MOVAABSZP, A, "mov", "a, $imm">;
def MOVBABS : BBCPURegMemInstr<OPC_MOVBABS, B, "mov", "b, $imm">;
def MOVBABSZP : BBCPURegMemZPInstr<OPC_MOVBABSZP, B, "mov", "b, $imm">;
def MOVATABSA : BBCPUMemRegInstr<OPC_MOVATABSA, A, "mov", "$imm, a">;
def MOVATABSAZP : BBCPUMemZPRegInstr<OPC_MOVATABSAZP, A, "mov", "$imm, a">;
def MOVATABSB : BBCPUMemRegInstr<OPC_MOVATABSB, B, "mov", "$imm, b">;
def MOVATABSBZP : BBCPUMemZPRegInstr<OPC_MOVATABSBZP, B, "mov", "$imm, b">;

def MOVATABSIMM : BBCPUInstr<(outs mem:$dst), (ins imm8:$src), "mov", "$dst, $src", []> {
  bits<8> src;
  bits<16> dst;

  let Size = 4;
  let Opcode = OPC_MOVATABSIMM.Value;
  let Uses = [T];

  let Inst{23-8} = dst;
  let Inst{31-24} = src;
}

def MOVATABSIMMZP : BBCPUInstr<(outs memzp:$dst), (ins imm8:$src), "mov", "$dst, $src", []> {
  bits<8> src;
  bits<16> dst;

  let Size = 4;
  let Opcode = OPC_MOVATABSIMMZP.Value;
  let Uses = [T];

  let Inst{23-8} = dst;
  let Inst{31-24} = src;
}

def MOVATTA : BBCPUIndexedRegInstr<OPC_MOVATTA, AT_T, A, "mov">;
def MOVATTB : BBCPUIndexedRegInstr<OPC_MOVATTB, AT_T, B, "mov">;
def MOVATAB : BBCPUIndexedRegInstr<OPC_MOVATAB, AT_A, B, "mov">;
def MOVATATH : BBCPUIndexedRegInstr<OPC_MOVATATH, AT_A, TH, "mov">;
def MOVATATL : BBCPUIndexedRegInstr<OPC_MOVATATL, AT_A, TL, "mov">;
def MOVATBA : BBCPUIndexedRegInstr<OPC_MOVATBA, AT_B, A, "mov">;
def MOVATBTH : BBCPUIndexedRegInstr<OPC_MOVATBTH, AT_B, TH, "mov">;
def MOVATBTL : BBCPUIndexedRegInstr<OPC_MOVATBTL, AT_B, TL, "mov">;
def MOVATTHA : BBCPUIndexedRegInstr<OPC_MOVATTHA, AT_TH, A, "mov">;
def MOVATTHB : BBCPUIndexedRegInstr<OPC_MOVATTHB, AT_TH, B, "mov">;
def MOVATTHTL : BBCPUIndexedRegInstr<OPC_MOVATTHTL, AT_TH, TL, "mov">;
def MOVATTLA : BBCPUIndexedRegInstr<OPC_MOVATTLA, AT_TL, A, "mov">;
def MOVATTLB : BBCPUIndexedRegInstr<OPC_MOVATTLB, AT_TL, B, "mov">;
def MOVATTLTH : BBCPUIndexedRegInstr<OPC_MOVATTLTH, AT_TL, TH, "mov">;
def MOVATTIMM : BBCPUIndexedImmInstr<OPC_MOVATTIMM, AT_T, "mov">;
def MOVATAIMM : BBCPUIndexedImmInstr<OPC_MOVATAIMM, AT_A, "mov">;
def MOVATBIMM : BBCPUIndexedImmInstr<OPC_MOVATBIMM, AT_B, "mov">;
def MOVATTHIMM : BBCPUIndexedImmInstr<OPC_MOVATTHIMM, AT_TH, "mov">;
def MOVATTLIMM : BBCPUIndexedImmInstr<OPC_MOVATTLIMM, AT_TL, "mov">;
def NEGAA : BBCPUBinaryRegInstr<OPC_NEGAA, A, A, "neg", "a, a">;
def NEGAB : BBCPUBinaryRegInstr<OPC_NEGAB, A, B, "neg", "a, b">;
def NEGBA : BBCPUBinaryRegInstr<OPC_NEGBA, B, A, "neg", "b, a">;
def NEGBB : BBCPUBinaryRegInstr<OPC_NEGBB, B, B, "neg", "b, b">;
def NEGMEMA : BBCPUMemRegInstr<OPC_NEGMEMA, A, "neg", "$imm, a">;
def NEGMEMB : BBCPUMemRegInstr<OPC_NEGMEMB, B, "neg", "$imm, b">;
def NEGMEMZPA : BBCPUMemZPRegInstr<OPC_NEGMEMZPA, A, "neg", "$imm, a">;
def NEGMEMZPB : BBCPUMemZPRegInstr<OPC_NEGMEMZPB, B, "neg", "$imm, b">;
def NEGSTCA : BBCPUStcRegInstr<OPC_NEGSTCA, A, "neg">;
def NEGSTCB : BBCPUStcRegInstr<OPC_NEGSTCB, B, "neg">;
def ADDA : BBCPURegInstr<OPC_ADDA, A, (ins DR:$src1, DR:$src2), "add", "a, $src1, $src2">;
def ADDB : BBCPURegInstr<OPC_ADDB, B, (ins DR:$src1, DR:$src2), "add", "b, $src1, $src2">;
def ADDMEM : BBCPUMemInstr<OPC_ADDMEM, (ins DR:$src1, DR:$src2), "add", "$imm, $src1, $src2">;
def ADDMEMZP : BBCPUMemZPInstr<OPC_ADDMEMZP, (ins DR:$src1, DR:$src2), "add", "$imm, $src1, $src2">;
def ADDSTC : BBCPUStcInstr<OPC_ADDSTC, (ins DR:$src1, DR:$src2), "add", "$dst, $src1, $src2">;
def SUBAAB : BBCPUTernaryRegInstr<OPC_SUBAAB, A, A, B, "sub", "a, a, b">;
def SUBABA : BBCPUTernaryRegInstr<OPC_SUBABA, A, B, A, "sub", "a, b, a">;
def SUBBAB : BBCPUTernaryRegInstr<OPC_SUBBAB, B, A, B, "sub", "b, a, b">;
def SUBBBA : BBCPUTernaryRegInstr<OPC_SUBBBA, B, B, A, "sub", "b, b, a">;
def SUBMEMAB : BBCPUMemBinaryRegInstr<OPC_SUBMEMAB, A, B, "sub", "$imm, a, b">;
def SUBMEMBA : BBCPUMemBinaryRegInstr<OPC_SUBMEMBA, B, A, "sub", "$imm, b, a">;
def SUBMEMZPAB : BBCPUMemZPInstr<OPC_SUBMEMZPAB, (ins DR:$src1, DR:$src2), "sub", "$imm, a, b">;
def SUBMEMZPBA : BBCPUMemZPInstr<OPC_SUBMEMZPBA, (ins DR:$src1, DR:$src2), "sub", "$imm, b, a">;
def SUBSTCAB : BBCPUStcInstr<OPC_SUBSTCAB, (ins DR:$a, DR:$b), "sub", "$dst, a, b">;
def SUBSTCBA : BBCPUStcInstr<OPC_SUBSTCBA, (ins DR:$b, DR:$a), "sub", "$dst, b, a">;
def DIV2AA : BBCPUBinaryRegInstr<OPC_DIV2AA, A, A, "div2", "a, a">;
def DIV2AB : BBCPUBinaryRegInstr<OPC_DIV2AB, A, B, "div2", "a, b">;
def DIV2BA : BBCPUBinaryRegInstr<OPC_DIV2BA, B, A, "div2", "b, a">;
def DIV2BB : BBCPUBinaryRegInstr<OPC_DIV2BB, B, B, "div2", "b, b">;
def DIV2MEMA : BBCPUMemRegInstr<OPC_DIV2MEMA, A, "div2", "$imm, a">;
def DIV2MEMB : BBCPUMemRegInstr<OPC_DIV2MEMB, B, "div2", "$imm, b">;
def DIV2MEMZPA : BBCPUMemZPRegInstr<OPC_DIV2MEMZPA, A, "div2", "$imm, a">;
def DIV2MEMZPB : BBCPUMemZPRegInstr<OPC_DIV2MEMZPB, B, "div2", "$imm, b">;
def DIV2STCA : BBCPUStcRegInstr<OPC_DIV2STCA, A, "div2">;
def DIV2STCB : BBCPUStcRegInstr<OPC_DIV2STCB, B, "div2">;
def INVAA : BBCPUBinaryRegInstr<OPC_INVAA, A, A, "inv", "a, a">;
def INVAB : BBCPUBinaryRegInstr<OPC_INVAB, A, B, "inv", "a, b">;
def INVBA : BBCPUBinaryRegInstr<OPC_INVBA, B, A, "inv", "b, a">;
def INVBB : BBCPUBinaryRegInstr<OPC_INVBB, B, B, "inv", "b, b">;
def INVMEMA : BBCPUMemRegInstr<OPC_INVMEMA, A, "inv", "$imm, a">;
def INVMEMB : BBCPUMemRegInstr<OPC_INVMEMB, B, "inv", "$imm, b">;
def INVMEMZPA : BBCPUMemZPRegInstr<OPC_INVMEMZPA, A, "inv", "$imm, a">;
def INVMEMZPB : BBCPUMemZPRegInstr<OPC_INVMEMZPB, B, "inv", "$imm, b">;
def INVSTCA : BBCPUStcRegInstr<OPC_INVSTCA, A, "inv">;
def INVSTCB : BBCPUStcRegInstr<OPC_INVSTCB, B, "inv">;
def ORA : BBCPURegInstr<OPC_ORA, A, (ins DR:$r1, DR:$r2), "or", "a, $r1, $r2">;
def ORB : BBCPURegInstr<OPC_ORB, B, (ins DR:$r1, DR:$r2), "or", "b, $r1, $r2">;
def ORMEM : BBCPUMemInstr<OPC_ORMEM, (ins DR:$r1, DR:$r2), "or", "$imm, $r1, $r2">;
def ORMEMZP : BBCPUMemZPInstr<OPC_ORMEMZP, (ins DR:$r1, DR:$r2), "or", "$imm, $r1, $r2">;
def ORSTC : BBCPUStcInstr<OPC_ORSTC, (ins DR:$r1, DR:$r2), "or", "$dst, $r1, $r2">;
def ANDA : BBCPURegInstr<OPC_ANDA, A, (ins GPR:$r1, GPR:$r2), "and", "a, $r1, $r2">;
def ANDB : BBCPURegInstr<OPC_ANDB, B, (ins GPR:$r1, GPR:$r2), "and", "b, $r1, $r2">;
def ANDMEM : BBCPUMemInstr<OPC_ANDMEM, (ins GPR:$r1, GPR:$r2), "and", "$imm, $r1, $r2">;
def ANDMEMZP : BBCPUMemZPInstr<OPC_ANDMEMZP, (ins DR:$r1, DR:$r2), "and", "$imm, $r1, $r2">;
def ANDSTC : BBCPUStcInstr<OPC_ANDSTC, (ins DR:$r1, DR:$r2), "and", "$dst, $r1, $r2">;
def XORA : BBCPURegInstr<OPC_XORA, A, (ins DR:$r1, DR:$r2), "xor", "a, $r1, $r2">;
def XORB : BBCPURegInstr<OPC_XORB, B, (ins DR:$r1, DR:$r2), "xor", "b, $r1, $r2">;
def XORMEM : BBCPUMemInstr<OPC_XORMEM, (ins DR:$r1, DR:$r2), "xor", "$imm, $r1, $r2">;
def XORMEMZP : BBCPUMemZPInstr<OPC_XORMEMZP, (ins DR:$r1, DR:$r2), "xor", "$imm, $r1, $r2">;
def XORSTC : BBCPUStcInstr<OPC_XORSTC, (ins DR:$r1, DR:$r2), "xor", "$dst, $r1, $r2">;
def SHRAA : BBCPUBinaryRegInstr<OPC_SHRAA, A, A, "shr", "a, a">;
def SHRAB : BBCPUBinaryRegInstr<OPC_SHRAB, A, B, "shr", "a, b">;
def SHRBA : BBCPUBinaryRegInstr<OPC_SHRBA, B, A, "shr", "b, a">;
def SHRBB : BBCPUBinaryRegInstr<OPC_SHRBB, B, B, "shr", "b, b">;
def SHRMEMA : BBCPUMemRegInstr<OPC_SHRMEMA, A, "shr", "$imm, a">;
def SHRMEMB : BBCPUMemRegInstr<OPC_SHRMEMB, B, "shr", "$imm, b">;
def SHRMEMZPA : BBCPUMemZPRegInstr<OPC_SHRMEMZPA, A, "shr", "$imm, a">;
def SHRMEMZPB : BBCPUMemZPRegInstr<OPC_SHRMEMZPB, B, "shr", "$imm, b">;
def SHRSTCA : BBCPUStcRegInstr<OPC_SHRSTCA, A, "shr">;
def SHRSTCB : BBCPUStcRegInstr<OPC_SHRSTCB, B, "shr">;
def SHLAA : BBCPUBinaryRegInstr<OPC_SHLAA, A, A, "shl", "a, a">;
def SHLAB : BBCPUBinaryRegInstr<OPC_SHLAB, A, B, "shl", "a, b">;
def SHLBA : BBCPUBinaryRegInstr<OPC_SHLBA, B, A, "shl", "b, a">;
def SHLBB : BBCPUBinaryRegInstr<OPC_SHLBB, B, B, "shl", "b, b">;
def SHLMEMA : BBCPUMemRegInstr<OPC_SHLMEMA, A, "shl", "$imm, a">;
def SHLMEMB : BBCPUMemRegInstr<OPC_SHLMEMB, B, "shl", "$imm, b">;
def SHLMEMZPA : BBCPUMemZPRegInstr<OPC_SHLMEMZPA, A, "shl", "$imm, a">;
def SHLMEMZPB : BBCPUMemZPRegInstr<OPC_SHLMEMZPB, B, "shl", "$imm, b">;
def SHLSTCA : BBCPUStcRegInstr<OPC_SHLSTCA, A, "shl">;
def SHLSTCB : BBCPUStcRegInstr<OPC_SHLSTCB, B, "shl">;
def CMPAB : BBCPUCmpInstr<OPC_CMPAB, A, B>;
def CMPBA : BBCPUCmpInstr<OPC_CMPBA, B, A>;
def CMPTHTL : BBCPUCmpInstr<OPC_CMPTHTL, TH, TL>;
def CMPTLTH : BBCPUCmpInstr<OPC_CMPTLTH, TL, TH>;
def CMPTHA : BBCPUCmpInstr<OPC_CMPTHA, TH, A>;
def CMPATH : BBCPUCmpInstr<OPC_CMPATH, A, TH>;
def CMPTHB : BBCPUCmpInstr<OPC_CMPTHB, TH, B>;
def CMPBTH : BBCPUCmpInstr<OPC_CMPBTH, B, TH>;
def CMPTLA : BBCPUCmpInstr<OPC_CMPTLA, TL, A>;
def CMPATL : BBCPUCmpInstr<OPC_CMPATL, A, TL>;
def CMPTLB : BBCPUCmpInstr<OPC_CMPTLB, TL, B>;
def CMPBTL : BBCPUCmpInstr<OPC_CMPBTL, B, TL>;
def CLRA : BBCPUSRegInstr<OPC_CLRA, A, "clr">;
def CLRB : BBCPUSRegInstr<OPC_CLRB, B, "clr">;
def CLRTH : BBCPUSRegInstr<OPC_CLRTH, TH, "clr">;
def CLRTL : BBCPUSRegInstr<OPC_CLRTL, TL, "clr">;
def CLRT : BBCPUSRegInstr<OPC_CLRT, T, "clr">;
def INCA : BBCPUSRegInstr<OPC_INCA, A, "inc">;
def INCB : BBCPUSRegInstr<OPC_INCB, B, "inc">;
def INCT : BBCPUSRegInstr<OPC_INCT, T, "inc">;
def DECA : BBCPUSRegInstr<OPC_DECA, A, "dec">;
def DECB : BBCPUSRegInstr<OPC_DECB, B, "dec">;
def DECT : BBCPUSRegInstr<OPC_DECT, T, "dec">;
def JMPIMM : BBCPUJmpImmInstr<OPC_JMPIMM, "jmp">;
def JMPIMMS : BBCPUJmpImmInstr<OPC_JMPIMMS, "js">;
def JMPIMMNS : BBCPUJmpImmInstr<OPC_JMPIMMNS, "jns">;
def JMPIMMTS : BBCPUJmpRegInstr<OPC_JMPIMMTS, T, "js">;
def JMPIMMTNS : BBCPUJmpRegInstr<OPC_JMPIMMTNS, T, "jns">;
def JMPIMMP : BBCPUJmpImmInstr<OPC_JMPIMMP, "jp">;
def JMPIMMNP : BBCPUJmpImmInstr<OPC_JMPIMMNP, "jnp">;
def JMPIMMTP : BBCPUJmpRegInstr<OPC_JMPIMMTP, T, "jp">;
def JMPIMMTNP : BBCPUJmpRegInstr<OPC_JMPIMMTNP, T, "jnp">;
def JMPIMMZ : BBCPUJmpImmInstr<OPC_JMPIMMZ, "jz">;
def JMPIMMNZ : BBCPUJmpImmInstr<OPC_JMPIMMNZ, "jnz">;
def JMPIMMTZ : BBCPUJmpRegInstr<OPC_JMPIMMTZ, T, "jz">;
def JMPIMMTNZ : BBCPUJmpRegInstr<OPC_JMPIMMTNZ, T, "jnz">;
def JMPIMMC : BBCPUJmpImmInstr<OPC_JMPIMMC, "jc">;
def JMPIMMNC : BBCPUJmpImmInstr<OPC_JMPIMMNC, "jnc">;
def JMPIMMTC : BBCPUJmpRegInstr<OPC_JMPIMMTC, T, "jc">;
def JMPIMMTNC : BBCPUJmpRegInstr<OPC_JMPIMMTNC, T, "jnc">;
def JMPIMMO : BBCPUJmpImmInstr<OPC_JMPIMMO, "jo">;
def JMPIMMNO : BBCPUJmpImmInstr<OPC_JMPIMMNO, "jno">;
def JMPIMMTO : BBCPUJmpRegInstr<OPC_JMPIMMTO, T, "jo">;
def JMPIMMTNO : BBCPUJmpRegInstr<OPC_JMPIMMTNO, T, "jno">;
def JMPREL : BBCPURelJmpImmInstr<OPC_JMPREL, "jr">;
def JMPRELS : BBCPURelJmpImmInstr<OPC_JMPRELS, "jrs">;
def JMPRELNS : BBCPURelJmpImmInstr<OPC_JMPRELNS, "jrns">;
def JMPRELTLS : BBCPURelJmpRegInstr<OPC_JMPRELTLS, TL, "jrs">;
def JMPRELTLNS : BBCPURelJmpRegInstr<OPC_JMPRELTLNS, TL, "jrns">;
def JMPRELP : BBCPURelJmpImmInstr<OPC_JMPRELP, "jrp">;
def JMPRELNP : BBCPURelJmpImmInstr<OPC_JMPRELNP, "jrnp">;
def JMPRELTLP : BBCPURelJmpRegInstr<OPC_JMPRELTLP, TL, "jrp">;
def JMPRELTLNP : BBCPURelJmpRegInstr<OPC_JMPRELTLNP, TL, "jrnp">;
def JMPRELZ : BBCPURelJmpImmInstr<OPC_JMPRELZ, "jrz">;
def JMPRELNZ : BBCPURelJmpImmInstr<OPC_JMPRELNZ, "jrnz">;
def JMPRELTLZ : BBCPURelJmpRegInstr<OPC_JMPRELTLZ, TL, "jrz">;
def JMPRELTLNZ : BBCPURelJmpRegInstr<OPC_JMPRELTLNZ, TL, "jrnz">;
def JMPRELC : BBCPURelJmpImmInstr<OPC_JMPRELC, "jrc">;
def JMPRELNC : BBCPURelJmpImmInstr<OPC_JMPRELNC, "jrnc">;
def JMPRELTLC : BBCPURelJmpRegInstr<OPC_JMPRELTLC, TL, "jrc">;
def JMPRELTLNC : BBCPURelJmpRegInstr<OPC_JMPRELTLNC, TL, "jrnc">;
def JMPRELO : BBCPURelJmpImmInstr<OPC_JMPRELO, "jro">;
def JMPRELNO : BBCPURelJmpImmInstr<OPC_JMPRELNO, "jrno">;
def JMPRELTLO : BBCPURelJmpRegInstr<OPC_JMPRELTLO, TL, "jro">;
def JMPRELTLNO : BBCPURelJmpRegInstr<OPC_JMPRELTLNO, TL, "jrno">;
def JMPRELFUN : BBCPUJmpImmInstr<OPC_JMPRELFUN, "call">;
let Uses = [T] in def JMPRELRET : BBCPUNoopInstr<OPC_JMPRELRET, "ret">;
def PUSHA : BBCPUSRegInstr<OPC_PUSHA, A, "push">;
def PUSHB : BBCPUSRegInstr<OPC_PUSHB, B, "push">;
def PUSHTH : BBCPUSRegInstr<OPC_PUSHTH, TH, "push">;
def PUSHTL : BBCPUSRegInstr<OPC_PUSHTL, TL, "push">;
def PUSHT : BBCPUSRegInstr<OPC_PUSHT, T, "push">;
def PUSHIMM : BBCPUImmInstr<OPC_PUSHIMM, "push">;
def PUSHABS : BBCPUSMemInstr<OPC_PUSHABS, "push">;
def PUSHABSZP : BBCPUSMemZPInstr<OPC_PUSHABSZP, "push">;
def POPA : BBCPUDRegInstr<OPC_POPA, A, "pop">;
def POPB : BBCPUDRegInstr<OPC_POPB, B, "pop">;
def POPTH : BBCPUDRegInstr<OPC_POPTH, TH, "pop">;
def POPTL : BBCPUDRegInstr<OPC_POPTL, TL, "pop">;
def POPT : BBCPUDRegInstr<OPC_POPT, T, "pop">;
def POPMEM : BBCPUMemInstr<OPC_POPMEM, (ins), "pop", "$imm">;
def POPMEMZP : BBCPUMemZPInstr<OPC_POPMEMZP, (ins), "pop", "$imm">;


def HALT : BBCPUNoopInstr<OPC_HALT, "halt">;

//===----------------------------------------------------------------------===//
// Instruction aliases
//===----------------------------------------------------------------------===//
def ASRAA : InstAlias<"asr a, a", (DIV2AA)>;
def ASRAB : InstAlias<"asr a, b", (DIV2AB)>;
def ASRBA : InstAlias<"asr b, a", (DIV2BA)>;
def ASRBB : InstAlias<"asr b, b", (DIV2BB)>;
def ASRMEMA : InstAlias<"asr $dst, a", (DIV2MEMA mem:$dst)>;
def ASRMEMB : InstAlias<"asr $dst, b", (DIV2MEMB mem:$dst)>;
def ASRMEMZPA : InstAlias<"asr $dst, a", (DIV2MEMZPA memzp:$dst)>;
def ASRMEMZPB : InstAlias<"asr $dst, b", (DIV2MEMZPB memzp:$dst)>;
def ASRSTCA : InstAlias<"asr $dst, a", (DIV2STCA stc:$dst)>;
def ASRSTCB : InstAlias<"asr $dst, b", (DIV2STCB stc:$dst)>;
