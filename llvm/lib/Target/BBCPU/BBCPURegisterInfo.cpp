//===-- BBCPURegisterInfo.cpp - BBCPU Register Information ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the BBCPU implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "BBCPURegisterInfo.h"

#define GET_REGINFO_TARGET_DESC
#include "BBCompGenRegisterInfo.inc"

using namespace llvm;

BBCPURegisterInfo::BBCPURegisterInfo() : BBCPUGenRegisterInfo(0) {}
