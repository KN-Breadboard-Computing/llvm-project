//===---- AVRAsmParser.cpp - Parse AVR assembly to MCInst instructions ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "BBCPURegisterInfo.h"
#include "MCTargetDesc/BBCPUMCTargetDesc.h"
#include "TargetInfo/BBCPUTargetInfo.h"

#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCParser/MCAsmLexer.h"
#include "llvm/MC/MCParser/MCAsmParser.h"
#include "llvm/MC/MCParser/MCTargetAsmParser.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "bbcpu-asm-parser"

using namespace llvm;

namespace {
class BBCPUAsmParser : public MCTargetAsmParser {
  MCAsmParser *Parser;

  bool emit(MCInst &Inst, const SMLoc &Loc, MCStreamer &Out);
  bool missingFeature(const SMLoc &Loc, uint64_t &ErrorInfo);
  bool invalidOperand(const SMLoc &Loc, OperandVector &Operands,
                      uint64_t &ErrorInfo);
  int parseRegister();
  bool parseOperand(OperandVector &Operands);
  bool parseImmediate(const MCExpr *&Expr, SMLoc &Start, SMLoc &End);
  bool parseMemory(const MCExpr *&Expr, SMLoc &Start, SMLoc &End);

public:
  BBCPUAsmParser(const MCSubtargetInfo &STI, MCAsmParser &P,
                 const MCInstrInfo &MII, const MCTargetOptions &Options);

#define GET_ASSEMBLER_HEADER
#include "BBCPUGenAsmMatcher.inc"

  bool parseRegister(MCRegister &Reg, SMLoc &StartLoc, SMLoc &EndLoc) override;

  ParseStatus tryParseRegister(MCRegister &Reg, SMLoc &StartLoc,
                               SMLoc &EndLoc) override;

  bool ParseInstruction(ParseInstructionInfo &Info, StringRef Name,
                        SMLoc NameLoc, OperandVector &Operands) override;

  bool MatchAndEmitInstruction(SMLoc IDLoc, unsigned int &Opcode,
                               OperandVector &Operands, MCStreamer &Out,
                               uint64_t &ErrorInfo,
                               bool MatchingInlineAsm) override;

  void onBeginOfFile() override;
};

class BBCPUOperand : public MCParsedAsmOperand {
  enum KindTy {
    Immediate,
    Register,
    Memory,
    Token,
  } Kind;

  struct RegisterMemImm {
    unsigned Reg;
    MCExpr const *MemImm;
  };

  union {
    RegisterMemImm RegMemImm;
    StringRef Tok;
  };

  SMLoc Start, End;

public:
  BBCPUOperand(const MCExpr *Imm, KindTy Kind, const SMLoc &Start,
               const SMLoc &End)
      : Kind(Kind), RegMemImm{0, Imm}, Start(Start), End(End) {}

  BBCPUOperand(unsigned Reg, const SMLoc &Start, const SMLoc &End)
      : Kind(Register), RegMemImm{Reg, nullptr}, Start(Start), End(End) {}

  BBCPUOperand(StringRef Tok, const SMLoc &Loc)
      : Kind(Token), Tok(Tok), Start(Loc), End(Loc) {}

  static std::unique_ptr<MCParsedAsmOperand>
  createImm(const MCExpr *Imm, const SMLoc &Start, const SMLoc &End) {
    return std::make_unique<BBCPUOperand>(Imm, Immediate, Start, End);
  }

  static std::unique_ptr<MCParsedAsmOperand>
  createMem(const MCExpr *Mem, const SMLoc &Start, const SMLoc &End) {
    return std::make_unique<BBCPUOperand>(Mem, Memory, Start, End);
  }

  static std::unique_ptr<MCParsedAsmOperand>
  createReg(unsigned Reg, const SMLoc &Start, const SMLoc &End) {
    return std::make_unique<BBCPUOperand>(Reg, Start, End);
  }

  static std::unique_ptr<MCParsedAsmOperand> createToken(StringRef Tok,
                                                         const SMLoc &Loc) {
    return std::make_unique<BBCPUOperand>(Tok, Loc);
  }

  bool isToken() const override { return Kind == Token; }
  bool isImm() const override { return Kind == Immediate; }
  bool isReg() const override { return Kind == Register; }
  bool isMem() const override { return Kind == Memory; }

  const MCExpr *getExpr() const {
    assert((Kind == Immediate || Kind == Memory) && "Unexpected operand kind");
    return RegMemImm.MemImm;
  }

  unsigned int getReg() const override {
    assert(Kind == Register && "Unexpected operand kind");
    return RegMemImm.Reg;
  }

  StringRef getToken() const {
    assert(Kind == Token && "Unexpected token kind");
    return Tok;
  }

  SMLoc getStartLoc() const override { return Start; }

  SMLoc getEndLoc() const override { return End; }

  void print(raw_ostream &OS) const override {
    switch (Kind) {
    case Token:
      OS << "Token: \"" << Tok << "\"";
      break;
    case Register:
      OS << "Register: " << getReg();
      break;
    case Immediate:
      OS << "Immediate: \"";
      getExpr()->print(OS, nullptr);
      OS << "\"";
      break;
    case Memory:
      OS << "Memory: \"";
      getExpr()->print(OS, nullptr);
      OS << "\"";
      break;
    }
  }

  void addRegOperands(MCInst &Inst, unsigned N) const {
    assert(Kind == Register && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands");

    Inst.addOperand(MCOperand::createReg(getReg()));
  }

  void addImmOperands(MCInst &Inst, unsigned N) const {
    assert(Kind == Immediate && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands");

    const MCExpr *Expr = getExpr();
    if (!Expr)
      Inst.addOperand(MCOperand::createImm(0));
    else if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Expr))
      Inst.addOperand(MCOperand::createImm(CE->getValue()));
    else
      Inst.addOperand(MCOperand::createExpr(Expr));
  }

  void addMemOperands(MCInst &Inst, unsigned N) const {
    assert(Kind == Memory && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands");

    const MCExpr *Expr = getExpr();
    if (!Expr)
      Inst.addOperand(MCOperand::createImm(0));
    else if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Expr))
      Inst.addOperand(MCOperand::createImm(CE->getValue()));
    else
      Inst.addOperand(MCOperand::createExpr(Expr));
  }
};

} // end namespace

#define GET_REGISTER_MATCHER
#define GET_MATCHER_IMPLEMENTATION
#include "BBCPUGenAsmMatcher.inc"

BBCPUAsmParser::BBCPUAsmParser(const MCSubtargetInfo &STI, MCAsmParser &P,
                               const MCInstrInfo &MII,
                               const MCTargetOptions &Options)
    : MCTargetAsmParser(Options, STI, MII), Parser(&P) {}

int BBCPUAsmParser::parseRegister() {
  int Reg = BBCPU::NoRegister;

  if (getParser().getTok().is(AsmToken::Identifier)) {
    StringRef ID = getParser().getTok().getString();
    Reg = MatchRegisterName(ID);

    if (Reg == BBCPU::NoRegister) {
      Reg = MatchRegisterAltName(ID);
    }
  }

  return Reg;
}

bool BBCPUAsmParser::parseRegister(MCRegister &Reg, SMLoc &StartLoc,
                                   SMLoc &EndLoc) {
  StartLoc = Parser->getTok().getLoc();
  Reg = parseRegister();
  EndLoc = Parser->getTok().getLoc();

  return Reg == BBCPU::NoRegister;
}

ParseStatus BBCPUAsmParser::tryParseRegister(MCRegister &Reg, SMLoc &StartLoc,
                                             SMLoc &EndLoc) {
  StartLoc = Parser->getTok().getLoc();
  Reg = parseRegister();
  EndLoc = Parser->getTok().getLoc();

  if (Reg == BBCPU::NoRegister)
    return ParseStatus::Failure;

  return ParseStatus::Success;
}

bool BBCPUAsmParser::parseImmediate(const MCExpr *&Expr, SMLoc &Start,
                                    SMLoc &End) {
  LLVM_DEBUG(dbgs() << "Got token kind = " << getParser().getTok().getKind()
                    << ", tok = " << getParser().getTok().getString() << '\n');

  Start = getLexer().getLoc();
  return getParser().parseExpression(Expr, End);
}

bool BBCPUAsmParser::parseMemory(const llvm::MCExpr *&Expr, llvm::SMLoc &Start,
                                 llvm::SMLoc &End) {
  if (getLexer().is(AsmToken::LBrac)) {
    SMLoc LBLoc = getLexer().getLoc();
    getLexer().Lex(); // Eat opening `[`

    Start = getLexer().getLoc();
    if (getParser().parseExpression(Expr, End))
      return true;

    if (getLexer().isNot(AsmToken::RBrac))
      return Error(getLexer().getLoc(), "expected closing `]`",
                   SMRange(LBLoc, getLexer().getLoc()));

    getLexer().Lex(); // Eat closing `]`
    return false;
  }

  return false;
}

bool BBCPUAsmParser::ParseInstruction(ParseInstructionInfo &Info,
                                      StringRef Name, SMLoc NameLoc,
                                      OperandVector &Operands) {
  LLVM_DEBUG(dbgs() << "ParseInstruction called with Name = `" << Name
                    << "`!\n");

  Operands.push_back(BBCPUOperand::createToken(Name, NameLoc));

  if (getLexer().is(AsmToken::EndOfStatement))
    return false;

  if (parseOperand(Operands))
    return true;

  while (getLexer().is(AsmToken::Comma)) {
    getLexer().Lex();

    if (parseOperand(Operands))
      return true;
  }

  if (getLexer().isNot(AsmToken::EndOfStatement)) {
    SMLoc Loc = getLexer().getLoc();
    getParser().eatToEndOfStatement();
    return Error(Loc, "unexpected token");
  }

  getLexer().Lex();
  return false;
}

bool BBCPUAsmParser::MatchAndEmitInstruction(SMLoc IDLoc, unsigned int &Opcode,
                                             OperandVector &Operands,
                                             MCStreamer &Out,
                                             uint64_t &ErrorInfo,
                                             bool MatchingInlineAsm) {
  MCInst Inst;
  unsigned MatchResult =
      MatchInstructionImpl(Operands, Inst, ErrorInfo, MatchingInlineAsm);

  switch (MatchResult) {
  case Match_Success:
    return emit(Inst, IDLoc, Out);
  case Match_InvalidOperand:
    return invalidOperand(IDLoc, Operands, ErrorInfo);
  case Match_MnemonicFail:
    return Error(IDLoc, "invalid instruction");
  default:
    LLVM_DEBUG(dbgs() << "MatchResult = " << MatchResult << '\n');
    return true;
  }
}

bool BBCPUAsmParser::emit(MCInst &Inst, const SMLoc &Loc, MCStreamer &Out) {
  Inst.setLoc(Loc);
  Out.emitInstruction(Inst, *STI);

  return false;
}

bool BBCPUAsmParser::missingFeature(const SMLoc &Loc, uint64_t &ErrorInfo) {
  return Error(Loc, "instruction requires a CPU feature not currently enabled");
}

bool BBCPUAsmParser::invalidOperand(const SMLoc &Loc, OperandVector &Operands,
                                    uint64_t &ErrorInfo) {
  return Error(Loc, "invalid operand for instruction");
}

bool BBCPUAsmParser::parseOperand(OperandVector &Operands) {
  LLVM_DEBUG(dbgs() << "Parsing operands\n");

  SMLoc Start;
  SMLoc End;

  MCRegister Reg;
  if (!parseRegister(Reg, Start, End)) {
    getLexer().Lex(); // eat the register token
    LLVM_DEBUG(dbgs() << "Parsed register operand reg = " << Reg << '\n');
    Operands.push_back(BBCPUOperand::createReg(Reg, Start, End));
    return false;
  }

  const MCExpr *Imm;
  if (getLexer().is(AsmToken::LBrac)) {
    if (!parseImmediate(Imm, Start, End)) {
      LLVM_DEBUG(dbgs() << "Parsed immediate memory address operand imm = "
                        << Imm << '\n');
      Operands.push_back(BBCPUOperand::createMem(Imm, Start, End));
      return false;
    }
  }

  if (!parseImmediate(Imm, Start, End)) {
    LLVM_DEBUG(dbgs() << "Parsed immediate operand imm = " << Imm << '\n');
    Operands.push_back(BBCPUOperand::createImm(Imm, Start, End));
    return false;
  }

  return Error(getParser().getTok().getLoc(),
               "expected register, immediate or memory reference");
}

void BBCPUAsmParser::onBeginOfFile() {
  getParser().setShowParsedOperands(true);
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeBBCPUAsmParser() {
  RegisterMCAsmParser<BBCPUAsmParser> X(getTheBBCPUTarget());
}
