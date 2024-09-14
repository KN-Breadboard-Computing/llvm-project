//===-- BBCPUAsmPrinter.h - BBCPU LLVM Assembly Printer -----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// This file contains BBCPU assembler printer declarations.
///
//===----------------------------------------------------------------------===//


#ifndef LLVM_LIB_TARGET_BBCPU_BBCPUASMPRINTER_H
#define LLVM_LIB_TARGET_BBCPU_BBCPUASMPRINTER_H

#include "BBCPUMCInstLower.h"
#include "BBCPUTargetMachine.h"
#include "MCTargetDesc/BBCPUMemOperandPrinter.h"

#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Target/TargetMachine.h"
#include <memory>
#include <utility>

namespace llvm {
class MCStreamer;
class MachineInstr;
class MachineBasicBlock;
class Module;
class raw_ostream;

class BBCPUSubtarget;
class BBCPUMachineFunctionInfo;

class LLVM_LIBRARY_VISIBILITY BBCPUAsmPrinter
    : public AsmPrinter,
      public BBCPUMemOperandPrinter<BBCPUAsmPrinter, MachineInstr> {

  friend class BBCPUMemOperandPrinter;

  void EmitInstrWithMacroNoAT(const MachineInstr *MI);

  void printOperand(const MachineInstr *MI, int OpNum, raw_ostream &OS);

  void printDisp(const MachineInstr *MI, unsigned OpNum, raw_ostream &OS);
  void printAbsMem(const MachineInstr *MI, unsigned OpNum, raw_ostream &OS);

public:
  const BBCPUSubtarget *Subtarget;
  const BBCPUMachineFunctionInfo *MMFI;
  std::unique_ptr<BBCPUMCInstLower> MCInstLowering;

  explicit BBCPUAsmPrinter(TargetMachine &TM,
                          std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {
    Subtarget = static_cast<BBCPUTargetMachine &>(TM).getSubtargetImpl();
  }

  StringRef getPassName() const override { return "BBCPU Assembly Printer"; }

  virtual bool runOnMachineFunction(MachineFunction &MF) override;

  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       const char *ExtraCode, raw_ostream &OS) override;
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                             const char *ExtraCode, raw_ostream &OS) override;

  void emitInstruction(const MachineInstr *MI) override;
  void emitFunctionBodyStart() override;
  void emitFunctionBodyEnd() override;
  void emitStartOfAsmFile(Module &M) override;
  void emitEndOfAsmFile(Module &M) override;
};
} // namespace llvm

#endif // LLVM_LIB_TARGET_BBCPU_BBCPUASMPRINTER_H