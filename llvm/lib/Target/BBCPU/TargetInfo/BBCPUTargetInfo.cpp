//===-- BBCompTargetInfo.cpp - BBCPU Target Implementation -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "BBCPUTargetInfo.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

Target &llvm::getTheBBCPUTarget() {
  static Target theBBCPUTarget;
  return theBBCPUTarget;
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeBBCPUTargetInfo() {
  RegisterTarget<Triple::bbcpu, false> X(
      getTheBBCPUTarget(), "bbcpu",
      "8-bit CPU by KN Breadboard Computing", "BBCPU");
}
