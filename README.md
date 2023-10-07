# GoonDash
A C program with Lua scripting, that utilizes Tiled and Aseprite for the game "engine".
![Build All Platforms]( https://github.com/kjblanchard/goonDash/actions/workflows/build.yml/badge.svg)
<!-- ![Status Picture](https://github.com/kjblanchard/goonDash/blob/master/img/status.png?raw=true) -->
- Play the game here, or likely watch its "progress" [Supergoon.com](https://supergoondash.supergoon.com)

## Development
- Mostly developed on macos apple silicon
- Going to build on Mac, Linux, Windows, Emscripten throughout development

## Goals
- Better at C
- Create a simple "Geometry Dash" clone.
- Better at cross-platform building (Macos, Linux, Windows)
- Learn github actions, as we should be building these here
#### Stretch Goals
- Game build on Mobile (IOS priority)

## Building
- If you have the libraries installed, just use the make rebuild command
- Otherwise, use the full builds in the makefile for your platform

## Current State
- Loads a tilemap and draws it to the screen.
- Currently no gameobjects.
- Sound implemented, loops over and over.
- Builds on all platforms in runners.

## Requirements
- Cmake will install all of the required libraries with all of the rebuild commands in make except "rebuild".

## Components
- CMake: The actual cross-platform build system.
- SDL2: Low Level handling of windowing, events, input
- Make: Streamlining building with one command
- Emscripten: Build for web
- Lua: Embedded Scripting

## Documentation
- Hosted on docs.supergoon.com, generated by doxygen.  Not created yet.

## Licenses
MIT

Libraries:
- [SDL](https://www.libsdl.org/license.php) - ZLIB - Low level Windowing / Eventing
- [doxygen](https://doxygen.nl) - GPL | Automatic documentation
- [LUA](https://www.lua.org/license.html) - MIT - Scripting
- [Supergoon Sound](https://github.com/kcat/openal-soft/blob/master/COPYING) - MIT | OpenAL implementation

### ZeroBrane Debugging notes
- Had to build luasocket from source, as the one from luarocks didn't build right for arm
- Had to get the build command from the mac.cmd file, and use that
- Had to remove -bundle and use these changes:
-LDFLAGS_macosx= -bundle -undefined dynamic_lookup -o
+LDFLAGS_macosx=  -undefined dynamic_lookup -dynamiclib -o
- Had to rename the files and put in a shared lib local location, as for some reason it references core in different places (socket-3.0.0)
- Now when you run (with make run) it will trigger breakpoints set in zerobrane after you start the server.

### Valgrind
valgrind --track-origins=yes --leak-check=yes --leak-resolution=low --show-leak-kinds=definite ./SupergoonDash 2>&1 | tee memcheck.txt