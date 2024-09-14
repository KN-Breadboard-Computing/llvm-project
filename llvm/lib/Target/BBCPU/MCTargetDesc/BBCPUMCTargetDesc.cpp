//===-- BBCPUMCTargetDesc.cpp - BBCPU Target Descriptions ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file provides BBCPU target specific descriptions.
///
//===----------------------------------------------------------------------===//

#include "BBCPUMCTargetDesc.h"
#include "BBCPUInstPrinter.h"
#include "BBCPUMCAsmInfo.h"
#include "TargetInfo/BBCPUTargetInfo.h"

#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCInstPrinter.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MachineLocation.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

#define GET_INSTRINFO_MC_DESC
#define ENABLE_INSTR_PREDICATE_VERIFIER
#include "BBCPUGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "BBCPUGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "BBCPUGenRegisterInfo.inc"

// TODO Implement feature set parsing logics
static std::string ParseBBCPUTriple(const Triple &TT, StringRef CPU) {
  return "";
}

static MCInstrInfo *createBBCPUMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitBBCPUMCInstrInfo(X); // defined in BBCPUGenInstrInfo.inc
  return X;
}

static MCRegisterInfo *createBBCPUMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitBBCPUMCRegisterInfo(X, llvm::BBCPU::R1);
  return X;
}

static MCSubtargetInfo *createBBCPUMCSubtargetInfo(const Triple &TT,
                                                  StringRef CPU, StringRef FS) {
  std::string ArchFS = ParseBBCPUTriple(TT, CPU);
  if (!FS.empty()) {
    if (!ArchFS.empty()) {
      ArchFS = (ArchFS + "," + FS).str();
    } else {
      ArchFS = FS.str();
    }
  }
  return createBBCPUMCSubtargetInfoImpl(TT, CPU, /*TuneCPU=*/CPU, ArchFS);
}

static MCAsmInfo *createBBCPUMCAsmInfo(const MCRegisterInfo &MRI,
                                      const Triple &TT,
                                      const MCTargetOptions &TO) {
  MCAsmInfo *MAI = new BBCPUMCAsmInfo(TT, TO);
  return MAI;
}

static MCRelocationInfo *createBBCPUMCRelocationInfo(const Triple &TheTriple,
                                                    MCContext &Ctx) {
  // Default to the stock relocation info.
  return llvm::createMCRelocationInfo(TheTriple, Ctx);
}

static MCInstPrinter *createBBCPUMCInstPrinter(const Triple &T,
                                              unsigned SyntaxVariant,
                                              const MCAsmInfo &MAI,
                                              const MCInstrInfo &MII,
                                              const MCRegisterInfo &MRI) {
  return new BBCPUInstPrinter(MAI, MII, MRI);
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeBBCPUTargetMC() {
  Target &T = getTheBBCPUTarget();

  // Register the MC asm info.
  RegisterMCAsmInfoFn X(T, createBBCPUMCAsmInfo);

  // Register the MC instruction info.
  TargetRegistry::RegisterMCInstrInfo(T, createBBCPUMCInstrInfo);

  // Register the MC register info.
  TargetRegistry::RegisterMCRegInfo(T, createBBCPUMCRegisterInfo);

  // Register the MC subtarget info.
  TargetRegistry::RegisterMCSubtargetInfo(T, createBBCPUMCSubtargetInfo);

  // Register the code emitter.
  TargetRegistry::RegisterMCCodeEmitter(T, createBBCPUMCCodeEmitter);

  // Register the MCInstPrinter.
  TargetRegistry::RegisterMCInstPrinter(T, createBBCPUMCInstPrinter);

  // Register the MC relocation info.
  TargetRegistry::RegisterMCRelocationInfo(T, createBBCPUMCRelocationInfo);

  // Register the asm backend.
  TargetRegistry::RegisterMCAsmBackend(T, createBBCPUAsmBackend);
}
