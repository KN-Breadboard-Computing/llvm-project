//===-- BBCPUELFTargetObjectFile.h - BBCPU Object Info ------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file contains declarations for BBCPU ELF object file lowering.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BBCPU_BBCPUTARGETOBJECTFILE_H
#define LLVM_LIB_TARGET_BBCPU_BBCPUTARGETOBJECTFILE_H

#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

namespace llvm {
class BBCPUTargetMachine;
class BBCPUELFTargetObjectFile : public TargetLoweringObjectFileELF {
  const BBCPUTargetMachine *TM;
  MCSection *SmallDataSection;
  MCSection *SmallBSSSection;

public:
  void Initialize(MCContext &Ctx, const TargetMachine &TM) override;
};
} // end namespace llvm

#endif // LLVM_LIB_TARGET_BBCPU_BBCPUTARGETOBJECTFILE_H
