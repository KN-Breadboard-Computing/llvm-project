add_llvm_component_group(BBComp)

add_llvm_target(BBCompCodeGen
        BBCompTargetMachine.cpp

        LINK_COMPONENTS
        BBCompInfo

        ADD_TO_COMPONENT
        BBComp
)

add_subdirectory(TargetInfo)
