
.PHONY: node_modules

export ANDROID_NDK_HOME ?= $(ANDROID_HOME)/ndk-bundle

DEBUG_APK := android/app/build/outputs/apk/app-debug.apk
NODEJS_MOBILE := node_modules/nodejs-mobile-react-native
NODEJS_PROJ := nodejs-assets/nodejs-project
LIBVIPS_VER := 8.6.1
LIBVIPS_ARCH := armv6

all: $(DEBUG_APK)

$(DEBUG_APK): node_modules
	cd android && \
	  ./gradlew -d androidDependencies && \
	  ./gradlew -d bundleReleaseJsAndAssets && \
	  mkdir app/src/main/assets && \
	  cp ./app/build/intermediates/assets/release/index.android.bundle \
	     app/src/main/assets/
	cd android && ./gradlew -d assembleDebug

node_modules:
	npm install
	patch -N -f -d $(NODEJS_MOBILE) \
	  -p0 < patches/nodejs-mobile.patch || echo 'patch failed'
	find "$(NODEJS_PROJ)/node_modules/sharp" -type d -name glib-2.0 | while read dir; do \
	  patch -N -f -d "$$dir" -p0 < patches/sharp-glib.patch || echo '$$dir patch failed'; \
	done
	find "$(NODEJS_PROJ)/node_modules" -type d -name leveldb-1.20 | while read dir; do \
	  patch -N -f -d "$$dir" -p0 < patches/leveldb.patch || echo "$$dir patch failed"; \
	done
	find "$(NODEJS_PROJ)/node_modules" -type d -name snappy-1.1.4 | while read dir; do \
	  patch -N -f -d "$$dir" -p0 < patches/snappy.patch || echo "$$dir patch failed"; \
	done
	#mkdir -p $(NODEJS_PROJ)/node_modules/sharp/vendor
	#curl -sSfL \
	#  https://github.com/lovell/sharp-libvips/releases/download/v$(LIBVIPS_VER)/$(LIBVIPS) \
	#  > $(NODEJS_PROJ)/node_modules/sharp/vendor/$(LIBVIPS)
	# hack
	#cp $(NODEJS_PROJ)/node_modules/sharp/vendor/libvips-$(LIBVIPS_VER)-linux-$(LIBVIPS_ARCH).tar.gz \
	#   $(NODEJS_PROJ)/node_modules/sharp/vendor/libvips-$(LIBVIPS_VER)-android-$(LIBVIPS_ARCH).tar.gz


clean:
	#rm -rf $(DEBUG_APK)
	cd android && ./gradlew clean

reset: clean
	# git clean -fd
	# git checkout .
	rm -rf \
	  node_modules \
	  nodejs-assets/nodejs-project/node_modules

