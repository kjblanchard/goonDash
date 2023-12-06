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
CMAKE_CONFIGURE_COMMAND = cmake
XCODE_CONFIGURE_FLAGS = -DIOS_PLATFORM=OS -Dvendored_default=TRUE -DSDL2TTF_VENDORED=TRUE
UNIX_PACKAGE_COMMAND = tar -czvf $(BUILD_FOLDER)/$(BINARY_NAME).tgz -C $(BINARY_FOLDER_REL_PATH) .
WINDOWS_PACKAGE_COMMAND = 7z a -r $(BUILD_FOLDER)/$(BINARY_NAME).zip $(BINARY_FOLDER_REL_PATH)
PACKAGE_COMMAND = $(UNIX_PACKAGE_COMMAND)
BUILD_COMMAND = cmake --build build --config $(CMAKE_BUILD_TYPE)
### ### ###
### ### ###
### Targets / Rules for easy calls into cmake and runners utilize these instead of interfacing with cmake directly. ##
### ### ###
all: build run
clean:
	@ - rm -rf build
configure:
	$(CMAKE_CONFIGURE_COMMAND) . -B build -D CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) -G $(BUILD_SYSTEM) -DGOON_FULL_MACOS_BUILD=$(FULL_MAC_BUILD) $(CONFIGURE_FLAGS)
build:
	@$(BUILD_COMMAND)
install:
	@cmake --install build --config $(CMAKE_BUILD_TYPE)
package:
	@$(PACKAGE_COMMAND)
rebuild: BUILD_SYSTEM = $(PRIMARY_BUILD_SYSTEM)
rebuild: clean configure build install
brebuild: BUILD_SYSTEM = $(BACKUP_BUILD_SYSTEM)
brebuild: clean configure build install
run:
	@cd ./$(BUILD_FOLDER)/$(BINARY_FOLDER) &&  ./$(BINARY_NAME)