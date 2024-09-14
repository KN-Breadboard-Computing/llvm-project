//===---- BBCPUDisassembler.cpp - Parse BBCPU disassembly MCInst instructions ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//#include "BBCPU.h"
#include "MCTargetDesc/BBCPUMCTargetDesc.h"
#include "TargetInfo/BBCPUTargetInfo.h"
#include "llvm/MC/MCDecoderOps.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/MathExtras.h"

#include <cassert>
#include <cstdint>

using namespace llvm;

#define DEBUG_TYPE "bbcpu-disassembler"

typedef MCDisassembler::DecodeStatus DecodeStatus;

namespace {

class BBCPUDisassembler : public MCDisassembler {
public:
  BBCPUDisassembler(const MCSubtargetInfo &STI, MCContext &Ctx)
      : MCDisassembler(STI, Ctx) {}
  ~BBCPUDisassembler() override = default;

  DecodeStatus getInstruction(MCInst &instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &CStream) const override;
};

} // end anonymous namespace

static MCDisassembler *createBBCPUDisassembler(const Target &T,
                                              const MCSubtargetInfo &STI,
                                              MCContext &Ctx) {
  return new BBCPUDisassembler(STI, Ctx);
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeBBCPUDisassembler() {
  // Register the disassembler.
  TargetRegistry::RegisterMCDisassembler(getTheBBCPUTarget(),
                                         createBBCPUDisassembler);
}

static const uint16_t GPRDecoderTable[] = {
    BBCPU::R0,  BBCPU::R1,  BBCPU::R2,  BBCPU::R3,  BBCPU::R4,  BBCPU::R5,
    BBCPU::R6,  BBCPU::R7,  BBCPU::R8,  BBCPU::R9,  BBCPU::R10, BBCPU::R11,
    BBCPU::R12, BBCPU::R13, BBCPU::R14, BBCPU::R15
};

static DecodeStatus decodeGPR16RegisterClass(MCInst &Inst, uint64_t RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  if (RegNo > 15)
    return MCDisassembler::Fail;

  unsigned Register = GPRDecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Register));
  return MCDisassembler::Success;
}

static DecodeStatus decodeGPR32RegisterClass(MCInst &Inst, uint64_t RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  if (RegNo > 15)
    return MCDisassembler::Fail;

  unsigned Register = GPRDecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Register));
  return MCDisassembler::Success;
}

static DecodeStatus decodeGPR64RegisterClass(MCInst &Inst, uint64_t RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  if (RegNo > 15)
    return MCDisassembler::Fail;

  unsigned Register = GPRDecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Register));
  return MCDisassembler::Success;
}

#include "BBCPUGenDisassemblerTable.inc"


DecodeStatus BBCPUDisassembler::getInstruction(MCInst &MI, uint64_t &Size,
                                              ArrayRef<uint8_t> Bytes,
                                              uint64_t Address,
                                              raw_ostream &CS) const {
  // Instruction size is always 16 bit.
  if (Bytes.size() < 2) {
    Size = 0;
    return MCDisassembler::Fail;

  }
  Size = 2;

  // Construct the instruction.
  uint16_t Inst = Bytes[0] | (Bytes[1] << 8);

  if (decodeInstruction(DecoderTableBBCPU16, MI, Inst, Address, this, STI) !=
      MCDisassembler::Success) {
    return MCDisassembler::Fail;
  }
  
  return MCDisassembler::Success;
}