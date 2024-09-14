//===-- BBCPUMemOperandPrinter.h - Memory operands printing ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file contains memory operand printing logics shared between AsmPrinter
//  and MCInstPrinter.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BBCPU_MEMOPERANDPRINTER_BBCPUINSTPRINTER_H
#define LLVM_LIB_TARGET_BBCPU_MEMOPERANDPRINTER_BBCPUINSTPRINTER_H

#include "BBCPUBaseInfo.h"

#include "llvm/Support/raw_ostream.h"

namespace llvm {
template <class Derived, typename InstTy> class BBCPUMemOperandPrinter {
  Derived &impl() { return *static_cast<Derived *>(this); }

// protected:
 
};
} // end namespace llvm
#endif
