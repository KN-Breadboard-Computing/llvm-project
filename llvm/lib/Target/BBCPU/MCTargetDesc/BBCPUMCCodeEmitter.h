//===-- BBCPUMCCodeEmitter.h - Convert BBCPU Code to Machine Code ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the BBCPUMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//
//

#ifndef LLVM_BBCPU_MCCODEEMITTER_H
#define LLVM_BBCPU_MCCODEEMITTER_H

#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCInstrInfo.h"

#define GET_INSTRINFO_OPERAND_TYPES_ENUM
#include "BBCPUGenInstrInfo.inc"

namespace llvm {

class BBCPUMCCodeEmitter : public MCCodeEmitter {
  const MCInstrInfo *MCII;

public:
  BBCPUMCCodeEmitter(const MCInstrInfo &MCII, MCContext &Ctx);

  uint64_t getBinaryCodeForInstr(const MCInst &MI,
                                 SmallVectorImpl<MCFixup> &Fixups,
                                 const MCSubtargetInfo &STI) const;

  unsigned getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                             SmallVectorImpl<MCFixup> &Fixups,
                             const MCSubtargetInfo &STI) const;

  void encodeInstruction(const MCInst &Inst, SmallVectorImpl<char> &CB,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;
};
} // end namespace llvm

#endif // LLVM_BBCPU_MCCODEEMITTER_H
