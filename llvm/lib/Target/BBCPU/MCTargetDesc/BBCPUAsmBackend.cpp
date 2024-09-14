//===-- BBCPUAsmBackend.cpp - BBCPU Assembler Backend -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file contains definitions for BBCPU assembler backend.
///
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/BBCPUBaseInfo.h"

#include "llvm/ADT/StringSwitch.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/BinaryFormat/MachO.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCMachObjectWriter.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSectionCOFF.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/MC/MCSectionMachO.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {

class BBCPUAsmBackend : public MCAsmBackend {

public:
  BBCPUAsmBackend(const Target &T) : MCAsmBackend(llvm::endianness::big) {}

  unsigned getNumFixupKinds() const override { return 0; }

  void applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                  const MCValue &Target, MutableArrayRef<char> Data,
                  uint64_t Value, bool IsResolved,
                  const MCSubtargetInfo *STI) const override {
    // No work to do since, when Fixup is added its target slot is filled with 0s
    if (Value == 0)
      return;

    const MCFixupKindInfo &Info = MCAsmBackend::getFixupKindInfo(Fixup.getKind());
    Value <<= Info.TargetOffset;

    unsigned int Size = (Info.TargetSize / 8);
    unsigned int Offset = Fixup.getOffset();
    assert(Size + Offset <= Data.size() && "invalid fixup offset");

    for (unsigned int i = (Info.TargetOffset / 8); i < Size; i++) {
      Data[Offset + i] |= (Value >> (i * 8)) & 0xFF;
    }
  }

  bool mayNeedRelaxation(const MCInst &Inst,
                         const MCSubtargetInfo &STI) const override;

  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *DF,
                            const MCAsmLayout &Layout) const override;

  void relaxInstruction(MCInst &Inst,
                        const MCSubtargetInfo &STI) const override;

  /// Returns the minimum size of a nop in bytes on this target. The assembler
  /// will use this to emit excess padding in situations where the padding
  /// required for simple alignment would be less than the minimum nop size.
  unsigned getMinimumNopSize() const override { return 2; }

  /// Write a sequence of optimal nops to the output, covering \p Count bytes.
  /// \return - true on success, false on failure
  bool writeNopData(raw_ostream &OS, uint64_t Count,
                    const MCSubtargetInfo *STI) const override;
};
} // end anonymous namespace


bool BBCPUAsmBackend::mayNeedRelaxation(const MCInst &Inst,
                                       const MCSubtargetInfo &STI) const {

  return false;
}

bool BBCPUAsmBackend::fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                                          const MCRelaxableFragment *DF,
                                          const MCAsmLayout &Layout) const {
  return false;
}

// NOTE Can tblgen help at all here to verify there aren't other instructions
// we can relax?
void BBCPUAsmBackend::relaxInstruction(MCInst &Inst,
                                      const MCSubtargetInfo &STI) const {
}

bool BBCPUAsmBackend::writeNopData(raw_ostream &OS, uint64_t Count,
                                  const MCSubtargetInfo *STI) const {
  for (size_t i = 0; i < Count; i++) {
    OS.write(0xD4);
  }

  return true;
}

namespace {

class BBCPUELFAsmBackend : public BBCPUAsmBackend {
public:
  uint8_t OSABI;
  BBCPUELFAsmBackend(const Target &T, uint8_t OSABI)
      : BBCPUAsmBackend(T), OSABI(OSABI) {}

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override {
    return createBBCPUELFObjectWriter(OSABI);
  }
};

} // end anonymous namespace

MCAsmBackend *llvm::createBBCPUAsmBackend(const Target &T,
                                         const MCSubtargetInfo &STI,
                                         const MCRegisterInfo &MRI,
                                         const MCTargetOptions &Options) {
  const Triple &TheTriple = STI.getTargetTriple();
  uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(TheTriple.getOS());
  return new BBCPUELFAsmBackend(T, OSABI);
}
