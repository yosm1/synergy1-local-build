# App-local MSVC runtime fallback when Build Tools has no CRT merge modules.
# This runs only for our MSI invocation, after CPack has staged application files.
if(NOT CPACK_TEMPORARY_INSTALL_DIRECTORY)
  message(FATAL_ERROR "CPack staging directory is not defined")
endif()
if(NOT DEFINED ENV{VCToolsRedistDir})
  message(FATAL_ERROR "Load the MSVC developer environment before packaging")
endif()
file(GLOB _crt_files "$ENV{VCToolsRedistDir}/x64/Microsoft.VC*.CRT/*.dll")
if(NOT _crt_files)
  message(FATAL_ERROR "MSVC x64 redistributable DLLs were not found")
endif()
file(COPY ${_crt_files} DESTINATION "${CPACK_TEMPORARY_INSTALL_DIRECTORY}")
include("${CMAKE_CURRENT_LIST_DIR}/package-notices.cmake")
