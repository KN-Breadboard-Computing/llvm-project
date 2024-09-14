//===-- BBCPUInstrFormat.td - BBCPU Instruction Formats -----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the BBCPU instruction formats in TableGen format.
//
//===----------------------------------------------------------------------===//


class InstBBCPU<dag outs, dag ins, string asm, string operands,
               list<dag> pattern = []>
    : Instruction {
    
    bits<16> Inst;
    bits<16> SoftFail = 0; // Needed by disassembler.

    let Namespace = "BBCPU";
    let Size = 2;

    dag OutOperandList = outs;
    dag InOperandList = ins;
  
    // Construct the assembler string from template parameters asm and operands.
    // If the instruction has a delay slot, then append ".n" to the mnemonic.
    let AsmString = !if(!eq(operands, ""), asm, !strconcat(asm, " ", operands));
    let Pattern = pattern;

    let DecoderNamespace = "BBCPU";
}

class Pseudo<dag outs, dag ins, string asmstr, list<dag> pattern>
    : InstBBCPU<outs, ins, asmstr, "", pattern> {
    
    let Inst{15 - 0} = 0;
    let isCodeGenOnly       = 1;
    let isPseudo            = 1;
}

//===----------------------------------------------------------------------===//
// The formats follow the categories specified in the Manual.
//===----------------------------------------------------------------------===//

// Register Register Immediate
class RRI<bits<5> opcode, bits<1> ext, dag outs, dag ins, string asm, string operands, list<dag> pattern = []>
    : InstBBCPU<outs, ins, asm, operands, pattern> {
    let Itinerary = IIC_ALU;

    bits<4> dst;
    bits<4> src;
    bits<2> imm;

    let Inst{15-11} = opcode;
    let Inst{10-10} = ext;
    let Inst{9-6} = dst;
    let Inst{5-2} = src;
    let Inst{1-0} = imm;
}

// Register Register Function
class RRF<bits<5> opcode, bits<1> ext, bits<2> fun, dag outs, dag ins, string asm, string operands, list<dag> pattern = []>
    : InstBBCPU<outs, ins, asm, operands, pattern> {
    let Itinerary = IIC_ALU;

    bits<4> dst;
    bits<4> src;

    let Inst{15-11} = opcode;
    let Inst{10-10} = ext;
    let Inst{9-6} = dst;
    let Inst{5-2} = src;
    let Inst{1-0} = fun;
}

class RRFmerged<bits<5> opcode, bits<1> ext, bits<2> fun, dag outs, dag ins, string asm, string operands, list<dag> pattern = []>
    : InstBBCPU<outs, ins, asm, operands, pattern> {
    let Itinerary = IIC_ALU;

    bits<8> addr;

    let Inst{15-11} = opcode;
    let Inst{10-10} = ext;
    let Inst{9-2} = addr;
    let Inst{1-0} = fun;
}

// Register Register Register
class RRR<bits<5> opcode, bits<1> ext, dag outs, dag ins, string asm, string operands, list<dag> pattern = []>
    : InstBBCPU<outs, ins, asm, operands, pattern> {
    let Itinerary = IIC_ALU;

    bits<4> dst;
    bits<3> src1;
    bits<3> src2;

    let Inst{15-11} = opcode;
    let Inst{10-10} = ext;
    let Inst{9-6} = dst;
    let Inst{5-3} = src1;
    let Inst{2-0} = src2;
}

class RRRmerged<bits<5> opcode, bits<1> ext, dag outs, dag ins, string asm, string operands, list<dag> pattern = []>
    : InstBBCPU<outs, ins, asm, operands, pattern> {
    let Itinerary = IIC_ALU;

    bits<4> dst;
    bits<6> addr;

    let Inst{15-11} = opcode;
    let Inst{10-10} = ext;
    let Inst{9-6} = dst;
    let Inst{5-0} = addr;
}

// Register Immediate Immediate
class RII<bits<5> opcode, bits<1> ext, dag outs, dag ins, string asm, string operands, list<dag> pattern = []>
    : InstBBCPU<outs, ins, asm, operands, pattern> {
    let Itinerary = IIC_ALU;

    bits<4> dst;
    bits<4> imm4;
    bits<2> imm2;

    let Inst{15-11} = opcode;
    let Inst{10-10} = ext;
    let Inst{9-6} = dst;
    let Inst{5-2} = imm4;
    let Inst{1-0} = imm2;
}

// Register 5-bit Immediate Function
class RI5F<bits<5> opcode, bits<1> ext, dag outs, dag ins, string asm, string operands, list<dag> pattern = []>
    : InstBBCPU<outs, ins, asm, operands, pattern> {
    let Itinerary = IIC_ALU;

    bits<4> dst;
    bits<5> imm;
    bits<1> fun;

    let Inst{15-11} = opcode;
    let Inst{10-10} = ext;
    let Inst{9-6} = dst;
    let Inst{5-1} = imm;
    let Inst{0-0} = fun;
}

// Register 4-bit Immediate Function
class RI4F<bits<5> opcode, bits<1> ext, dag outs, dag ins, string asm, string operands, list<dag> pattern = []>
    : InstBBCPU<outs, ins, asm, operands, pattern> {
    let Itinerary = IIC_ALU;

    bits<4> dst;
    bits<4> imm;
    bits<2> fun;

    let Inst{15-11} = opcode;
    let Inst{10-10} = ext;
    let Inst{9-6} = dst;
    let Inst{5-2} = imm;
    let Inst{1-0} = fun;
}

// Register 6-bit Immediate
class RI6F<bits<5> opcode, bits<1> ext, dag outs, dag ins, string asm, string operands, list<dag> pattern = []>
    : InstBBCPU<outs, ins, asm, operands, pattern> {
    let Itinerary = IIC_ALU;

    bits<4> dst;
    bits<6> imm;

    let Inst{15-11} = opcode;
    let Inst{10-10} = ext;
    let Inst{9-6} = dst;
    let Inst{5-0} = imm;
}


class RRF_AluAllRegs16<bits<5> opcode, bits<2> fun, string asm, list<dag> pattern = []>
    : RRF<opcode, 0b0, fun, (outs GPR16Opnd:$dst), (ins GPR16Opnd:$src), asm, "$dst, $src", pattern>, Sched<[WriteALU]> { }

class RRF_JumpRegs16<bits<5> opcode, bits<2> fun, string asm, list<dag> pattern = []>
    : RRFmerged<opcode, 0b0, fun, (outs), (ins GPR32Opnd:$addr), asm, "$addr", pattern>, Sched<[WriteALU]> { }

class RRR_AluAllRegs16<bits<5> opcode, string asm, list<dag> pattern = []>
    : RRR<opcode, 0b0, (outs GPR16Opnd:$dst), (ins GPR16LowOpnd:$src1, GPR16LowOpnd:$src2), asm, "$dst, $src1, $src2", pattern>, Sched<[WriteALU]> { }

class RRR_LoadAllRegs32<bits<5> opcode, list<dag> pattern = []>
    : RRRmerged<opcode, 0b0, (outs GPR16Opnd:$dst), (ins GPR32Opnd:$addr), "load $dst, $addr", "$dst, $addr", pattern>, Sched<[WriteLD]> { }

class RRR_StoreAllRegs32<bits<5> opcode, list<dag> pattern = []>
    : RRRmerged<opcode, 0b0, (outs), (ins GPR16Opnd:$dst, GPR32Opnd:$addr), "store $dst, $addr", "$dst, $addr", pattern>, Sched<[WriteST]> { }
