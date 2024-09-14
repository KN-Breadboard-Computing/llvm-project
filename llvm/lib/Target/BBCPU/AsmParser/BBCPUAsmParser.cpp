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
  bool parseMemory(const MCExpr *&Expr, SMLoc &Start, SMLoc &End, bool Inside = false);

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
};

class BBCPUOperand : public MCParsedAsmOperand {
  enum KindTy {
    Immediate,
    Register,
    Memory,
    Token,
    MemZeroPage,
    IndexedReg,
    Stack
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

  BBCPUOperand(unsigned Reg, bool Indexed, const SMLoc &Start, const SMLoc &End)
      : Kind(Indexed ? IndexedReg : Register), RegMemImm{Reg, nullptr}, Start(Start), End(End) {}

  BBCPUOperand(StringRef Tok, const SMLoc &Loc)
      : Kind(Token), Tok(Tok), Start(Loc), End(Loc) {}

  BBCPUOperand(KindTy Kind, const SMLoc &Loc)
      : Kind(Kind), Start(Loc), End(Loc) {}

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
    return std::make_unique<BBCPUOperand>(Reg, false, Start, End);
  }

  static std::unique_ptr<MCParsedAsmOperand>
  createMemZeroPage(const MCExpr *Mem, const SMLoc &Start, const SMLoc &End) {
    return std::make_unique<BBCPUOperand>(Mem, MemZeroPage, Start, End);
  }

  static std::unique_ptr<MCParsedAsmOperand> createIndexedReg(unsigned Reg, const SMLoc &Start, const SMLoc &End) {
    return std::make_unique<BBCPUOperand>(Reg, true, Start, End);
  }

  static std::unique_ptr<MCParsedAsmOperand> createToken(StringRef Tok,
                                                         const SMLoc &Loc) {
    return std::make_unique<BBCPUOperand>(Tok, Loc);
  }

  static std::unique_ptr<MCParsedAsmOperand> createStack(const SMLoc& Loc) {
    return std::make_unique<BBCPUOperand>(Stack, Loc);
  }

  bool isToken() const override { return Kind == Token; }
  bool isImm() const override { return Kind == Immediate; }
  bool isReg() const override { return Kind == Register; }
  bool isMem() const override { return Kind == Memory; }
  bool isMemZeroPage() const { return Kind == MemZeroPage; }
  bool isIndexedReg() const { return Kind == IndexedReg; }
  template<int Reg> bool isIndexedRegOf() {
    return isIndexedReg() && RegMemImm.Reg == Reg;
  }
  bool isStack() const { return Kind == Stack; };

  const MCExpr *getExpr() const {
    assert((Kind == Immediate || Kind == Memory || Kind == MemZeroPage) && "Unexpected operand kind");
    return RegMemImm.MemImm;
  }

  unsigned int getReg() const override {
    assert((Kind == Register || Kind == IndexedReg) && "Unexpected operand kind");
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
    case MemZeroPage:
      OS << "Memory Zero Page: \"";
      getExpr()->print(OS, nullptr);
      OS << "\"";
      break;
    case IndexedReg:
      OS << "IndexedReg: " << getReg();
      break;
    case Stack:
      OS << "Stack";
      break;
    }
  }

  void addRegOperands(MCInst &Inst, unsigned N) const {
    assert(Kind == Register && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands");

    addRegLikeOperands(Inst, N);
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

    addMemLikeOperands(Inst, N);
  }

  void addMemZeroPageOperands(MCInst &Inst, unsigned N) const {
    assert(Kind == MemZeroPage && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands");

    addMemLikeOperands(Inst, N);
  }

  void addIndexedRegOperands(MCInst &Inst, unsigned N) const {
    assert(Kind == IndexedReg && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands");
    addRegLikeOperands(Inst, N);
  }

  void addStackOperands(MCInst &Inst, unsigned N) {
    assert(Kind == Stack && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands");
    // add a dummy operand, so that number of operands checks out
    Inst.addOperand(MCOperand::createImm(0));
  }

  bool isBrTarget() { isToken(); }

  bool isCallTarget() { return isImm() || isToken(); }

private:
  void addMemLikeOperands(MCInst &Inst, unsigned N) const {
    assert((Kind == Memory || Kind == MemZeroPage) && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands");

    const MCExpr *Expr = getExpr();
    if (!Expr)
      Inst.addOperand(MCOperand::createImm(0));
    else if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Expr))
      Inst.addOperand(MCOperand::createImm(CE->getValue()));
    else
      Inst.addOperand(MCOperand::createExpr(Expr));
  }

  void addRegLikeOperands(MCInst& Inst, unsigned N) const {
    assert((Kind == IndexedReg || Kind == Register) && "Unexpected operand kind");
    assert(N == 1 && "Invalid number of operands");

    Inst.addOperand(MCOperand::createReg(getReg()));
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
                                 llvm::SMLoc &End, bool Inside) {
  if (Inside || getLexer().is(AsmToken::LBrac)) {
    SMLoc LBLoc = getLexer().getLoc();
    if (!Inside) getLexer().Lex(); // eat `[`

    Start = getLexer().getLoc();
    const llvm::MCExpr *Seg;
    if (getParser().parseExpression(Seg, End) || !Expr)
      return Error(getLexer().getLoc(), "expected an expression",
                   SMRange(LBLoc, getLexer().getLoc()));

    if (getLexer().isNot(AsmToken::Colon)) {
      if (parseToken(AsmToken::RBrac, "expected `]`"))
        return true;

      Expr = Seg;
      return false;
    }

    const MCConstantExpr *CSeg = dyn_cast<MCConstantExpr>(Seg);
    if (!CSeg)
      return Error(getLexer().getLoc(), "expected a constant",
                   SMRange(LBLoc, getLexer().getLoc()));

    if (CSeg->getValue() != 0)
      return Error(getLexer().getLoc(), "expected page `0`",
                   SMRange(LBLoc, getLexer().getLoc()));

    if (parseToken(AsmToken::Colon, "expected `:`"))
      return true;

    if (getParser().parseExpression(Expr, End))
      return Error(getLexer().getLoc(), "expected address expression",
                   SMRange(LBLoc, getLexer().getLoc()));

    if (parseToken(AsmToken::RBrac, "expected `]`"))
      return true;

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
  const MCExpr* Expr;

  if (getLexer().is(AsmToken::LBrac)) {
    Lex();

    if (!parseRegister(Reg, Start, End)) {
      Lex();

      if (parseToken(AsmToken::RBrac, "expected closing `]`"))
        return true;

      End = getLexer().getLoc();

      Operands.push_back(BBCPUOperand::createIndexedReg(Reg, Start, End));
      return false;
    }

    if (!parseMemory(Expr, Start, End, true)) {
      Operands.push_back(BBCPUOperand::createMem(Expr, Start, End));
      return false;
    }

    End = getLexer().getLoc();
    return Error(Start, "expected register or memory", SMRange(Start, End));
  }

  if (getLexer().is(AsmToken::Less)) {
    Lex();

    AsmToken Tok = getTok();
    StringRef S;
    if (getParser().parseIdentifier(S))
      return true;

    if (!S.equals("stack"))
      return Error(Tok.getLoc(), "expected `stack`", Tok.getLocRange());

    if (parseToken(AsmToken::Greater, "expected closing `<`"))
      return true;

    Operands.push_back(BBCPUOperand::createStack(Tok.getLoc()));
    return false;
  }

  if (!parseRegister(Reg, Start, End)) {
    Lex();
    End = getLexer().getLoc();

    Operands.push_back(BBCPUOperand::createReg(Reg, Start, End));
    return false;
  }

  if (!getParser().parseExpression(Expr, End)) {
    Operands.push_back(BBCPUOperand::createImm(Expr, Start, End));
    return false;
  }

  End = getLexer().getLoc();
  return Error(getLexer().getLoc(), "expected an operand", SMRange(Start, End));
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeBBCPUAsmParser() {
  RegisterMCAsmParser<BBCPUAsmParser> X(getTheBBCPUTarget());
}