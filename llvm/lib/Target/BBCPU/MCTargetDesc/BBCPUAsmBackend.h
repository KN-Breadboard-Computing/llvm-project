//===-- BBCPUAsmBackend.h - BBCPU Asm Backend------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// \file The BBCPU assembly backend implementation.
//
//===----------------------------------------------------------------------===//
//

#ifndef LLVM_BBCPU_ASM_BACKEND_H
#define LLVM_BBCPU_ASM_BACKEND_H

#include "llvm/MC/MCAsmBackend.h"
#include "llvm/TargetParser/Triple.h"

#include <memory>

namespace llvm {

class BBCPUAsmBackend : public MCAsmBackend {
public:
  BBCPUAsmBackend(Triple::OSType OSType);

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override;

  unsigned int getNumFixupKinds() const override;

  void applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                  const MCValue &Target, MutableArrayRef<char> Data,
                  uint64_t Value, bool IsResolved,
                  const MCSubtargetInfo *STI) const override;

  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *DF,
                            const MCAsmLayout &Layout) const override;

  bool writeNopData(raw_ostream &OS, uint64_t Count,
                    const MCSubtargetInfo *STI) const override;

private:
  Triple::OSType OSType;
};

} // end namespace llvm

#endif // LLVM_BBCPU_ASM_BACKEND_H
