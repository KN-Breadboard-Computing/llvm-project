add_llvm_component_library(LLVMBBCPUDisassembler
    BBCPUDisassembler.cpp

    LINK_COMPONENTS
    CodeGenTypes
    BBCPUDesc
    BBCPUInfo
    MCDisassembler
    Support

    ADD_TO_COMPONENT
    BBCPU
)

