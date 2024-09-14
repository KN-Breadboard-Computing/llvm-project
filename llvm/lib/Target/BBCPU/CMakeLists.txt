add_llvm_component_group(BBCPU)

set(LLVM_TARGET_DEFINITIONS BBCPU.td)

tablegen(LLVM BBCPUGenGlobalISel.inc            -gen-global-isel)
tablegen(LLVM BBCPUGenRegisterInfo.inc          -gen-register-info)
tablegen(LLVM BBCPUGenRegisterBank.inc          -gen-register-bank)
tablegen(LLVM BBCPUGenInstrInfo.inc             -gen-instr-info)
tablegen(LLVM BBCPUGenSubtargetInfo.inc         -gen-subtarget)
tablegen(LLVM BBCPUGenMCCodeEmitter.inc         -gen-emitter)
tablegen(LLVM BBCPUGenDAGISel.inc               -gen-dag-isel)
tablegen(LLVM BBCPUGenCallingConv.inc           -gen-callingconv)
tablegen(LLVM BBCPUGenAsmWriter.inc             -gen-asm-writer)
tablegen(LLVM BBCPUGenAsmMatcher.inc            -gen-asm-matcher)
tablegen(LLVM BBCPUGenDisassemblerTable.inc     -gen-disassembler)

add_public_tablegen_target(BBCPUCommonTableGen)

add_llvm_target(BBCPUCodeGen
  BBCPUAsmPrinter.cpp
  BBCPUFrameLowering.cpp
  BBCPUInstrInfo.cpp
  BBCPUISelDAGToDAG.cpp
  BBCPUISelLowering.cpp
  BBCPUMachineFunctionInfo.cpp
  BBCPUMCInstLower.cpp
  BBCPURegisterInfo.cpp
  BBCPUSubtarget.cpp
  BBCPUTargetMachine.cpp
  BBCPUTargetObjectFile.cpp

  LINK_COMPONENTS
  Analysis
  AsmPrinter
  CodeGen
  CodeGenTypes
  Core
  GlobalISel
  BBCPUDesc
  BBCPUInfo
  MC
  SelectionDAG
  Support
  Target

  ADD_TO_COMPONENT
  BBCPU
  )

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
add_subdirectory(AsmParser)
add_subdirectory(Disassembler)
