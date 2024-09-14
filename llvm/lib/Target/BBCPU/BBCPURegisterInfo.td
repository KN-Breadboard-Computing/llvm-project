//===-- BBCPURegisterInfo.td - BBCPU Register defs ---------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//  Declarations that describe the BBCPU register file
//===----------------------------------------------------------------------===//

class BBCPUReg<bits<4> enc, string n, list<Register> subregs = []>
    : Register<n> {
    
    let HWEncoding{15-4} = 0;
    let HWEncoding{3-0} = enc;
    let SubRegs = subregs;
    let Namespace = "BBCPU";
}

class BBCPURegisterClass<list<ValueType> types, int size, int alignment, dag regList, int copycost = 1>
    : RegisterClass<"BBCPU", types, alignment, regList> {
      
    let Size = size;
    let CopyCost = copycost;
}

class BBCPURegisterOperand<RegisterClass RC>
    : RegisterOperand<RC> {
    
    let DecoderMethod = "decode"#RC#"RegisterClass";
}

let Namespace = "BBCPU" in {
    def sub_hi_hi : SubRegIndex<16, 0>;
    def sub_hi_lo : SubRegIndex<16, 16>;
    def sub_lo_hi : SubRegIndex<16, 32>;
    def sub_lo_lo : SubRegIndex<16, 48>;
}

// Integer registers
foreach I = 0-15 in {
    def R#I : BBCPUReg<I, "r"#I>, DwarfRegNum<[I]>;
}

// Register aliases
let SubRegIndices = [sub_hi_hi] in {
    def ZERO      : BBCPUReg<0,  "zero", [R0]>,  DwarfRegAlias<R0>;
    def SP_LOW    : BBCPUReg<1,  "spl",  [R1]>,  DwarfRegAlias<R1>;
    def SP_HIGH   : BBCPUReg<2,  "sph",  [R2]>,  DwarfRegAlias<R2>;
    def FP        : BBCPUReg<3,  "fp",   [R3]>,  DwarfRegAlias<R3>;
    def RR1       : BBCPUReg<4,  "rr1",  [R5]>,  DwarfRegAlias<R4>;
    def RR2       : BBCPUReg<5,  "rr2",  [R6]>,  DwarfRegAlias<R5>;
    def RR3       : BBCPUReg<6,  "rr3",  [R7]>,  DwarfRegAlias<R6>;
    def RV        : BBCPUReg<4,  "rv",   [R8]>,  DwarfRegAlias<R8>;
    def RCA       : BBCPUReg<15, "rca",  [R15]>, DwarfRegAlias<R15>;
}

// Status register
def SR : BBCPUReg< 0, "sw">;

// Condition code register class
def CCR : RegisterClass<"BBCPU", [i16], 16, (add SR)> {
  let CopyCost = -1; // Don't allow copying of status registers
  let isAllocatable = 0;
}

// Register classes.
def GPR16 : BBCPURegisterClass<[i16], 16, 16,
    (add
     R15, RCA,                          // return call address
     R14,
     R11, R12, R13,                     // registers for passing arguments  
     R8, R9, R10,                       // free for bigger return types
     R7, RV,                            // return value
     R6, RR3,                           // programmer controlled registers
     R5, RR2,                           // programmer controlled registers
     R4, RR1,                           // programmer controlled registers
     R3, FP,                            // frame pointer
     R2, SP_HIGH,                       // stack pointer - high byte
     R1, SP_LOW,                        // stack pointer - low byte
     R0, ZERO                           // constant 0
    ), 1>;

def GPR16Low : BBCPURegisterClass<[i16], 16, 16,
    (add (sequence "R%u", 0, 7, 1)), 1>;

def GRPair : RegisterTuples<[sub_hi_hi, sub_hi_lo],
                            [(add (sequence "R%u", 4, 14, 2)),
                             (add (sequence "R%u", 5, 15, 2))]>;

def GRQuad : RegisterTuples<[sub_hi_hi, sub_hi_lo, sub_lo_hi, sub_lo_lo],
                            [(add (sequence "R%u", 4, 12, 4)),
                             (add (sequence "R%u", 5, 13, 4)),
                             (add (sequence "R%u", 6, 14, 4)),
                             (add (sequence "R%u", 7, 15, 4))]>;

def GPR32 : BBCPURegisterClass<[i32, f32, v4i8, v2i16], 32, 15,
                              (add GRPair), 2>;

def GPR64 : BBCPURegisterClass<[i64, f64, v8i8, v4i16, v2i32], 64, 16,
                              (add GRQuad), 4>;

def GPR16Opnd    : BBCPURegisterOperand<GPR16> { let GIZeroRegister = R0; }
def GPR16LowOpnd : BBCPURegisterOperand<GPR16> { let GIZeroRegister = R0; }
def GPR32Opnd    : BBCPURegisterOperand<GPR32>;
def GPR64Opnd    : BBCPURegisterOperand<GPR64>;