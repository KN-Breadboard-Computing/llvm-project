add_llvm_component_library(LLVMBBCPUInfo
    BBCPUTargetInfo.cpp

    LINK_COMPONENTS
    MC
    Support

    ADD_TO_COMPONENT
    BBCPU
)
