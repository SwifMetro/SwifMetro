#!/bin/bash
set -e

echo "Building SwifMetro.xcframework..."

# Clean
rm -rf build/
rm -rf SwifMetro.xcframework
rm -f SwifMetro.xcframework.zip

# Create build directory
mkdir -p build

# Get Swift files
SWIFT_FILES=$(find Sources/SwifMetro -name "*.swift")

echo "Building for iOS devices (arm64)..."
swiftc $SWIFT_FILES \
  -module-name SwifMetro \
  -emit-library \
  -emit-module \
  -emit-module-path build/ \
  -target arm64-apple-ios14.0 \
  -sdk $(xcrun --sdk iphoneos --show-sdk-path) \
  -o build/libSwifMetro-ios-arm64.dylib

echo "Building for iOS Simulator (arm64 + x86_64)..."
swiftc $SWIFT_FILES \
  -module-name SwifMetro \
  -emit-library \
  -emit-module \
  -emit-module-path build/ \
  -target arm64-apple-ios14.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  -o build/libSwifMetro-sim-arm64.dylib

swiftc $SWIFT_FILES \
  -module-name SwifMetro \
  -emit-library \
  -emit-module \
  -emit-module-path build/ \
  -target x86_64-apple-ios14.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  -o build/libSwifMetro-sim-x86_64.dylib

echo "Creating fat binary for Simulator..."
lipo -create \
  build/libSwifMetro-sim-arm64.dylib \
  build/libSwifMetro-sim-x86_64.dylib \
  -output build/libSwifMetro-simulator.dylib

echo "Creating XCFramework..."
xcodebuild -create-xcframework \
  -library build/libSwifMetro-ios-arm64.dylib \
  -library build/libSwifMetro-simulator.dylib \
  -output SwifMetro.xcframework

echo "XCFramework created successfully!"
