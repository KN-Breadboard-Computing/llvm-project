//===-- BBCPUMCAsmInfo.h - BBCPU asm properties -----------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the BBCPUMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_BBCOMP_ASM_INFO_H
#define LLVM_BBCOMP_ASM_INFO_H

#include "llvm/MC/MCAsmInfo.h"

namespace llvm {

class Triple;

class BBCPUMCAsmInfo : public MCAsmInfo {
public:
  explicit BBCPUMCAsmInfo(const Triple &TT, const MCTargetOptions &Options);
};
} // end namespace llvm

#endif // LLVM_BBCOMP_ASM_INFO_H
