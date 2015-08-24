export ARCHS=armv7 armv7s arm64

GO_EASY_ON_ME=1

include theos/makefiles/common.mk

LIBRARY_NAME = libWeatherInfo
libWeatherInfo_FILES = WBWeatherInfoManager.m WBCity.m
libWeatherInfo_FRAMEWORKS = CoreLocation
libWeatherInfo_PRIVATE_FRAMEWORKS = Weather

TOOL_NAME = weatherinfod
weatherinfod_FILES = main.mm WBInfoUpdater.m WBInfoService.m WBInfoWorker.m WBCity.m
weatherinfod_FRAMEWORKS = CoreLocation QuartzCore IOKit
weatherinfod_PRIVATE_FRAMEWORKS = Weather
weatherinfod_CODESIGN_FLAGS = -S./entitlements.xml
weatherinfod_INSTALL_PATH = /usr/libexec/

ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/include

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tool.mk

internal-library-compile:
	cp ./obj/libWeatherInfo.dylib $(THEOS_LIBRARY_PATH)