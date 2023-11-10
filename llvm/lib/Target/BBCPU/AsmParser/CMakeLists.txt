add_llvm_component_library(LLVMBBCPUAsmParser
        BBCPUAsmParser.cpp

        LINK_COMPONENTS
        BBCPUInfo

        ADD_TO_COMPONENT
        BBCPU
)