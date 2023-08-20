.PHONY: config configure build release clean rebuild run lldb debug doc windows scripting

BUILD_SYSTEM = Ninja
XCODE_BUILD_SYSTEM = Xcode
BACKUP_BUILD_SYSTEM = 'Unix Makefiles'
WINDOWS_BUILD_SYSTEM = 'Visual Studio 17 2022'
MSVC_CONFIG_TYPE = Debug
BUILD_FOLDER = build
BINARY_FOLDER = bin
BINARY_NAME = SupergoonDash
BINARY_PATH = $(BUILD_FOLDER)/$(BINARY_NAME)
TILED_PATH = /Applications/Tiled.app/Contents/MacOS/Tiled
TILED_FOLDER_PATH = ./assets/tiled
TILED_EXPORT_TILESETS = background terrain
TILED_EXPORT_MAPS = level1

all: build run

# Macos dev
configure:
	@cmake . -B build -D CMAKE_BUILD_TYPE=Debug -G $(BUILD_SYSTEM)
# Macos Runner
mconfigure:
	@cmake . -B build -D CMAKE_BUILD_TYPE=Debug -G $(BACKUP_BUILD_SYSTEM) -DGOON_FULL_MACOS_BUILD=ON
# Macos Runner Future
xconfigure:
	@cmake . -B build -D CMAKE_BUILD_TYPE=Debug -G $(XCODE_BUILD_SYSTEM)
# Linux/Runner / MacosDev backup
bconfigure:
	@cmake . -B build -D CMAKE_BUILD_TYPE=Debug -G $(BACKUP_BUILD_SYSTEM)
# Windows/Runner
wconfigure:
	@cmake . -B build -D CMAKE_PREFIX_PATH=/c/cmake -G $(WINDOWS_BUILD_SYSTEM)

build:
	@cmake --build build --config $(MSVC_CONFIG_TYPE)

install:
	@cmake --install build --config $(MSVC_CONFIG_TYPE)
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

rebuild: clean configure build install test
brebuild: clean bconfigure build install test
wrebuild: clean wconfigure build install
mrebuild: clean mconfigure build install

# MacosDev
run:
	@cd ./$(BUILD_FOLDER)/$(BINARY_FOLDER) && ./$(BINARY_NAME)

test:
	@cd ./$(BUILD_FOLDER) && ctest --verbose --output-on-failure