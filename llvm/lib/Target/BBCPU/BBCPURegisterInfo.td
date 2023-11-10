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

def F : BBCPUReg<"f", ["flags"]>, DwarfRegNum<[0]>;
def A : BBCPUReg<"a">, DwarfRegNum<[1]>;
def B : BBCPUReg<"b">, DwarfRegNum<[2]>;

// NOTE: This feels a bit hacky, but simplifies the way instructions are defined
def RA : RegisterClass<"BBCPU", [i8], 8, (add A)> {}
def RB : RegisterClass<"BBCPU", [i8], 8, (add B)> {}

def GPR : RegisterClass<"BBCPU", [i8], 8, (add A, B)> {
}
