ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = MediaSpeak7
MediaSpeak7_FILES = Tweak.xm
MediaSpeak7_FRAMEWORKS = UIKit AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
	make clean
	rm *.deb

SUBPROJECTS += Preferences

include $(THEOS_MAKE_PATH)/aggregate.mk
