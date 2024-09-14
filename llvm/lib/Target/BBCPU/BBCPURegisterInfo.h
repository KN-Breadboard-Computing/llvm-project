//===-- BBCPURegisterInfo.h - BBCPU Register Information Impl ---*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_BBCPU_BBCPUREGISTERINFO_H
#define LLVM_LIB_TARGET_BBCPU_BBCPUREGISTERINFO_H

#include "BBCPU.h"

#include "llvm/CodeGen/TargetRegisterInfo.h"

#define GET_REGINFO_HEADER
#include "BBCPUGenRegisterInfo.inc"

namespace llvm {

class BBCPURegisterInfo : public BBCPUGenRegisterInfo {
public:
  BBCPURegisterInfo();

  const uint32_t *getCallPreservedMask(const MachineFunction &MF,
                                       CallingConv::ID) const override;

  /// Code Generation virtual methods...
  const MCPhysReg *getCalleeSavedRegs(const MachineFunction *MF) const override;

  BitVector getReservedRegs(const MachineFunction &MF) const override;

  bool requiresRegisterScavenging(const MachineFunction &MF) const override;

  bool eliminateFrameIndex(MachineBasicBlock::iterator II, int SPAdj,
      unsigned FIOperandNum, RegScavenger *RS = nullptr) const override;

  // Debug information queries.
  unsigned getRARegister() const;
  Register getFrameRegister(const MachineFunction &MF) const override;
  Register getBaseRegister() const;
  bool hasBasePointer(const MachineFunction &MF) const;

  int getDwarfRegNum(unsigned RegNum, bool IsEH) const;
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_BBCPU_BBCPUREGISTERINFO_H
