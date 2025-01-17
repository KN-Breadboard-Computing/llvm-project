# KN Breadboard Computer LLVM
Welcome to the KN Breadboard Computer fork of LLVM!

This repository contains the source code for 16-bit BBCPU LLVM backend. 
As of 7 Feb. 2024 it only contains code for generating object files from native assembly.
However, the goal is to eventually get other LLVM tools to work (with the ultimate goal being compiling C code with 
Clang for BBCPU).

Currently, there are no plans of upstreaming backend in this fork.

Please consult [Docs](llvm/docs/KNBBC/README.md) for information specific to this fork.

Rest of the upstream README follows...

# The LLVM Compiler Infrastructure

[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/llvm/llvm-project/badge)](https://securityscorecards.dev/viewer/?uri=github.com/llvm/llvm-project)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/8273/badge)](https://www.bestpractices.dev/projects/8273)
[![libc++](https://github.com/llvm/llvm-project/actions/workflows/libcxx-build-and-test.yaml/badge.svg?branch=main&event=schedule)](https://github.com/llvm/llvm-project/actions/workflows/libcxx-build-and-test.yaml?query=event%3Aschedule)

Welcome to the LLVM project!

This repository contains the source code for LLVM, a toolkit for the
construction of highly optimized compilers, optimizers, and run-time
environments.

The LLVM project has multiple components. The core of the project is
itself called "LLVM". This contains all of the tools, libraries, and header
files needed to process intermediate representations and convert them into
object files. Tools include an assembler, disassembler, bitcode analyzer, and
bitcode optimizer.

C-like languages use the [Clang](http://clang.llvm.org/) frontend. This
component compiles C, C++, Objective-C, and Objective-C++ code into LLVM bitcode
-- and from there into object files, using LLVM.

Other components include:
the [libc++ C++ standard library](https://libcxx.llvm.org),
the [LLD linker](https://lld.llvm.org), and more.

## Getting the Source Code and Building LLVM

Consult the
[Getting Started with LLVM](https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm)
page for information on building and running LLVM.

For information on how to contribute to the LLVM project, please take a look at
the [Contributing to LLVM](https://llvm.org/docs/Contributing.html) guide.

### Build
```
mkdir llvm/build
cd llvm/build
cmake -G "Ninja" -DLLVM_TARGETS_TO_BUILD="BBCPU" -DCMAKE_BUILD_TYPE=Release ../
cmake --build .
```

### Test
#### Assemble
```
echo 'and r1,r2,r3' | bin/llvm-mc --triple bbcpu --show-encoding
```

#### Disassemble
```
echo '0x53,0x20' | bin/llvm-mc --triple bbcpu -disassemble
```

#### Compile
```
echo 'define i16 @f1(i16 %a, i16 %b) {
    %res = and i16 %a, %b
ret i16 %res
}' | bin/llc -mtriple bbcpu
```

## Getting in touch

Join the [LLVM Discourse forums](https://discourse.llvm.org/), [Discord
chat](https://discord.gg/xS7Z362),
[LLVM Office Hours](https://llvm.org/docs/GettingInvolved.html#office-hours) or
[Regular sync-ups](https://llvm.org/docs/GettingInvolved.html#online-sync-ups).

The LLVM project has adopted a [code of conduct](https://llvm.org/docs/CodeOfConduct.html) for
participants to all modes of communication within the project.
