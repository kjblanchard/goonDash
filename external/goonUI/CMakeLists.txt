# #########################################
# Initial config
# #########################################
set(EXECUTABLE_TARGET_NAME SupergoonUIDesigner)
set(LIBRARY_TARGET_NAME SupergoonUI)
cmake_minimum_required(VERSION 3.16)
message(STATUS "Starting ${EXECUTABLE_TARGET_NAME} project initialization")
set(CMAKE_EXPORT_COMPILE_COMMANDS 1) # This exports a file that clangd can use so that we know what compile/include flags so that we can use clangd language server properly with our cmake attributes.
include(FindPkgConfig)
project(${EXECUTABLE_TARGET_NAME} VERSION 0.1.0 LANGUAGES C)
set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/modules")

# #########################################
# File globbing
# #########################################
message(STATUS "Getting all files for cmake..")
file(GLOB_RECURSE LIBRARY_FILES src/GoonUI/src/*.c* src/GoonUI/src/*.h* src/shared/src/*.h* src/shared/src.*.c*)
file(GLOB_RECURSE DESIGNER_FILES src/GoonDesigner/src/*.c* src/GoonDesigner/src/*.h*)

# #########################################
# Platform specific Project setup
# #########################################
message(STATUS "Changing the platform specific settings")

if(EMSCRIPTEN)
    message(STATUS "Configuring Emscripten")
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    set(GOON_ENABLE_TESTING OFF)
elseif(APPLE)
    if(NOT IOS) # MACOS #
        message(STATUS "Configuring Macos")
        set(MACOS ON)
        list(FILTER FILES EXCLUDE REGEX ".*platform/Windows.*$")

        if(CMAKE_GENERATOR STREQUAL "Xcode")
            message(STATUS "Setting Build to Universal Binary")
            set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "" FORCE)
        endif(CMAKE_GENERATOR STREQUAL "Xcode")
    endif(NOT IOS)

# IOS
elseif(WIN32)
    message(STATUS "Configuring Windows")
    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} /c/cmake)
    set(GOON_ENABLE_TESTING OFF)
    list(FILTER FILES EXCLUDE REGEX ".*platform/Mac.*$")
elseif(UNIX AND NOT APPLE)
    message(STATUS "Configuring Linux")
    set(LINUX ON)
endif(EMSCRIPTEN)

# #########################################
# Initialize
# #########################################
message(STATUS "Initializing the project")
add_library(${LIBRARY_TARGET_NAME}
    STATIC
    ${LIBRARY_FILES})
set_property(TARGET ${LIBRARY_TARGET_NAME} PROPERTY C_STANDARD 99)
find_package(PkgConfig REQUIRED)
add_executable(${EXECUTABLE_TARGET_NAME}
    ${DESIGNER_FILES}
)

# #########################################
# Options
# #########################################
option(GOON_BUILD_PCH "Uses a PCH file to try and speed up compilation" ON)
# Should we build shared libs, cmake uses BUILD_SHARED_LIBS for this
set(BUILD_SHARED_LIBS OFF)

# #########################################
# Precompiled headers
# #########################################
if(GOON_BUILD_PCH)
    message(STATUS "Setting up PCH, mac needs objc")
    target_precompile_headers(${LIBRARY_TARGET_NAME} PRIVATE
        "$<$<COMPILE_LANGUAGE:C>:${CMAKE_CURRENT_SOURCE_DIR}/src/shared/src/gnpch.h>")
endif(GOON_BUILD_PCH)

# #########################################
# Build Type specific setup
# #########################################
# Local builds need to find all the packages
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
message(STATUS "Finding Packages")

# 1. Look for a SDL2 package, 2. look for the SDL2 component and 3. fail if none can be found
find_package(SDL2 REQUIRED CONFIG REQUIRED COMPONENTS SDL2)
find_package(SDL2_image
    NAMES SDL2_Image libSDL2_Image SDL2_image libSDL2_image libSDL2_image
    REQUIRED
)
find_package(SDL2_ttf
    NAMES SDL2_ttf libSDL2_ttf SDL2_Ttf libSDL2_Ttf libSDL2_Ttf
    REQUIRED
    CONFIG COMPONENTS SDL2_ttf
    HINTS /usr/local/lib)

# 1. Look for a SDL2 package, 2. Look for the SDL2maincomponent and 3. DO NOT fail when SDL2main is not available
find_package(SDL2 REQUIRED CONFIG COMPONENTS SDL2main)

# Find lua static (non homebrew on mac)
find_library(LIB_LUA
    NAMES liblua_static lua_static liblua_static.a lua_static.a liblua.a
    HINTS /usr/local/lib
    REQUIRED)
set(LUA_LIBRARIES ${LIB_LUA})
else()
endif(CMAKE_BUILD_TYPE STREQUAL "Debug")

# #########################################
# Packages
# #########################################

# #########################################
# Platform Specific Build settings
# #########################################
if(EMSCRIPTEN)
endif(EMSCRIPTEN)

# #########################################
# Compile Definitions
# #########################################

# Platform-specific compile definitions
target_compile_definitions(${LIBRARY_TARGET_NAME} PRIVATE
    $<$<BOOL:${APPLE}>: -DGN_PLATFORM_MACOS>
    $<$<BOOL:${WIN32}>: -DGN_PLATFORM_WINDOWS>
    $<$<BOOL:${EMSCRIPTEN}>: -DGN_PLATFORM_EMSCRIPTEN>
    $<$<BOOL:${LINUX}>: -DGN_PLATFORM_LINUX>
)

# Other compile definitions
target_compile_definitions(${LIBRARY_TARGET_NAME} PRIVATE

    # $<$<BOOL:${GOON_MULTITHREADED_SOUND}>: -DGN_MULTITHREADED>
)

# #########################################
# Debug
# #########################################
if(CMAKE_DEBUG_VARIABLES)
    message(STATUS "Exporting debug")
    get_cmake_property(_variableNames VARIABLES)
    list(SORT _variableNames)

    foreach(_variableName ${_variableNames})
        message(STATUS "${_variableName}=${${_variableName}}")
    endforeach()
endif(CMAKE_DEBUG_VARIABLES)

# #########################################
# Compile Options
# #########################################
set(FULL_COMPILE_OPTIONS
    -Wall
    -Wextra
    -Wpedantic
    -Wdeprecated
    -Wno-newline-eof
    -Wno-strict-prototypes
    -pthread
)

if(WIN32)
    set(FULL_COMPILE_OPTIONS /std:c99)
elseif(EMSCRIPTEN)
    # target_compile_options(${EXECUTABLE_TARGET_NAME} PRIVATE -sUSE_SDL_TTF=2)
endif(WIN32)

target_compile_options(${LIBRARY_TARGET_NAME} PRIVATE ${FULL_COMPILE_OPTIONS})

# #########################################
# Linking Options
# #########################################

# Handle all targets
# SDL2::SDL2main may or may not be available. It is e.g. required by Windows GUI applications
# It has an implicit dependency on SDL2 functions, so it MUST be added before SDL2::SDL2 (or SDL2::SDL2-static)
set(LIBRARIES_TO_LINK
    SDL2::SDL2main
    SDL2::SDL2-static
    # SDL2_image::SDL2_image-static
    SDL2_ttf::SDL2_ttf-static
    ${LUA_LIBRARIES}
    # Lua
)

foreach(LIBRARY ${LIBRARIES_TO_LINK})
    # Check if the target exists, if we are building it then we should link to it.
    if(TARGET ${LIBRARY})
        target_link_libraries(${LIBRARY_TARGET_NAME} PRIVATE ${LIBRARY})
    endif()
endforeach()

target_link_libraries(${EXECUTABLE_TARGET_NAME} PRIVATE ${LIBRARY_TARGET_NAME})

# #########################################
# Include Option
# #########################################
target_include_directories(${LIBRARY_TARGET_NAME}
PUBLIC
/usr/local/include)

target_include_directories(${LIBRARY_TARGET_NAME}
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/
    ${CMAKE_CURRENT_SOURCE_DIR}/src/shared/src
)

# #########################################
# Install
# #########################################
# set(FOLDERS_TO_COPY src/Scripts assets)

# if(MSVC OR CMAKE_GENERATOR STREQUAL "Xcode")
# set(INSTALL_DIR ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$<CONFIG>)
# else()
# set(INSTALL_DIR ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
# endif(MSVC OR CMAKE_GENERATOR STREQUAL "Xcode")

# install(DIRECTORY ${FOLDERS_TO_COPY}
# DESTINATION ${INSTALL_DIR}
# )

# #########################################
# Test