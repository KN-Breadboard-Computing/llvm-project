//===-- BBCPUMCTargetDesc.h - BBCPU Target Descriptions ---------*- C++ -*-===//
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

#ifndef LLVM_BBCPU_MCTARGET_DESC_H
#define LLVM_BBCPU_MCTARGET_DESC_H

#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/TargetRegistry.h"

#include <memory>

namespace llvm {

class MCInstrInfo;

MCAsmBackend *createBBCPUMCAsmBackend(const Target &T,
                                      const MCSubtargetInfo &STI,
                                      const MCRegisterInfo &MRI,
                                      const MCTargetOptions &Options);

MCCodeEmitter *createBBCPUMCCodeEmitter(const MCInstrInfo &MCII,
                                        MCContext &Ctx);

std::unique_ptr<MCObjectTargetWriter> createBBCPUELFObjectWriter(uint8_t OSABI);

} // end namespace llvm

#define GET_REGINFO_ENUM
#include "BBCPUGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#define GET_INSTRINFO_MC_HELPER_DECLS
#include "BBCPUGenInstrInfo.inc"

#endif // LLVM_BBCPU_MCTARGET_DESC_H
