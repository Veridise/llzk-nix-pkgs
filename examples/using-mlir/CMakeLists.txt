cmake_minimum_required(VERSION 3.20)
project(UsingMlirExample)

find_package(MLIR REQUIRED CONFIG)
list(APPEND CMAKE_MODULE_PATH ${MLIR_CMAKE_DIR})
include(AddMLIR)

message(STATUS "MLIR reports tablegen is in: ${MLIR_TABLEGEN_EXE}")
find_program(mlir_tblgen_loc "${MLIR_TABLEGEN_EXE}" REQUIRED)

include(GNUInstallDirs)
install(CODE "message(\"Dummy install target\")")
