import argparse
import json


OPERAND_PREFIX = \
r"""//===-- BBCPUInstrInfo.td - BBCPU Instruction defs ---------*- tablegen -*-===//
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
"""

OPCODE_PREFIX = \
r"""
//===----------------------------------------------------------------------===//
// Opcode and Instruction definitions
//===----------------------------------------------------------------------===//

// Following opcodes names and values match those defined in the manual
// (see https://kn-breadboard-computing.github.io/proc-instr/)
class BBCPUOpcode<bits<8> val> {
    bits<8> Value = val;
}

"""

INSTRUCTION_PREFIX = \
r"""
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
  llet Uses = [A, B];
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

"""

MOVATABSIMM = \
r"""def MOVATABSIMM : BBCPUInstr<(outs mem:$dst), (ins imm8:$src), "mov", "$dst, $src", []> {
  bits<8> src;
  bits<16> dst;

  let Size = 4;
  let Opcode = OPC_MOVATABSIMM.Value;
  let Uses = [T];

  let Inst{23-8} = dst;
  let Inst{31-24} = src;
}
"""

MOVATABSIMMZP = \
r"""def MOVATABSIMMZP : BBCPUInstr<(outs memzp:$dst), (ins imm8:$src), "mov", "$dst, $src", []> {
  bits<8> src;
  bits<16> dst;

  let Size = 4;
  let Opcode = OPC_MOVATABSIMMZP.Value;
  let Uses = [T];

  let Inst{23-8} = dst;
  let Inst{31-24} = src;
}
"""

ALIASES_SUFIX = \
r"""
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
"""

def define_opcodes(instructions_config: json) -> str:
    result = ""
    for _, instruction in instructions_config.items():
        result += f"def OPC_{instruction['name']} : BBCPUOpcode<{instruction['opcode']}>;\n"

    return result

def define_instructions(instructions_config: json) -> str:
    result = ""

    for _, instruction in instructions_config.items():
        if instruction['mnemonic'] == 'MOV':
            if 'IMM' in instruction['name']:
                instruction_type = "BBCPURegImmInstr"
                dst = instruction['arguments'][0]
                mnemonic = "mov"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, \"{mnemonic}\", \"{dst.lower()}, $imm\">;\n"
            elif 'ABSZP' in instruction['name']:
                instruction_type = "BBCPURegMemZPInstr"
                dst = instruction['arguments'][0]
                mnemonic = "mov"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, \"{mnemonic}\", \"{dst.lower()}, $imm\">;\n"
            elif 'ABS' in instruction['name']:
                instruction_type = "BBCPURegMemInstr"
                dst = instruction['arguments'][0]
                mnemonic = "mov"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, \"{mnemonic}\", \"{dst.lower()}, $imm\">;\n"
            else:
                instruction_type = "BBCPUBinaryRegInstr"
                dst = instruction['arguments'][0]
                src = instruction['arguments'][1]
                mnemonic = "mov"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, {src}, \"{mnemonic}\", \"{dst.lower()}, {src.lower()}\">;\n"
        elif instruction['mnemonic'] == 'MOVAT':
            if instruction['name'] == 'MOVATABSIMM':
                result += MOVATABSIMM
            elif instruction['name'] == 'MOVATABSIMMZP':
                result += MOVATABSIMMZP
            elif 'IMM' in instruction['name']:
                instruction_type = "BBCPUIndexedImmInstr"
                dst = instruction['arguments'][0]
                mnemonic = "mov"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, AT_{dst}, \"{mnemonic}\">;\n"
            elif 'ABS' in instruction['name'] and 'ZP' in instruction['name']:
                instruction_type = "BBCPUMemZPRegInstr"
                dst = instruction['arguments'][1]
                mnemonic = "mov"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, \"{mnemonic}\", \"$imm, {dst.lower()}\">;\n"
            elif 'ABS' in instruction['name']:
                instruction_type = "BBCPUMemRegInstr"
                dst = instruction['arguments'][1]
                mnemonic = "mov"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, \"{mnemonic}\", \"$imm, {dst.lower()}\">;\n"
            else:
                instruction_type = "BBCPUIndexedRegInstr"
                dst = "AT_" + instruction['arguments'][0]
                src = instruction['arguments'][1]
                mnemonic = "mov"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, {src}, \"{mnemonic}\">;\n"
        elif instruction['mnemonic'] in ['NEG', 'DIV2', 'INV', 'SHR', 'SHL']:
            if 'MEMZP' in instruction['name']:
                instruction_type = "BBCPUMemZPRegInstr"
                src = instruction['arguments'][1]
                mnemonic = instruction['mnemonic'].lower()
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {src}, \"{mnemonic}\", \"$imm, {src.lower()}\">;\n"
            elif 'MEM' in instruction['name']:
                instruction_type = "BBCPUMemRegInstr"
                src = instruction['arguments'][1]
                mnemonic = instruction['mnemonic'].lower()
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {src}, \"{mnemonic}\", \"$imm, {src.lower()}\">;\n"
            elif 'STC' in instruction['name']:
                instruction_type = "BBCPUStcRegInstr"
                src = instruction['arguments'][1]
                mnemonic = instruction['mnemonic'].lower()
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {src}, \"{mnemonic}\">;\n"
            else:
                instruction_type = "BBCPUBinaryRegInstr"
                dst = instruction['arguments'][0]
                src = instruction['arguments'][1]
                mnemonic = instruction['mnemonic'].lower()
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, {src}, \"{mnemonic}\", \"{dst.lower()}, {src.lower()}\">;\n"
        elif instruction['mnemonic'] in ['ADD', 'OR', 'AND', 'XOR']:
            if 'MEMZP' in instruction['name']:
                instruction_type = "BBCPUMemZPInstr"
                dst = instruction['arguments'][0]
                mnemonic = instruction['mnemonic'].lower()
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, (ins DR:$src1, DR:$src2), \"{mnemonic}\", \"$imm, $src1, $src2\">;\n"
            elif 'MEM' in instruction['name']:
                instruction_type = "BBCPUMemInstr"
                dst = instruction['arguments'][0]
                mnemonic = instruction['mnemonic'].lower()
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, (ins DR:$src1, DR:$src2), \"{mnemonic}\", \"$imm, $src1, $src2\">;\n"
            elif 'STC' in instruction['name']:
                instruction_type = "BBCPUStcInstr"
                dst = instruction['arguments'][0]
                mnemonic = instruction['mnemonic'].lower()
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, (ins DR:$src1, DR:$src2), \"{mnemonic}\", \"$dst, $src1, $src2\">;\n"
            else:
                instruction_type = "BBCPURegInstr"
                dst = instruction['arguments'][0]
                mnemonic = instruction['mnemonic'].lower()
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, (ins DR:$src1, DR:$src2), \"{mnemonic}\", \"{dst.lower()}, $src1, $src2\">;\n"
        elif instruction['mnemonic'] == 'SUB':
            if 'MEMZP' in instruction['name']:
                instruction_type = "BBCPUMemZPInstr"
                dst = instruction['arguments'][0]
                src1 = instruction['arguments'][1]
                src2 = instruction['arguments'][2]
                mnemonic = "sub"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {src1}, {src2}, \"{mnemonic}\", \"$imm, {src1.lower()}, {src2.lower()}\">;\n"
            elif 'MEM' in instruction['name']:
                instruction_type = "BBCPUMemBinaryRegInstr"
                dst = instruction['arguments'][0]
                src1 = instruction['arguments'][1]
                src2 = instruction['arguments'][2]
                mnemonic = "sub"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {src1}, {src2}, \"{mnemonic}\", \"$imm, {src1.lower()}, {src2.lower()}\">;\n"
            elif 'STC' in instruction['name']:
                instruction_type = "BBCPUStcInstr"
                dst = instruction['arguments'][0]
                src1 = instruction['arguments'][1]
                src2 = instruction['arguments'][2]
                mnemonic = "sub"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {src1}, {src2}, \"{mnemonic}\", \"$dst, {src1.lower()}, {src2.lower()}\">;\n"
            else:
                instruction_type = "BBCPUTernaryRegInstr"
                dst = instruction['arguments'][0]
                src1 = instruction['arguments'][1]
                src2 = instruction['arguments'][2]
                mnemonic = "sub"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, {src1}, {src2}, \"{mnemonic}\", \"{dst.lower()}, {src1.lower()}, {src2.lower()}\">;\n"
        elif instruction['mnemonic'] == 'CMP':
            instruction_type = "BBCPUCmpInstr"
            src1 = instruction['arguments'][0]
            src2 = instruction['arguments'][1]
            result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {src1}, {src2}>;\n"
        elif instruction['mnemonic'] in ['CLR', 'INC', 'DEC']:
            instruction_type = "BBCPUSRegInstr"
            src = instruction['arguments'][0]
            mnemonic = instruction['mnemonic'].lower()
            result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {src}, \"{mnemonic}\">;\n"
        elif instruction['mnemonic'] == 'JMPIMM':
            mnemonic = "jmp" if instruction['depend-on-flag'] == "" else f"j{instruction['depend-on-flag'].lower()}"
            if 'T' in instruction['name']:
                instruction_type = "BBCPUJmpRegInstr"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, T, \"{mnemonic}\">;\n"
            else:
                instruction_type = "BBCPUJmpImmInstr"
                src = instruction['arguments'][0]
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, \"{mnemonic}\">;\n"
        elif instruction['mnemonic'] == 'JMPREL':
            mnemonic = "jr" if instruction['depend-on-flag'] == "" else f"jr{instruction['depend-on-flag'].lower()}"
            if instruction['name'] == 'JMPRELFUN':
                result += f"def JMPRELFUN : BBCPUJmpImmInstr<OPC_JMPRELFUN, \"call\">;\n"
            elif instruction['name'] == 'JMPRELRET':
                result += f"let Uses = [T] in def JMPRELRET : BBCPUNoopInstr<OPC_JMPRELRET, \"ret\">;\n"
            elif 'TL' in instruction['name']:
                instruction_type = "BBCPURelJmpRegInstr"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, TL, \"{mnemonic}\">;\n"
            elif 'T' in instruction['name']:
                instruction_type = "BBCPURelJmpRegInstr"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, T, \"{mnemonic}\">;\n"
            else:
                instruction_type = "BBCPURelJmpImmInstr"
                src = instruction['arguments'][0]
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, \"{mnemonic}\">;\n"
        elif instruction['mnemonic'] == 'PUSH':
            if 'IMM' in instruction['name']:
                instruction_type = "BBCPUImmInstr"
                mnemonic = "push"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, \"{mnemonic}\">;\n"
            elif 'ABSZP' in instruction['name']:
                instruction_type = "BBCPUSMemZPInstr"
                mnemonic = "push"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, \"{mnemonic}\">;\n"
            elif 'ABS' in instruction['name']:
                instruction_type = "BBCPUSMemInstr"
                mnemonic = "push"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, \"{mnemonic}\">;\n"
            else:
                instruction_type = "BBCPUSRegInstr"
                src = instruction['arguments'][0]
                mnemonic = "push"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {src}, \"{mnemonic}\">;\n"
        elif instruction['mnemonic'] == 'POP':
            if "MEMZP" in instruction['name']:
                instruction_type = "BBCPUMemZPInstr"
                dst = instruction['arguments'][0]
                mnemonic = "pop"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, (ins), \"{mnemonic}\", \"$imm\">;\n"
            elif 'MEM' in instruction['name']:
                instruction_type = "BBCPUMemInstr"
                dst = instruction['arguments'][0]
                mnemonic = "pop"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, (ins), \"{mnemonic}\", \"$imm\">;\n"
            else:
                instruction_type = "BBCPUDRegInstr"
                dst = instruction['arguments'][0]
                mnemonic = "pop"
                result += f"def {instruction['name']} : {instruction_type}<OPC_{instruction['name']}, {dst}, \"{mnemonic}\">;\n"
        elif instruction['mnemonic'] == 'NOP':
            result += f"def NOP : BBCPUNoopInstr<OPC_NOP, \"nop\">;\n"
        elif instruction['mnemonic'] == 'SKIP':
            result += f"def SKIP : BBCPUNoopInstr<OPC_SKIP, \"skip\">;\n"
        elif instruction['mnemonic'] == 'SKIP1':
            result += f"def SKIP1 : BBCPUNoopInstr<OPC_SKIP1, \"skip1\">;\n"
        elif instruction['mnemonic'] == 'SKIP2':
            result += f"def SKIP2 : BBCPUNoopInstr<OPC_SKIP2, \"skip2\">;\n"
        elif instruction['mnemonic'] == 'ISR':
            result += f"def ISR : BBCPUNoopInstr<OPC_ISR, \"isr\">;\n"
        elif instruction['mnemonic'] == 'IRET':
            result += f"def IRET : BBCPUNoopInstr<OPC_IRET, \"iret\">;\n"
        elif 'INT' in instruction['mnemonic']:
            mnemonic = instruction['name'].lower()
            result += f"def {instruction['name']} : BBCPUNoopInstr<OPC_{instruction['name']}, \"{instruction['name'].lower()}\">;\n"
        elif instruction['mnemonic'] == 'HALT':
            result += f"def HALT : BBCPUNoopInstr<OPC_HALT, \"halt\">;\n"
        else:
            print(f"Unknown instruction type: {instruction['mnemonic']}")
            continue

    return result


# main
arg_parser = argparse.ArgumentParser(description='BBCPU LLVM Backend Generator')
arg_parser.add_argument('--config', required=True, help='Configuration file for instructions')

args = arg_parser.parse_args()

with open(args.config) as f:
    instructions_config = json.load(f)

with open("BBCPUInstrInfo.td", "w") as f:
    f.write(OPERAND_PREFIX)
    f.write(OPCODE_PREFIX)
    f.write(define_opcodes(instructions_config))
    f.write(INSTRUCTION_PREFIX)
    f.write(define_instructions(instructions_config))
    f.write(ALIASES_SUFIX)
