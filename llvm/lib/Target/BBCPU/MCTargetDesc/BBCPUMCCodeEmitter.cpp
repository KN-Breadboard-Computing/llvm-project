//===-- BBCPUMCCodeEmitter.cpp - Convert BBCPU Code to Machine Code -------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the BBCPUMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/BBCPUMCCodeEmitter.h"
#include "MCTargetDesc/BBCPUMCTargetDesc.h"
#include "MCTargetDesc/BBCPUBaseInfo.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/raw_ostream.h"
#include <cassert>

#define DEBUG_TYPE "mccodeemitter"

STATISTIC(MCNumEmitted, "Number of MC instructions emitted");

using namespace llvm;

BBCPUMCCodeEmitter::BBCPUMCCodeEmitter(const MCInstrInfo &MCII, MCContext &Ctx)
  : MCII(MCII), Ctx(Ctx) {}

void BBCPUMCCodeEmitter::encodeInstruction(const MCInst &MI, SmallVectorImpl<char> &CB,
                                          SmallVectorImpl<MCFixup> &Fixups,
                                          const MCSubtargetInfo &STI) const {
  // Get instruction encoding and emit it.
  uint64_t Bits = getBinaryCodeForInstr(MI, Fixups, STI);
  MCNumEmitted++; // Keep track of the number of emitted insns.

  support::endian::write<uint16_t>(CB, Bits, llvm::endianness::little);
}

unsigned
BBCPUMCCodeEmitter::getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                                     SmallVectorImpl<MCFixup> &Fixups,
                                     const MCSubtargetInfo &STI) const {
  if (MO.isReg())
    return Ctx.getRegisterInfo()->getEncodingValue(MO.getReg());
  if (MO.isImm())
    return static_cast<uint64_t>(MO.getImm());
  return 0;
}

//#define ENABLE_INSTR_PREDICATE_VERIFIER
#include "BBCPUGenMCCodeEmitter.inc"


namespace llvm {
MCCodeEmitter *createBBCPUMCCodeEmitter(const MCInstrInfo &MCII,
                                             MCContext &Ctx) {
  return new BBCPUMCCodeEmitter(MCII, Ctx);
}
}