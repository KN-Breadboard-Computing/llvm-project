//===-- BBCPUELFObjectWriter.cpp - BBCPU ELF Writer -----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "BBCPUMCTargetDesc.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCValue.h"

namespace llvm {
class BBCPUELFObjectWriter : public MCELFObjectTargetWriter {
public:
  BBCPUELFObjectWriter(uint8_t OSABI);

  unsigned int getRelocType(MCContext &Ctx, const MCValue &Target,
                            const MCFixup &Fixup, bool IsPCRel) const override;
};

BBCPUELFObjectWriter::BBCPUELFObjectWriter(uint8_t OSABI)
    : MCELFObjectTargetWriter(false, OSABI, ELF::EM_BBCPU, false) {}

unsigned int BBCPUELFObjectWriter::getRelocType(MCContext &Ctx,
                                                const MCValue &Target,
                                                const MCFixup &Fixup,
                                                bool IsPCRel) const {
  const unsigned Kind = Fixup.getTargetKind();
  if (Kind >= FirstLiteralRelocationKind)
    return Kind - FirstLiteralRelocationKind;

  MCSymbolRefExpr::VariantKind Modifier = Target.getAccessVariant();

  switch (Modifier) {
  default:
    llvm_unreachable("unsupported modifier");
  case MCSymbolRefExpr::VK_None:
    switch ((unsigned)Kind) {
    default:
      llvm_unreachable("invalid fixup kind!");
    case FK_NONE:
      return ELF::R_BBCPU_NONE;
    case FK_Data_1:
      return ELF::R_BBCPU_8;
    case FK_Data_2:
      return ELF::R_BBCPU_16;
    }
  }
}
} // end namespace llvm

using namespace llvm;

std::unique_ptr<MCObjectTargetWriter>
llvm::createBBCPUELFObjectWriter(uint8_t OSABI) {
  return std::make_unique<BBCPUELFObjectWriter>(OSABI);
}
