//===-- BBCPUMCAsmInfo.cpp - BBCPU asm properties -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the declarations of the BBCPUMCAsmInfo properties.
//
//===----------------------------------------------------------------------===//
#include "BBCPUMCAsmInfo.h"

using namespace llvm;

BBCPUMCAsmInfo::BBCPUMCAsmInfo(const llvm::Triple &TT,
                               const llvm::MCTargetOptions &Options) {
  CalleeSaveStackSlotSize = CodePointerSize = 2;
  CommentString = ";";
  SeparatorString = "$";
  PrivateGlobalPrefix = ".L";
  PrivateLabelPrefix = ".L";
  UsesELFSectionDirectiveForBSS = true;
  SupportsDebugInformation = true;
}
