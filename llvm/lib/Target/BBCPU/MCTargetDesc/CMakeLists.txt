add_llvm_component_library(LLVMBBCPUDesc
        BBCPUAsmBackend.cpp
        BBCPUMCAsmInfo.cpp
        BBCPUMCTargetDesc.cpp
        BBCPUELFObjectWriter.cpp
        BBCPUMCCodeEmitter.cpp

        LINK_COMPONENTS
        BBCPUInfo

        ADD_TO_COMPONENT
        BBCPU
)
