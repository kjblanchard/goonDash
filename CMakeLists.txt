# #########################################
# Initial config
# #########################################
cmake_minimum_required(VERSION 3.16)
message(STATUS "Starting Goon Dash project initialization")
set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# This exports a file that clangd can use so that we know what compile/include flags so that we can use clangd language server properly with our cmake attributes.
message(STATUS "Project initializing")
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)
include(FindPkgConfig)
project(goonDash
    VERSION 0.1.0
    LANGUAGES C)

# #########################################
# File globbing
# #########################################
message(STATUS "Getting all files for cmake..")
file(GLOB_RECURSE FILES src/*.c* src/*.h*)

# #########################################
# Platform specific Project setup
# #########################################
message(STATUS "Changing the platform specific settings")

if(EMSCRIPTEN)
    message(STATUS "Configuring Emscripten")
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    set(GOON_ENABLE_TESTING OFF)
elseif(APPLE)
    # MACOS
    if(NOT IOS)
        message(STATUS "Configuring Macos")
        set(MACOS ON)
        list(FILTER FILES EXCLUDE REGEX ".*platform/Windows.*$")

        if(CMAKE_GENERATOR STREQUAL "Xcode")
            message(STATUS "Setting Build to Universal Binary")
            set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "" FORCE)
        endif(CMAKE_GENERATOR STREQUAL "Xcode")
    endif(NOT IOS)
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

add_executable(SupergoonDash
    ${FILES})

# Using 11 instead of 99 for forward declaring typedef
set_property(TARGET SupergoonDash PROPERTY C_STANDARD 11)
find_package(PkgConfig REQUIRED)
include(CTest)

# #########################################
# Options
# #########################################
option(CMAKE_DEBUG_VARIABLES "Runs a debug on all variables for troubleshooting" ON)
option(GOON_BUILD_PCH "Uses a PCH file to try and speed up compilation" ON)
option(GOON_DEBUG_LUA "Includes socket so that we can debug lua remotely" OFF)
option(GOON_MULTITHREADED_SOUND "Adds multithreaded support for sound updates, experimental and has a memory leak somehow" OFF)
option(GOON_BENCHMARKING "Enables benchmarking functions, adds overhead" OFF)

# option(GOON_FULL_MACOS_BUILD "Full builds of all libraries, used for runners mostly, and passed in to override." OFF)
option(GOON_BUILD_TESTING "Should we enable testing" ON)
set(BUILD_TESTING GOON_BUILD_TESTING)

# #########################################
# Packages
# #########################################
# Most dev is done here, so to speed up builds don't rebuild all packages, must have them installed.
if(MACOS AND NOT GOON_FULL_MACOS_BUILD)
    # 1. Look for a SDL2 package, 2. look for the SDL2 component and 3. fail if none can be found
    find_package(SDL2 REQUIRED CONFIG REQUIRED COMPONENTS SDL2)
    find_package(SDL2_image

        NAMES SDL2_Image libSDL2_Image SDL2_image libSDL2_image libSDL2_image
        CONFIG COMPONENTS SDL2_image
        HINTS /usr/local/lib)

    find_package(SDL2_ttf

        NAMES SDL2_ttf libSDL2_ttf SDL2_Ttf libSDL2_Ttf libSDL2_Ttf
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

    # Disable this for now so that we always build it.
    # find_library(LIB_GOONPHYSICS
    # NAMES libgoonphysics.a libgoonPhysics.a
    # HINTS /usr/local/lib
    # REQUIRED)
    # set(GOONPHYSICS_LIBRARIES ${LIB_GOONPHYSICS})
    add_subdirectory(./external/goonPhysics)

    if(GOON_DEBUG_LUA)
        find_library(LIB_SOCKET
            NAMES socket-3.0.0.so

            # HINTS /Users/kevin/git/lua/luasocket/build/lib/lua/5.4/socket
            PATHS /Users/kevin/git/lua/luasocket/build/lib/lua/5.4/socket
            REQUIRED)
    endif(GOON_DEBUG_LUA)

    add_subdirectory(./external/sg_sound)

# Build everything, useful for runners, and builds we don't care take a little longer.
else()
    find_package(Git REQUIRED QUIET)
    message(STATUS "Cloning and updating submodules")

    if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE GIT_SUBMOD_RESULT)

        if(NOT GIT_SUBMOD_RESULT EQUAL "0")
            message(FATAL_ERROR "git submodule update --init --recursive failed with ${GIT_SUBMOD_RESULT}, please checkout submodules")
        endif()

        add_subdirectory(./external/SDL EXCLUDE_FROM_ALL)
        add_subdirectory(./external/SDL_image EXCLUDE_FROM_ALL)
        add_subdirectory(./external/SDL_ttf EXCLUDE_FROM_ALL)
        add_subdirectory(./external/Lua EXCLUDE_FROM_ALL)
        add_subdirectory(./external/sg_sound)
        add_subdirectory(./external/goonPhysics)

        target_link_libraries(SupergoonDash PRIVATE lua_static goonPhysics)
    else()
        message(STATUS "Could not init git for some reason")
    endif()
endif(MACOS AND NOT GOON_FULL_MACOS_BUILD)

# #########################################
# Compile Definitions
# #########################################
if(APPLE)
    target_compile_definitions(SupergoonDash PRIVATE -DGN_PLATFORM_MACOS)

    if(GOON_MULTITHREADED_SOUND)
        target_compile_definitions(SupergoonDash PRIVATE -DGN_MULTITHREADED)
    endif(GOON_MULTITHREADED_SOUND)
elseif(WIN32)
    target_compile_definitions(SupergoonDash PRIVATE -DGN_PLATFORM_WINDOWS)
elseif(EMSCRIPTEN)
elseif(LINUX)
    target_compile_definitions(SupergoonDash PRIVATE -DGN_PLATFORM_LINUX)

    if(GOON_MULTITHREADED_SOUND)
        target_compile_definitions(SupergoonDash PRIVATE -DGN_MULTITHREADED)
    endif(GOON_MULTITHREADED_SOUND)
endif(APPLE)

if(GOON_DEBUG_LUA)
    target_compile_definitions(SupergoonDash PRIVATE -DGN_DEBUG_LUA)
endif(GOON_DEBUG_LUA)

if(GOON_BENCHMARKING)
    target_compile_definitions(SupergoonDash PRIVATE -DGN_BENCHMARKING_ENABLED)
endif(GOON_BENCHMARKING)

# #########################################
# Precompiled headers
# #########################################
if(GOON_BUILD_PCH)
    message(STATUS "Setting up PCH, mac needs objc")
    target_precompile_headers(SupergoonDash PRIVATE
        "$<$<COMPILE_LANGUAGE:C>:${CMAKE_CURRENT_SOURCE_DIR}/src/GoonDash/gnpch.h>")
endif(GOON_BUILD_PCH)

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

# PROPERTIES
if(EMSCRIPTEN)
    # Use this for pthreads in emscripten when ready
    # set_target_properties(SupergoonDash PROPERTIES LINK_FLAGS ${LINK_FLAGS} "-O0 -g -s USE_PTHREADS=1 -sPTHREAD_POOL_SIZE=2 -s SAFE_HEAP=1 -pthread -s STACK_OVERFLOW_CHECK=1 --preload-file ${CMAKE_SOURCE_DIR}/assets@/assets --preload-file ${CMAKE_SOURCE_DIR}/src/Scripts@/Scripts")
    # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread -sPTHREAD_POOL_SIZE=2 -s USE_PTHREADS=1 -s 'DEFAULT_LIBRARY_FUNCS_TO_INCLUDE=[\"$autoResumeAudioContext\",\"$dynCall\"]'")
    set_target_properties(SupergoonDash PROPERTIES LINK_FLAGS ${LINK_FLAGS} "-O0 -g -s SAFE_HEAP=1 -s STACK_OVERFLOW_CHECK=1 --preload-file ${CMAKE_SOURCE_DIR}/assets@/assets --preload-file ${CMAKE_SOURCE_DIR}/src/Scripts@/Scripts")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s 'DEFAULT_LIBRARY_FUNCS_TO_INCLUDE=[\"$autoResumeAudioContext\",\"$dynCall\"]'")
endif(EMSCRIPTEN)

# #########################################
# Compile Options
# #########################################
if(WIN32)
    target_compile_options(SupergoonDash PRIVATE
        /std:c11
    )
else()
    target_compile_options(SupergoonDash PRIVATE
        -Wall
        -Wextra
        -Wpedantic
        -Wdeprecated
        -Wno-newline-eof
        -Wno-strict-prototypes
        -pthread
    )
endif(WIN32)

# #########################################
# Linking Options
# #########################################

# SDL2::SDL2main may or may not be available. It is e.g. required by Windows GUI applications
if(TARGET SDL2::SDL2main)
    # It has an implicit dependency on SDL2 functions, so it MUST be added before SDL2::SDL2 (or SDL2::SDL2-static)
    target_link_libraries(SupergoonDash PRIVATE SDL2::SDL2main)
endif()

if(TARGET SDL2::SDL2-static)
    target_link_libraries(SupergoonDash PRIVATE SDL2::SDL2-static)
endif(TARGET SDL2::SDL2-static)

if(TARGET goonPhysics)
    target_link_libraries(SupergoonDash PRIVATE goonPhysics)
    target_include_directories(SupergoonDash PUBLIC
        external/goonPhysics/include/
    )
endif(TARGET goonPhysics)

# Always add goonphysics include instead of using the installed one for now
target_include_directories(SupergoonDash PUBLIC
    external/goonPhysics/include/
)

if(TARGET supergoonSound)
    target_link_libraries(SupergoonDash PRIVATE supergoonSound)
    target_include_directories(SupergoonDash PUBLIC
        external/sg_sound/src/
    )
endif(TARGET supergoonSound)

# Link to the actual SDL2 library. SDL2::SDL2 is the shared SDL library, SDL2::SDL2-static is the static SDL libarary.
target_link_libraries(SupergoonDash
    PUBLIC
    PRIVATE

    # SDL2::SDL2-static
    SDL2_image::SDL2_image-static
    SDL2_ttf::SDL2_ttf-static
    ${LUA_LIBRARIES}
    ${GOONSOUND_LIBRARIES}
    ${LIB_SOCKET}
    ${GOONPHYSICS_LIBRARIES}
)
target_link_directories(SupergoonDash
    PRIVATE
    /usr/local/lib
)

target_include_directories(SupergoonDash
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/
)

# #########################################
# Install
# #########################################
set(FOLDERS_TO_COPY src/Scripts assets)

if(MSVC OR CMAKE_GENERATOR STREQUAL "Xcode")
    set(INSTALL_DIR ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$<CONFIG>)
else()
    set(INSTALL_DIR ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
endif(MSVC OR CMAKE_GENERATOR STREQUAL "Xcode")

install(DIRECTORY ${FOLDERS_TO_COPY}
    DESTINATION ${INSTALL_DIR}
    PATTERN "*.tsx" EXCLUDE
    PATTERN "*.tmx" EXCLUDE
    PATTERN "*.tiled-project" EXCLUDE
)

# #########################################
# Test
# #########################################
if(BUILD_TESTING AND NOT WIN32)
    message(STATUS "Enabling and starting tests")
    enable_testing()
endif(BUILD_TESTING AND NOT WIN32)

add_test(NAME cppclean COMMAND ${CMAKE_SOURCE_DIR}/tests/cppclean.sh ${CMAKE_SOURCE_DIR})
