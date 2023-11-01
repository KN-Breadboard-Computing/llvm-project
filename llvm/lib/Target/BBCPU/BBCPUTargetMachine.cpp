//===-- BBCPUTargetMachine.cpp - Define TargetMachine for BBCPU -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the BBCPU specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#include "BBCPUTargetMachine.h"
#include "TargetInfo/BBCPUTargetInfo.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

static const char *BBCompDataLayout =
    "e-p:16:8-i8:8-i16:8-i32:8-i64:8-f32:8-f64:8-n8-a:8";

extern "C" void LLVMInitializeBBCompTarget() {
  RegisterTargetMachine<BBCompTargetMachine> X(getTheBBCPUTarget());
}

static Reloc::Model getEffectiveRelocModel(std::optional<Reloc::Model> RM) {
  return RM.value_or(Reloc::Static);
}

BBCPUTargetMachine::BBCPUTargetMachine(
    const llvm::Target &T, const llvm::Triple &TT, llvm::StringRef CPU,
    llvm::StringRef FS, const llvm::TargetOptions &Options,
    std::optional<Reloc::Model> RM, std::optional<CodeModel::Model> CM,
    llvm::CodeGenOptLevel OL)
    : LLVMTargetMachine(T, BBCompDataLayout, TT, CPU, FS, Options,
                        getEffectiveRelocModel(RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL) {
  initAsmInfo();
}
