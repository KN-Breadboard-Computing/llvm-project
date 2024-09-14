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

#include "llvm/MC/MCInstrDesc.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/Support/DataTypes.h"

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCRegisterInfo;
class MCSubtargetInfo;
class MCRelocationInfo;
class MCTargetOptions;
class Target;
class Triple;
class StringRef;
class raw_ostream;
class raw_pwrite_stream;

MCAsmBackend *createBBCPUAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                   const MCRegisterInfo &MRI,
                                   const MCTargetOptions &Options);

MCCodeEmitter *createBBCPUMCCodeEmitter(const MCInstrInfo &MCII,
                                       MCContext &Ctx);

/// Construct an BBCPU ELF object writer.
std::unique_ptr<MCObjectTargetWriter> createBBCPUELFObjectWriter(uint8_t OSABI);

} // namespace llvm

#define GET_REGINFO_ENUM
#include "BBCPUGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#define GET_INSTRINFO_MC_HELPER_DECLS
#include "BBCPUGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "BBCPUGenSubtargetInfo.inc"

#endif // LLVM_BBCPU_MCTARGET_DESC_H
