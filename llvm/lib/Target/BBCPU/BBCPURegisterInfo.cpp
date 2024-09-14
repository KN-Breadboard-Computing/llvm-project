//===-- BBCPURegisterInfo.cpp - BBCPU Register Information
//------------------===//
//
// Part of the LLVM Project, under the Apache License
// v2.0 with LLVM Exceptions. See
// https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH
// LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the BBCPU implementation of the
// TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "BBCPURegisterInfo.h"
#include "BBCPUFrameLowering.h"
#include "BBCPUInstrInfo.h"
#include "MCTargetDesc/BBCPUMCTargetDesc.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/Register.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/MC/MCRegister.h"

using namespace llvm;

#define GET_REGINFO_TARGET_DESC
#include "BBCPUGenRegisterInfo.inc"

BBCPURegisterInfo::BBCPURegisterInfo() : BBCPUGenRegisterInfo(BBCPU::RCA) {}

const MCPhysReg *BBCPURegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_SaveList;
}

BitVector BBCPURegisterInfo::getReservedRegs(
    const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());

  Reserved.set(BBCPU::R0);
  Reserved.set(BBCPU::ZERO);
  Reserved.set(BBCPU::R1);
  Reserved.set(BBCPU::SP_LOW);
  Reserved.set(BBCPU::R2);
  Reserved.set(BBCPU::SP_HIGH);
  Reserved.set(BBCPU::R3);
  Reserved.set(BBCPU::FP);
  Reserved.set(BBCPU::R4);
  Reserved.set(BBCPU::RR1);
  Reserved.set(BBCPU::R5);
  Reserved.set(BBCPU::RR2);
  Reserved.set(BBCPU::R6);
  Reserved.set(BBCPU::RR3);
  Reserved.set(BBCPU::R7);
  Reserved.set(BBCPU::RV);
  Reserved.set(BBCPU::R15);
  Reserved.set(BBCPU::RCA);

  if (hasBasePointer(MF)) {
    Reserved.set(getBaseRegister());
  }

  return Reserved;
}

bool BBCPURegisterInfo::requiresRegisterScavenging(const MachineFunction & MF) const {
  return true;
}

bool BBCPURegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator MI, int SPAdj,
                                            unsigned FIOperandNum, RegScavenger *RS) const {
  return false;
}

bool BBCPURegisterInfo::hasBasePointer(const MachineFunction &MF) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  // When we need stack realignment and there are dynamic allocas, we can't
  // reference off of the stack pointer, so we reserve a base pointer.
  if (hasStackRealignment(MF) && MFI.hasVarSizedObjects())
    return true;

  return false;
}

unsigned BBCPURegisterInfo::getRARegister() const { return BBCPU::RCA; }

Register
BBCPURegisterInfo::getFrameRegister(const MachineFunction & MF) const {
  return BBCPU::FP;
}

Register BBCPURegisterInfo::getBaseRegister() const { return BBCPU::R14; }

const uint32_t *
BBCPURegisterInfo::getCallPreservedMask(const MachineFunction & MF, CallingConv::ID CC) const {
  return CSR_RegMask;
}
