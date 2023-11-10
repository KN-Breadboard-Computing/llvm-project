add_llvm_component_group(BBCPU)

set(LLVM_TARGET_DEFINITIONS BBCPU.td)

tablegen(LLVM BBCPUGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM BBCPUGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM BBCPUGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM BBCPUGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM BBCPUGenMCCodeEmitter.inc -gen-emitter)

add_public_tablegen_target(BBCPUCommonTableGen)

add_llvm_target(BBCPUCodeGen
        BBCPUTargetMachine.cpp
        BBCPURegisterInfo.cpp

        LINK_COMPONENTS
        BBCPUInfo
        BBCPUDesc

        ADD_TO_COMPONENT
        BBCPU
)

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
add_subdirectory(AsmParser)
