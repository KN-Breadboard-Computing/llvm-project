//===-- BBCPU.td - Describe the BBCPU Target Machine -----*-- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===---------------------------------------------------------------------===//
// This is the top level entry point for the BBCPU target.
//===---------------------------------------------------------------------===//

//===---------------------------------------------------------------------===//
// Target-independent interfaces which we are implementing
//===---------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===---------------------------------------------------------------------===//
// Processor Description
//===---------------------------------------------------------------------===//

def : Processor<"BBCPU", NoItineraries, []>;

//===---------------------------------------------------------------------===//
// Register File Description
//===---------------------------------------------------------------------===//

include "BBCPURegisterInfo.td"

//===---------------------------------------------------------------------===//
// Instruction Descriptions
//===---------------------------------------------------------------------===//

include "BBCPUInstrInfo.td"

def BBCPUInstrInfo : InstrInfo;

//===---------------------------------------------------------------------===//
// Target Declaration
//===---------------------------------------------------------------------===//

def BBCPUAsmParser : AsmParser {
    let ShouldEmitMatchRegisterAltName = 1;
}

def BBCPU : Target {
    let InstructionSet = BBCPUInstrInfo;
    let AssemblyParsers = [BBCPUAsmParser];
}
