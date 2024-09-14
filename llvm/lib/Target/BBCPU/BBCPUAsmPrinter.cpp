//===-- BBCPUAsmPrinter.cpp - BBCPU LLVM assembly writer ----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format BBCPU assembly language.
//
//===----------------------------------------------------------------------===//

#include "BBCPUMCInstLower.h"
#include "MCTargetDesc/BBCPUMCTargetDesc.h"
#include "TargetInfo/BBCPUTargetInfo.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/TargetRegistry.h"
#include <memory>

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

namespace {
class BBCPUAsmPrinter : public AsmPrinter {
public:
  explicit BBCPUAsmPrinter(
      TargetMachine &TM,
      std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

  StringRef getPassName() const override {
    return "BBCPU Assembly Printer";
  }

  void emitInstruction(const MachineInstr *MI) override;
};
} // end of anonymous namespace

void BBCPUAsmPrinter::emitInstruction(
    const MachineInstr *MI) {
  MCInst LoweredMI;
  BBCPUMCInstLower Lower;
  Lower.lower(MI, LoweredMI);
  EmitToStreamer(*OutStreamer, LoweredMI);
}

// Force static initialization.
extern "C" LLVM_EXTERNAL_VISIBILITY void
LLVMInitializeBBCPUAsmPrinter() {
  RegisterAsmPrinter<BBCPUAsmPrinter> X(
      getTheBBCPUTarget());
}
