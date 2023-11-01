add_llvm_component_group(BBCPU)

add_llvm_target(BBCPUCodeGen
        BBCPUTargetMachine.cpp

        LINK_COMPONENTS
        BBCPUInfo

        ADD_TO_COMPONENT
        BBCPU
)

add_subdirectory(TargetInfo)
