//===-- BBCompMCTargetDesc.cpp - BBCPU Target Descriptions ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides BBCPU specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "BBCPUMCTargetDesc.h"
#include "BBCPUAsmBackend.h"
#include "BBCPUMCAsmInfo.h"
#include "TargetInfo/BBCPUTargetInfo.h"

#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "BBCPUGenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "BBCPUGenRegisterInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "BBCPUGenSubtargetInfo.inc"

using namespace llvm;

static MCInstrInfo *createBBCPUMCInstrInfo() {
  MCInstrInfo *info = new MCInstrInfo();
  InitBBCPUMCInstrInfo(info);

  return info;
}

static MCRegisterInfo *createBBCPUMCRegisterInfo(const Triple &) {
  MCRegisterInfo *info = new MCRegisterInfo();
  InitBBCPUMCRegisterInfo(info, 0);

  return info;
}

static MCSubtargetInfo *
createBBCPUMCSubtargetInfo(const Triple &TT, StringRef CPU, StringRef FS) {
  return createBBCPUMCSubtargetInfoImpl(TT, CPU, CPU, FS);
}

static MCStreamer *createMCStreamer(const Triple &T, MCContext &Ctx,
                                    std::unique_ptr<MCAsmBackend> &&TAB,
                                    std::unique_ptr<MCObjectWriter> &&OW,
                                    std::unique_ptr<MCCodeEmitter> &&Emitter,
                                    bool RelaxAll) {
  return createELFStreamer(Ctx, std::move(TAB), std::move(OW),
                           std::move(Emitter), RelaxAll);
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeBBCPUTargetMC() {
  RegisterMCAsmInfo<BBCPUMCAsmInfo> X(getTheBBCPUTarget());

  TargetRegistry::RegisterMCInstrInfo(getTheBBCPUTarget(),
                                      createBBCPUMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(getTheBBCPUTarget(),
                                    createBBCPUMCRegisterInfo);
  TargetRegistry::RegisterMCSubtargetInfo(getTheBBCPUTarget(),
                                          createBBCPUMCSubtargetInfo);

  TargetRegistry::RegisterELFStreamer(getTheBBCPUTarget(), createMCStreamer);

  TargetRegistry::RegisterMCAsmBackend(getTheBBCPUTarget(),
                                       createBBCPUMCAsmBackend);

  TargetRegistry::RegisterMCCodeEmitter(getTheBBCPUTarget(),
                                        createBBCPUMCCodeEmitter);
}
