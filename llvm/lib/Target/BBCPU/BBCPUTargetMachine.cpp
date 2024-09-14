//===-- BBCPUTargetMachine.cpp - BBCPU Target Machine -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file contains implementation for BBCPU target machine.
///
//===----------------------------------------------------------------------===//

#include "BBCPUTargetMachine.h"
#include "BBCPU.h"
#include "BBCPUSubtarget.h"
#include "BBCPUTargetObjectFile.h"
#include "TargetInfo/BBCPUTargetInfo.h"
#include "llvm/CodeGen/GlobalISel/IRTranslator.h"
#include "llvm/CodeGen/GlobalISel/InstructionSelect.h"
#include "llvm/CodeGen/GlobalISel/Legalizer.h"
#include "llvm/CodeGen/GlobalISel/RegBankSelect.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/InitializePasses.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/PassRegistry.h"
#include <memory>
#include <optional>

using namespace llvm;

#define DEBUG_TYPE "bbcpu"

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeBBCPUTarget() {
  RegisterTargetMachine<BBCPUTargetMachine> X(getTheBBCPUTarget());
  auto *PR = PassRegistry::getPassRegistry();
  initializeBBCPUDAGToDAGISelPass(*PR);
}

namespace {

std::string computeDataLayout() {
  std::string Ret = "";
  Ret += "e";               // little endian
  Ret += "-p:32:16:32";     // 32-bit pointer, 16-bit alignment

  Ret += "-i8:8:8";         // 8-bit integers are 16-bit aligned
  Ret += "-i16:16:16";      // 16-bit integers are 16-bit aligned
  Ret += "-i32:16:32";      // 32-bit integers are 16-bit aligned
  Ret += "-i64:16:64";      // 64-bit integers are 16-bit aligned

  Ret += "-a:8:16";         // 16-bit address space, 16-bit alignment
  Ret += "-n16";            // 16-bit native register width

  return Ret;
}
} // end anonymous namespace

static Reloc::Model getEffectiveRelocModel(std::optional<Reloc::Model> RM) {
  return RM.value_or(Reloc::PIC_);
}

BBCPUTargetMachine::BBCPUTargetMachine(const Target &T, const Triple &TT,
                                     StringRef CPU, StringRef FS,
                                     const TargetOptions &Options,
                                     std::optional<Reloc::Model> RM,
                                     std::optional<CodeModel::Model> CM,
                                     CodeGenOptLevel OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(), TT, CPU, FS,
                        Options, getEffectiveRelocModel(RM),
                        getEffectiveCodeModel(CM, CodeModel::Medium), OL),
      Subtarget(TT, CPU, FS, *this, Options, getCodeModel(), OL),
      TLOF(std::make_unique<BBCPUELFTargetObjectFile>()) {
  initAsmInfo();
}

BBCPUTargetMachine::~BBCPUTargetMachine() {}

MachineFunctionInfo *BBCPUTargetMachine::createMachineFunctionInfo(
    BumpPtrAllocator &Allocator, const Function &F,
    const TargetSubtargetInfo *STI) const {
  return BBCPUMachineFunctionInfo::create<BBCPUMachineFunctionInfo>(Allocator,
                                                                    F, STI);
}

const BBCPUSubtarget *
BBCPUTargetMachine::getSubtargetImpl(const Function &F) const {
  return &Subtarget;
}

//===----------------------------------------------------------------------===//
// Pass Pipeline Configuration
//===----------------------------------------------------------------------===//

namespace {
class BBCPUPassConfig : public TargetPassConfig {
public:
  BBCPUPassConfig(BBCPUTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  BBCPUTargetMachine &getBBCPUTargetMachine() const {
    return getTM<BBCPUTargetMachine>();
  }

  const BBCPUSubtarget &getBBCPUSubtarget() const {
    return *getBBCPUTargetMachine().getSubtargetImpl();
  }

  bool addInstSelector() override;
  void addPreEmitPass() override;

  bool addIRTranslator() override;
  bool addLegalizeMachineIR() override;
  bool addRegBankSelect() override;
  bool addGlobalInstructionSelect() override;
};
} // namespace

TargetPassConfig *BBCPUTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new BBCPUPassConfig(*this, PM);
}

bool BBCPUPassConfig::addInstSelector() {
  addPass(createBBCPUISelDag(getTM<BBCPUTargetMachine>()));
  return false;
}

void BBCPUPassConfig::addPreEmitPass() {
  // TODO Add pass for div-by-zero check.
}

// Global ISEL
bool BBCPUPassConfig::addIRTranslator() {
  addPass(new IRTranslator());
  return false;
}

bool BBCPUPassConfig::addLegalizeMachineIR() {
  addPass(new Legalizer());
  return false;
}

bool BBCPUPassConfig::addRegBankSelect() {
  addPass(new RegBankSelect());
  return false;
}

bool BBCPUPassConfig::addGlobalInstructionSelect() {
  addPass(new InstructionSelect(getOptLevel()));
  return false;
}
