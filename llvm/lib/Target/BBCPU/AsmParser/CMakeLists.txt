add_llvm_component_library(LLVMBBCPUAsmParser
        BBCPUAsmParser.cpp

        LINK_COMPONENTS
        CodeGenTypes
        BBCPUCodeGen
        BBCPUInfo
        MC
        MCParser
        Support

        ADD_TO_COMPONENT
        BBCPU
  )
