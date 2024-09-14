//===-- BBCPU.td - BBCPU target definitions --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This is a target description file for the 16-bit BBCPU architecture
///
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// BBCPU Subtarget features
//===----------------------------------------------------------------------===//

include "BBCPUSchedule.td"

def : ProcessorModel<"generic", BBCPUSchedModel, []>;

//===----------------------------------------------------------------------===//
// Register File Description
//===----------------------------------------------------------------------===//

include "BBCPURegisterInfo.td"

//===----------------------------------------------------------------------===//
// Instruction Descriptions
//===----------------------------------------------------------------------===//

include "BBCPUInstrInfo.td"

def BBCPUInstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// Calling Conventions
//===----------------------------------------------------------------------===//

include "BBCPUCallingConv.td"

//===---------------------------------------------------------------------===//
// Assembly Printers
//===---------------------------------------------------------------------===//

def BBCPUAsmWriter : AsmWriter {
 string AsmWriterClassName = "InstPrinter";
 bit isMCAsmWriter = 1;
}

//===---------------------------------------------------------------------===//
// Assembly Parsers
//===---------------------------------------------------------------------===//

def BBCPUAsmParser : AsmParser {
  let ShouldEmitMatchRegisterName = 1;
  let ShouldEmitMatchRegisterAltName = 1;
}

def BBCPUAsmParserVariant : AsmParserVariant {
  int Variant = 0;
}

//===----------------------------------------------------------------------===//
// Target
//===----------------------------------------------------------------------===//

def BBCPU : Target {
  let InstructionSet = BBCPUInstrInfo;
  let AssemblyParsers = [BBCPUAsmParser];
  let AssemblyWriters = [BBCPUAsmWriter];
}
