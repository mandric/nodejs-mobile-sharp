
# NDK 18b failed on compling sha nodejs module, changed to 16b for now.
# https://developer.android.com/ndk/downloads/older_releases
export ANDROID_NDK_HOME ?= $(ANDROID_HOME)/ndk-bundle-r16b

DEBUG_APK := android/app/build/outputs/apk/app-debug.apk

all: $(DEBUG_APK)

$(DEBUG_APK): node_modules
	cd android && ./gradlew assembleDebug

node_modules:
	npm install
	patch -N \
	  -d nodejs-assets/nodejs-project/node_modules/sharp \
	  -p0 < sharp-glib.patch
# patching node_modules/sharp is not necessary because it only gets copied to
# the above location during install, it's not used in the android build but
# patching anyway.
	patch -N \
	  -d node_modules/sharp \
	  -p0 < sharp-glib.patch

clean:
	rm -rf $(DEBUG_APK)

reset: clean
	# git clean -fd
	# git checkout .
	cd android && ./gradlew clean
	rm -rf \
	  node_modules \
	  nodejs-assets/nodejs-project/node_modules

