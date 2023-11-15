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

#include "BBCPUMCCodeEmitter.h"
#include "BBCPUMCTargetDesc.h"

#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/EndianStream.h"

#define GET_INSTRMAP_INFO
#include "BBCPUGenInstrInfo.inc"

#define DEBUG_TYPE "mccodeemitter"

using namespace llvm;

BBCPUMCCodeEmitter::BBCPUMCCodeEmitter(const llvm::MCInstrInfo &MCII,
                                       llvm::MCContext &Ctx)
    : MCII(&MCII) {}

void BBCPUMCCodeEmitter::encodeInstruction(
    const llvm::MCInst &Inst, llvm::SmallVectorImpl<char> &CB,
    llvm::SmallVectorImpl<llvm::MCFixup> &Fixups,
    const llvm::MCSubtargetInfo &STI) const {
  LLVM_DEBUG(dbgs() << "Encoding instruction inst = " << Inst << '\n');

  const MCInstrDesc &ID = MCII->get(Inst.getOpcode());
  unsigned Size = ID.getSize();

  assert(Size > 0 && "Instruction size cannot be zero");

  uint64_t BinaryOpCode = getBinaryCodeForInstr(Inst, Fixups, STI);
  LLVM_DEBUG(dbgs() << "Encoding instruction BinaryOpCode = " << BinaryOpCode
                    << ", Size = " << Size << '\n');

  for (int64_t i = 0; i < Size; ++i) {
    uint8_t Byte = (BinaryOpCode >> (i * 8)) & 0xFF;
    support::endian::write(CB, Byte, llvm::endianness::little);
  }
}

template <MCFixupKind Fixup, uint32_t Offset>
uint64_t encodeImm(const MCInst &MI, unsigned int OpNo,
                   SmallVectorImpl<llvm::MCFixup> &Fixups,
                   const MCSubtargetInfo &STI) {
  const MCOperand &Op = MI.getOperand(OpNo);

  // If Op is just a constant simply emit it
  if (Op.isImm()) {
    return Op.getImm();
  }

  // If Op is an expression fill whatever it occupies with 0 and create a fixup
  // that will fill in the slot later
  if (Op.isExpr()) {
    Fixups.push_back(MCFixup::create(Offset, Op.getExpr(), Fixup));
    return 0;
  }

  llvm_unreachable("unexpected operand kind");
}

MCCodeEmitter *llvm::createBBCPUMCCodeEmitter(const llvm::MCInstrInfo &MCII,
                                              llvm::MCContext &Ctx) {
  return new BBCPUMCCodeEmitter(MCII, Ctx);
}

#include "BBCPUGenMCCodeEmitter.inc"
