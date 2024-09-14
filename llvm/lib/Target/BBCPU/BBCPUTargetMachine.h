//===-- BBCPUTargetMachine.h - Define TargetMachine for BBCPU -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file declares the BBCPU specific subclass of TargetMachine.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BBCPU_BBCPUTARGETMACHINE_H
#define LLVM_LIB_TARGET_BBCPU_BBCPUTARGETMACHINE_H

#include "BBCPUSubtarget.h"
#include "BBCPUISelLowering.h"
#include "BBCPUInstrInfo.h"
#include "BBCPUMachineFunctionInfo.h"

#include "llvm/Target/TargetLoweringObjectFile.h"
#include "llvm/Target/TargetMachine.h"

#include <optional>

namespace llvm {

class BBCPUTargetMachine : public LLVMTargetMachine {
  BBCPUSubtarget Subtarget;
  std::unique_ptr<TargetLoweringObjectFile> TLOF;

  mutable StringMap<std::unique_ptr<BBCPUSubtarget>> SubtargetMap;

public:
  BBCPUTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                    StringRef FS, const TargetOptions &Options,
                    std::optional<Reloc::Model> RM,
                    std::optional<CodeModel::Model> CM, CodeGenOptLevel OL,
                    bool JIT);

  ~BBCPUTargetMachine() override;

  const BBCPUSubtarget *getSubtargetImpl() const { return &Subtarget; }

  const BBCPUSubtarget *getSubtargetImpl(const Function &F) const override;

  // Pass Pipeline Configuration
  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;

  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }

  MachineFunctionInfo *
  createMachineFunctionInfo(BumpPtrAllocator &Allocator, const Function &F,
                            const TargetSubtargetInfo *STI) const override;

  bool isMachineVerifierClean() const override {
    return false;
  }
};
} // namespace llvm

#endif // LLVM_LIB_TARGET_BBCPU_BBCPUTARGETMACHINE_H
