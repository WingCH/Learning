xcodebuild archive \
-scheme study_objc_framework \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/study_objc_framework.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild archive \
-scheme study_objc_framework \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/study_objc_framework.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES