//===- BBCPUCallingConv.td - Calling Conventions BBCPU -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This describes the calling conventions for the BBCPU architectures.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Return Value Calling Conventions
//===----------------------------------------------------------------------===//

// BBCPU 16-bit C Calling convention.
def CC_BBCPU16 : CallingConv<[
  // Promote i8 args to i16
  CCIfType<[i8], CCPromoteToType<i16>>,

  CCIfSRet<CCIfType<[i16], CCAssignToReg<[RV]>>>,

  // Registers are used for passing parameters.
  CCIfType<[i16], CCAssignToReg<[R11, R12, R13, R14]>>,

  // Otherwise they are assigned to the stack in 2-byte aligned units.
  CCAssignToStack<2, 2>
]>;

// BBCPU 16-bit Fast Calling convention.
def CC_BBCPU16_Fast : CallingConv<[
  // Promote i8 args to i16
  CCIfType<[i8], CCPromoteToType<i16>>,

  CCIfSRet<CCIfType<[i16], CCAssignToReg<[RV]>>>,

  // Registers are used for passing parameters.
  CCIfType<[i16], CCAssignToReg<[R11, R12, R13, R14]>>,

  // Otherwise they are assigned to the stack in 4-byte aligned units.
  CCAssignToStack<2, 2>
]>;

// BBCPU 16-bit C return-value convention.
def RetCC_BBCPU16 : CallingConv<[
  // Specify two registers to allow returning 16-bit results that have already
  // been lowered to 2 16-bit values.
  CCIfType<[i16], CCAssignToReg<[RV]>>,
  CCIfType<[i32], CCAssignToReg<[RV, R8]>>,
  CCIfType<[i64], CCAssignToReg<[RV, R8, R9, R10]>>
]>;

def CSR: CalleeSavedRegs<(add)>;
