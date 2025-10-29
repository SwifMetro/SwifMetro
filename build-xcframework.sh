#!/bin/bash
set -e

echo "Building SwifMetro.xcframework with PROPER framework structure..."

# Clean
rm -rf build/
rm -rf SwifMetro.xcframework
rm -f SwifMetro.xcframework.zip

# Create build directory
mkdir -p build

# Get Swift files
SWIFT_FILES=$(find /Users/conlanainsworth/Desktop/SwiftMetroTEST/Sources/SwifMetro -name "*.swift")

echo "Building for iOS devices (arm64)..."
swiftc $SWIFT_FILES \
  -module-name SwifMetro \
  -D DEBUG \
  -emit-library \
  -emit-module \
  -emit-module-interface \
  -enable-library-evolution \
  -emit-module-path build/SwifMetro-ios.swiftmodule \
  -emit-module-interface-path build/SwifMetro-ios.swiftinterface \
  -target arm64-apple-ios14.0 \
  -sdk $(xcrun --sdk iphoneos --show-sdk-path) \
  -o build/libSwifMetro-ios-arm64.dylib

echo "Building for iOS Simulator (arm64 + x86_64)..."
swiftc $SWIFT_FILES \
  -module-name SwifMetro \
  -D DEBUG \
  -emit-library \
  -emit-module \
  -emit-module-interface \
  -enable-library-evolution \
  -emit-module-path build/SwifMetro-sim-arm64.swiftmodule \
  -emit-module-interface-path build/SwifMetro-sim-arm64.swiftinterface \
  -target arm64-apple-ios14.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  -o build/libSwifMetro-sim-arm64.dylib

swiftc $SWIFT_FILES \
  -module-name SwifMetro \
  -D DEBUG \
  -emit-library \
  -emit-module \
  -emit-module-interface \
  -enable-library-evolution \
  -emit-module-path build/SwifMetro-sim-x86_64.swiftmodule \
  -emit-module-interface-path build/SwifMetro-sim-x86_64.swiftinterface \
  -target x86_64-apple-ios14.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  -o build/libSwifMetro-sim-x86_64.dylib

echo "Creating fat binary for Simulator..."
lipo -create \
  build/libSwifMetro-sim-arm64.dylib \
  build/libSwifMetro-sim-x86_64.dylib \
  -output build/libSwifMetro-simulator.dylib

echo "Creating proper framework bundle structures..."

# Create iOS device framework structure
mkdir -p "build/ios-arm64/SwifMetro.framework/Modules/SwifMetro.swiftmodule"
cp build/libSwifMetro-ios-arm64.dylib "build/ios-arm64/SwifMetro.framework/SwifMetro"
# Fix install name
install_name_tool -id "@rpath/SwifMetro.framework/SwifMetro" "build/ios-arm64/SwifMetro.framework/SwifMetro"
cp build/SwifMetro-ios.swiftmodule "build/ios-arm64/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios.swiftmodule"
cp build/SwifMetro-ios.swiftinterface "build/ios-arm64/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios.swiftinterface"
cp build/SwifMetro-ios.swiftdoc "build/ios-arm64/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios.swiftdoc" 2>/dev/null || true
cp build/SwifMetro-ios.abi.json "build/ios-arm64/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios.abi.json" 2>/dev/null || true
cp build/SwifMetro-ios.swiftsourceinfo "build/ios-arm64/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios.swiftsourceinfo" 2>/dev/null || true

# Create module map for iOS device framework
cat > "build/ios-arm64/SwifMetro.framework/Modules/module.modulemap" << EOF
framework module SwifMetro {
    export *
}
EOF

# Create Info.plist for iOS device framework
cat > "build/ios-arm64/SwifMetro.framework/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>SwifMetro</string>
    <key>CFBundleIdentifier</key>
    <string>com.swifmetro.SwifMetro</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>SwifMetro</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.18</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>14.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>iPhoneOS</string>
    </array>
</dict>
</plist>
EOF

# Create iOS simulator framework structure
mkdir -p "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule"
cp build/libSwifMetro-simulator.dylib "build/ios-arm64_x86_64-simulator/SwifMetro.framework/SwifMetro"
# Fix install name
install_name_tool -id "@rpath/SwifMetro.framework/SwifMetro" "build/ios-arm64_x86_64-simulator/SwifMetro.framework/SwifMetro"
cp build/SwifMetro-sim-arm64.swiftmodule "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios-simulator.swiftmodule"
cp build/SwifMetro-sim-arm64.swiftinterface "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios-simulator.swiftinterface"
cp build/SwifMetro-sim-arm64.swiftdoc "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios-simulator.swiftdoc" 2>/dev/null || true
cp build/SwifMetro-sim-arm64.abi.json "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios-simulator.abi.json" 2>/dev/null || true
cp build/SwifMetro-sim-arm64.swiftsourceinfo "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/arm64-apple-ios-simulator.swiftsourceinfo" 2>/dev/null || true
cp build/SwifMetro-sim-x86_64.swiftmodule "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/x86_64-apple-ios-simulator.swiftmodule"
cp build/SwifMetro-sim-x86_64.swiftinterface "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/x86_64-apple-ios-simulator.swiftinterface"
cp build/SwifMetro-sim-x86_64.swiftdoc "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/x86_64-apple-ios-simulator.swiftdoc" 2>/dev/null || true
cp build/SwifMetro-sim-x86_64.abi.json "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/x86_64-apple-ios-simulator.abi.json" 2>/dev/null || true
cp build/SwifMetro-sim-x86_64.swiftsourceinfo "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/SwifMetro.swiftmodule/x86_64-apple-ios-simulator.swiftsourceinfo" 2>/dev/null || true

# Create module map for iOS simulator framework
cat > "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Modules/module.modulemap" << EOF
framework module SwifMetro {
    export *
}
EOF

# Create Info.plist for iOS simulator framework
cat > "build/ios-arm64_x86_64-simulator/SwifMetro.framework/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>SwifMetro</string>
    <key>CFBundleIdentifier</key>
    <string>com.swifmetro.SwifMetro</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>SwifMetro</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.18</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>14.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>iPhoneSimulator</string>
    </array>
</dict>
</plist>
EOF

echo "Creating XCFramework with framework bundles..."
xcodebuild -create-xcframework \
  -framework "build/ios-arm64/SwifMetro.framework" \
  -framework "build/ios-arm64_x86_64-simulator/SwifMetro.framework" \
  -output SwifMetro.xcframework

echo "XCFramework created successfully with proper framework structure!"
echo ""
echo "Verifying structure..."
find SwifMetro.xcframework -type f | head -50
echo ""
echo "Verifying binaries are in place..."
file SwifMetro.xcframework/ios-arm64/SwifMetro.framework/SwifMetro
file SwifMetro.xcframework/ios-arm64_x86_64-simulator/SwifMetro.framework/SwifMetro

echo ""
echo "Creating zip archive..."
zip -r SwifMetro.xcframework.zip SwifMetro.xcframework

echo ""
echo "SUCCESS! XCFramework v1.0.18 built with proper framework structure."
echo ""
echo "Calculate checksum with: shasum -a 256 SwifMetro.xcframework.zip"
