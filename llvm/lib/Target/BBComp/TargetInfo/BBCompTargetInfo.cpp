//===-- BBCompTargetInfo.cpp - BBComp Target Implementation -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "BBCompTargetInfo.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

Target &llvm::getTheBBCompTarget() {
  static Target theBBCompTarget;
  return theBBCompTarget;
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeBBCompTargetInfo() {
  RegisterTarget<Triple::bbcomp, false> X(
      getTheBBCompTarget(), "bbcomp",
      "8-bit CPU by KN Breadboard Computing", "BBComp");
}

// FIXME: Empty stub just so things link correctly
extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeBBCompTargetMC() {}
