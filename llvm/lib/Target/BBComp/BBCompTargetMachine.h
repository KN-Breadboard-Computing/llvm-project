//===-- BBCompTargetMachine.h - Define TargetMachine for BBComp -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares the BBComp specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BBCOMP_BBCOMPTARGETMACHINE_H
#define LLVM_LIB_TARGET_BBCOMP_BBCOMPTARGETMACHINE_H

#include "llvm/Target/TargetMachine.h"

namespace llvm {
class BBCompTargetMachine : LLVMTargetMachine {
  BBCompTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                      StringRef FS, const TargetOptions &Options,
                      std::optional<Reloc::Model> RM,
                      std::optional<CodeModel::Model> CM, CodeGenOptLevel OL);
};
} // end namespace llvm
#endif
