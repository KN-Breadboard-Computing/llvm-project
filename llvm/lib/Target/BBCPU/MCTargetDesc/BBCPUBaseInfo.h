//===-- BBCPUBaseInfo.h - Top level definitions for BBCPU MC ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file contains small standalone helper functions and enum definitions
/// for the BBCPU target useful for the compiler back-end and the MC
/// libraries.  As such, it deliberately does not include references to LLVM
/// core code gen types, passes, etc..
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BBCPU_MCTARGETDESC_BBCPUBASEINFO_H
#define LLVM_LIB_TARGET_BBCPU_MCTARGETDESC_BBCPUBASEINFO_H

#include "BBCPUMCTargetDesc.h"

#include "llvm/MC/MCExpr.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/ErrorHandling.h"

#define GET_INSTRINFO_MI_OPS_INFO
#define GET_INSTRINFO_OPERAND_TYPES_ENUM
#define GET_INSTRINFO_LOGICAL_OPERAND_SIZE_MAP
#include "BBCPUGenInstrInfo.inc"

namespace llvm {

namespace BBCPU {

} // namespace BBCPU

} // namespace llvm

#endif // LLVM_LIB_TARGET_BBCPU_MCTARGETDESC_BBCPUBASEINFO_H
