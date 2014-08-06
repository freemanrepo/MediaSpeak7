ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = MediaSpeak7
MediaSpeak7_FILES = MediaSpeak7.mm
MediaSpeak7_INSTALL_PATH = /Library/PreferenceBundles
MediaSpeak7_FRAMEWORKS = UIKit Social
MediaSpeak7_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MediaSpeak7.plist$(ECHO_END)
