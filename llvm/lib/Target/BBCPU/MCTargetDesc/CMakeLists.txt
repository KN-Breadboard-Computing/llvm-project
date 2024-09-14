add_llvm_component_library(LLVMBBCPUDesc
        BBCPUAsmBackend.cpp
        BBCPUELFObjectWriter.cpp
        BBCPUInstPrinter.cpp
        BBCPUMCAsmInfo.cpp
        BBCPUMCCodeEmitter.cpp
        BBCPUMCTargetDesc.cpp

        LINK_COMPONENTS
        MC
        MCDisassembler
        Support
        TargetParser
        BBCPUInfo
      
        ADD_TO_COMPONENT
        BBCPU
  )
