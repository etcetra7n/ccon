cmake_minimum_required(VERSION 3.31.0)
project(ccon
    VERSION 1.2.0
    LANGUAGES CXX
)
set(CMAKE_CXX_STANDARD 17)
set(SOURCES
    src/ErrorExit.h
    src/ErrorExit.cpp
    src/main.cpp
)
add_executable(ccon WIN32 ${SOURCES})