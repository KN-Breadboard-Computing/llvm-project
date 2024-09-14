//===-- BBCPUInstrInfo.cpp - BBCPU instruction information ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the BBCPU implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "BBCPUInstrInfo.h"
#include "BBCPUSubtarget.h"
#include "MCTargetDesc/BBCPUMCTargetDesc.h"
#include "llvm/CodeGen/LiveIntervals.h"
#include "llvm/CodeGen/LiveVariables.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "BBCPUGenInstrInfo.inc"

#define DEBUG_TYPE "bbcpu-ii"

// Pin the vtable to this file.
void BBCPUInstrInfo::anchor() {}

BBCPUInstrInfo::BBCPUInstrInfo()
    : BBCPUGenInstrInfo(), RI() {}

bool BBCPUInstrInfo::expandPostRAPseudo(
    MachineInstr &MI) const {
  MachineBasicBlock &MBB = *MI.getParent();

  switch (MI.getOpcode()) {
  default:
    return false;
  case BBCPU::RET: {
    // MachineInstrBuilder MIB =
    //     BuildMI(MBB, &MI, MI.getDebugLoc(),
    //             get(BBCPU::JMP))
    //         .addReg(BBCPU::R3, RegState::Undef);

    // Retain any imp-use flags.
    // for (auto &MO : MI.operands()) {
    //   if (MO.isImplicit())
    //     MIB.add(MO);
    // }
    break;
  }
  }

  // Erase the pseudo instruction.
  MBB.erase(MI);
  return true;
}

void BBCPUInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator Position,
                                 const DebugLoc &DL,
                                 MCRegister DestinationRegister,
                                 MCRegister SourceRegister,
                                 bool KillSource) const {
  // if (!BBCPU::GPRRegClass.contains(DestinationRegister, SourceRegister)) {
  //   llvm_unreachable("Impossible reg-to-reg copy");
  // }

  // BuildMI(MBB, Position, DL, get(BBCPU::OR_I_LO), DestinationRegister)
  //     .addReg(SourceRegister, getKillRegState(KillSource))
  //     .addImm(0);
}