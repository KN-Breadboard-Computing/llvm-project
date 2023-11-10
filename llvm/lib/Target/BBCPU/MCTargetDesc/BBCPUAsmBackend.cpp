//===-- BBCPUAsmBackend.cpp - BBCPU Asm Backend  --------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the BBCPUAsmBackend class.
//
//===----------------------------------------------------------------------===//

#include "BBCPUAsmBackend.h"
#include "BBCPUMCTargetDesc.h"

#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"

using namespace llvm;

BBCPUAsmBackend::BBCPUAsmBackend(Triple::OSType OSType)
    : MCAsmBackend(llvm::endianness::little), OSType(OSType) {}

std::unique_ptr<MCObjectTargetWriter>
BBCPUAsmBackend::createObjectTargetWriter() const {
  return createBBCPUELFObjectWriter(MCELFObjectTargetWriter::getOSABI(OSType));
}
unsigned int BBCPUAsmBackend::getNumFixupKinds() const { return 0; }
void BBCPUAsmBackend::applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                                 const MCValue &Target,
                                 MutableArrayRef<char> Data, uint64_t Value,
                                 bool IsResolved,
                                 const MCSubtargetInfo *STI) const {}
bool BBCPUAsmBackend::fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                                           const MCRelaxableFragment *DF,
                                           const MCAsmLayout &Layout) const {
  return false;
}
bool BBCPUAsmBackend::writeNopData(raw_ostream &OS, uint64_t Count,
                                   const MCSubtargetInfo *STI) const {
  // BBCPU `nop` is just 0b00000000, so Count `nop`s is just Count 0 bytes
  OS.write_zeros(Count);
  return true;
}

MCAsmBackend *llvm::createBBCPUMCAsmBackend(const Target &T,
                                            const MCSubtargetInfo &STI,
                                            const MCRegisterInfo &MRI,
                                            const MCTargetOptions &Options) {
  return new BBCPUAsmBackend(STI.getTargetTriple().getOS());
}
