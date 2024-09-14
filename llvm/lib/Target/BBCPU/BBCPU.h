//===-- BBCPU.h - Top-level interface for BBCPU representation ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file contains the entry points for global functions defined in the
/// BBCPU target library, as used by the LLVM JIT.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BBCPU_BBCPU_H
#define LLVM_LIB_TARGET_BBCPU_BBCPU_H

#include "llvm/Pass.h"

namespace llvm {

class FunctionPass;
class InstructionSelector;
class BBCPURegisterBankInfo;
class BBCPUTargetMachine;
class BBCPUSubtarget;
class PassRegistry;

/// This pass converts a legalized DAG into a BBCPU-specific DAG, ready for
/// instruction scheduling.
FunctionPass *createBBCPUISelDag(BBCPUTargetMachine &TM);

InstructionSelector *
createBBCPUInstructionSelector(const BBCPUTargetMachine &, const BBCPUSubtarget &,
                              const BBCPURegisterBankInfo &);

void initializeBBCPUDAGToDAGISelPass(PassRegistry &);

} // namespace llvm

#endif // LLVM_LIB_TARGET_BBCPU_BBCPU_H
