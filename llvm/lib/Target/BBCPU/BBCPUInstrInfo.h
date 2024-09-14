//===-- BBCPUInstrInfo.h - BBCPU Instruction Information ----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file contains the BBCPU implementation of the TargetInstrInfo class.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BBCPU_BBCPUINSTRINFO_H
#define LLVM_LIB_TARGET_BBCPU_BBCPUINSTRINFO_H

#include "BBCPU.h"
#include "BBCPURegisterInfo.h"
#include "MCTargetDesc/BBCPUBaseInfo.h"
#include "MCTargetDesc/BBCPUMCTargetDesc.h"

#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "BBCPUGenInstrInfo.inc"

namespace llvm {

class BBCPUSubtarget;

class BBCPUInstrInfo : public BBCPUGenInstrInfo {
  const BBCPURegisterInfo RI;
  
  virtual void anchor();

public:
  explicit BBCPUInstrInfo();

  // Return the BBCPURegisterInfo, which this class owns.
  const BBCPURegisterInfo &getRegisterInfo() const {
    return RI;
  }

  bool expandPostRAPseudo(MachineInstr &MI) const override;

  void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator Position,
                   const DebugLoc &DL, MCRegister DestinationRegister,
                   MCRegister SourceRegister, bool KillSource) const override;
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_BBCPU_BBCPUINSTRINFO_H
