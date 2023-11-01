//===-- BBCPUTargetMachine.h - Define TargetMachine for BBCPU ---*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares the BBCPU specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_BBCPU_TARGET_MACHINE_H
#define LLVM_BBCPU_TARGET_MACHINE_H

#include "llvm/Target/TargetMachine.h"

namespace llvm {
class BBCPUTargetMachine : LLVMTargetMachine {
  BBCPUTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                      StringRef FS, const TargetOptions &Options,
                      std::optional<Reloc::Model> RM,
                      std::optional<CodeModel::Model> CM, CodeGenOptLevel OL);
};
} // end namespace llvm
#endif // LLVM_BBCPU_TARGET_MACHINE_H
