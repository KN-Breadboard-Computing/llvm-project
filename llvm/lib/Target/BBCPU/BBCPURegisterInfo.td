//===-- BBCPURegisterInfo.td - BBCPU Register defs ---------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the BBCPU register file
//===----------------------------------------------------------------------===//

class BBCPUReg<string name, list<string> alt = []> : Register<name, alt> {
    let Namespace = "BBCPU";
}

class BBCPUSubRegIndex<int size, int offset = 0> : SubRegIndex<size, offset> {
    let Namespace = "BBCPU";
}

def F : BBCPUReg<"f", ["flags"]>, DwarfRegNum<[0]>;
def A : BBCPUReg<"a">, DwarfRegNum<[1]>;
def B : BBCPUReg<"b">, DwarfRegNum<[2]>;

def TL : BBCPUReg<"tl", ["tmpl"]>, DwarfRegNum<[4]>;
def TLSubIndex : BBCPUSubRegIndex<8, 0>;

def TH : BBCPUReg<"th", ["tmph"]>, DwarfRegNum<[5]>;
def THSubIndex : BBCPUSubRegIndex<8, 8>;

def T : BBCPUReg<"t", ["tmp"]> {
    let SubRegs = [ TH, TL ];
    let SubRegIndices = [ THSubIndex, TLSubIndex ];
    let DwarfNumbers = [3];
}

// NOTE: This feels a bit hacky, but simplifies the way instructions are defined
def RA : RegisterClass<"BBCPU", [i8], 8, (add A)> {}
def RB : RegisterClass<"BBCPU", [i8], 8, (add B)> {}

def GPR : RegisterClass<"BBCPU", [i8], 8, (add A, B, TL, TH)> {
}
