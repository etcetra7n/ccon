cmake_minimum_required(VERSION 3.1.0)
project(ccon
    VERSION 1.0.0
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 14)
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++14 /W4 /link /subsystem:windows /entry:mainCRTStartup")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -Wall -Wextra -Wpedantic -mwindows")
endif()

set(SOURCES
    ccon.cpp
)

add_executable(ccon ${SOURCES})

install(
    TARGETS ccon
    RUNTIME DESTINATION bin
)
