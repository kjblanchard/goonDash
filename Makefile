.PHONY: config configure build release clean rebuild run lldb debug doc windows scripting package
# Build System definitions
PRIMARY_BUILD_SYSTEM = Ninja
BACKUP_BUILD_SYSTEM = 'Unix Makefiles'
XCODE_BUILD_SYSTEM = Xcode
WINDOWS_BUILD_SYSTEM = 'Visual Studio 17 2022'
### Build Type ### You can override this when calling make ### make CMAKE_BUILD_TYPE=Release ###
CMAKE_BUILD_TYPE ?= Debug
FULL_MAC_BUILD ?= OFF
# Binary Config
BUILD_FOLDER = build
BINARY_FOLDER = bin
BINARY_NAME = SupergoonDash
BINARY_FOLDER_REL_PATH = $(BUILD_FOLDER)/$(BINARY_FOLDER)
##Build Specific Flags
CONFIGURE_FLAGS = ''
EMSCRIPTEN_CONFIGURE_FLAGS = -DCMAKE_VERBOSE_MAKEFILE=ON
XCODE_CONFIGURE_FLAGS = '-DIOS_PLATFORM=OS -Dvendored_default=TRUE -DSDL2TTF_VENDORED=TRUE'
# Tiled Configuration
TILED_PATH = /Applications/Tiled.app/Contents/MacOS/Tiled
TILED_FOLDER_PATH = ./assets/tiled
TILED_EXPORT_TILESETS = background terrain
TILED_EXPORT_MAPS = level1

all: build run

# Macos dev
configure:
	@cmake . -B build -D CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) -G $(BUILD_SYSTEM) -DGOON_FULL_MACOS_BUILD=$(FULL_MAC_BUILD) $(CONFIGURE_FLAGS)
# econfigure:
#	@emcmake cmake . -B build  -D CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) -G $(BACKUP_BUILD_SYSTEM) -DGOON_FULL_MACOS_BUILD=ON -DCMAKE_VERBOSE_MAKEFILE=ON
# Macos Runner Future
# xconfigure:
# 	@cmake . -B build -D CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) -G $(XCODE_BUILD_SYSTEM) -DGOON_FULL_MACOS_BUILD=ON -DIOS_PLATFORM=OS -Dvendored_default=TRUE -DSDL2TTF_VENDORED=TRUE
# Linux/Runner / MacosDev backup
# bconfigure:
# 	@cmake . -B build -D CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) -G $(BACKUP_BUILD_SYSTEM)
# Windows/Runner
# wconfigure:
# 	@cmake . -B build -D CMAKE_PREFIX_PATH=/c/cmake -G $(WINDOWS_BUILD_SYSTEM)

build:
	@cmake --build build --config $(CMAKE_BUILD_TYPE)
ebuild:
	@sudo cmake --build build

install:
	@cmake --install build --config $(CMAKE_BUILD_TYPE)
# Exports the tilesets if we need to as lua files for tsx/tmx
tiled:
	@$(foreach file,$(TILED_EXPORT_TILESETS),\
		$(TILED_PATH) --export-tileset lua $(TILED_FOLDER_PATH)/$(file).tsx $(TILED_FOLDER_PATH)/$(file).lua;\
	)
	@$(foreach file,$(TILED_EXPORT_MAPS),\
		$(TILED_PATH) --export-map lua $(TILED_FOLDER_PATH)/$(file).tmx $(TILED_FOLDER_PATH)/$(file).lua;\
	)
# Clean build folder
clean:
	@ - rm -rf build
package:
	@tar -czvf $(BUILD_FOLDER)/$(BINARY_NAME).tgz -C $(BINARY_FOLDER_REL_PATH) .

wpackage:
	@7z a -r $(BUILD_FOLDER)/$(BINARY_NAME).zip $(BINARY_FOLDER_REL_PATH)

rebuild: BUILD_SYSTEM = $(PRIMARY_BUILD_SYSTEM)
rebuild: clean configure build install test
brebuild: BUILD_SYSTEM = $(BACKUP_BUILD_SYSTEM)
brebuild: clean configure build install test package
wrebuild: BUILD_SYSTEM=$(WINDOWS_BUILD_SYSTEM)
wrebuild: clean configure build install wpackage
xrebuild: BUILD_SYSTEM=$(XCODE_BUILD_SYSTEM) CONFIGURE_FLAGS=$(XCODE_CONFIGURE_FLAGS)
xrebuild: clean configure build install package
erebuild: @BUILD_SYSTEM=$(BACKUP_BUILD_SYSTEM) CONFIGURE_FLAGS=$(EMSCRIPTEN_CONFIGURE_FLAGS)
erebuild: clean configure ebuild

# MacosDev
run:
	@cd ./$(BUILD_FOLDER)/$(BINARY_FOLDER) && DYLD_LIBRARY_PATH="/Users/kevin/git/lua/luasocket/build/lib/lua/5.4/socket" ./$(BINARY_NAME)

erun:
	@emrun ./$(BUILD_FOLDER)/$(BINARY_FOLDER)/$(BINARY_NAME).html

test:
	@cd ./$(BUILD_FOLDER) && ctest --verbose --output-on-failure