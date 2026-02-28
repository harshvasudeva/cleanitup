# CLI Setup Guide for URL Sanitizer

Quick reference for setting up the Share Extension from command line or automated build systems.

## Project Structure

```
sanitizer/
├── sanitizer/                          # Main app target
│   ├── sanitizerApp.swift
│   ├── ContentView.swift
│   ├── URLSanitizer.swift             # ← Shared
│   ├── SettingsManager.swift          # ← Shared
│   ├── RecentURLsManager.swift        # ← Shared
│   └── ShareView.swift                # ← Shared
│
└── sanitizer Share Extension/          # Extension target
    ├── ShareExtensionViewController.swift
    └── Info.plist
```

## Using xcodebuild

### Create Share Extension Target

You'll need to manually add the Share Extension target in Xcode GUI initially, but here's how to build:

```bash
# Build main app
xcodebuild -scheme sanitizer \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  clean build

# Build with extension
xcodebuild -scheme "sanitizer" \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

### Build for Device

```bash
xcodebuild -scheme sanitizer \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath ./build/sanitizer.xcarchive \
  archive

# Export IPA
xcodebuild -exportArchive \
  -archivePath ./build/sanitizer.xcarchive \
  -exportPath ./build/ipa \
  -exportOptionsPlist ExportOptions.plist
```

## Target Configuration via pbxproj

If editing `.pbxproj` directly (advanced):

### 1. Add Share Extension Files

Files that need to be in BOTH targets:
- `URLSanitizer.swift`
- `SettingsManager.swift`
- `RecentURLsManager.swift`
- `ShareView.swift`

Files ONLY in Share Extension:
- `ShareExtensionViewController.swift`

### 2. Build Settings

**Share Extension Target**:
```
PRODUCT_BUNDLE_IDENTIFIER = com.yourteam.sanitizer.ShareExtension
INFOPLIST_FILE = sanitizer Share Extension/Info.plist
IPHONEOS_DEPLOYMENT_TARGET = 16.0
TARGETED_DEVICE_FAMILY = 1  // iPhone only
```

**Main App Target**:
```
PRODUCT_BUNDLE_IDENTIFIER = com.yourteam.sanitizer
IPHONEOS_DEPLOYMENT_TARGET = 16.0
TARGETED_DEVICE_FAMILY = 1  // iPhone only
```

### 3. Embed Extension in App

The Share Extension must be embedded in the main app:

```xml
<!-- In main target's Copy Files Phase -->
<key>Embed App Extensions</key>
<array>
    <dict>
        <key>target</key>
        <string>sanitizer Share Extension</string>
    </dict>
</array>
```

## App Groups Setup (CLI)

### 1. Enable in Entitlements

**sanitizer.entitlements**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yourteam.sanitizer</string>
    </array>
</dict>
</plist>
```

**sanitizer Share Extension.entitlements**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yourteam.sanitizer</string>
    </array>
</dict>
</plist>
```

### 2. Link Entitlements in Build Settings

```
CODE_SIGN_ENTITLEMENTS = sanitizer/sanitizer.entitlements
// For extension:
CODE_SIGN_ENTITLEMENTS = sanitizer Share Extension/sanitizer Share Extension.entitlements
```

## Automated Testing

### Unit Tests

```swift
// Tests/URLSanitizerTests.swift
import XCTest
@testable import sanitizer

final class URLSanitizerTests: XCTestCase {
    func testBasicTracking() {
        let input = "https://example.com?utm_source=test"
        let result = URLSanitizer.sanitize(url: input)
        
        XCTAssertTrue(result.wasModified)
        XCTAssertEqual(result.sanitized, "https://example.com")
    }
    
    func testYouTubeVideoID() {
        let input = "https://youtube.com/watch?v=abc123&si=xyz"
        let result = URLSanitizer.sanitize(url: input)
        
        XCTAssertTrue(result.sanitized.contains("v=abc123"))
        XCTAssertFalse(result.sanitized.contains("si="))
    }
}
```

Run tests:
```bash
xcodebuild test -scheme sanitizer \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app
    
    - name: Build
      run: |
        xcodebuild -scheme sanitizer \
          -destination 'platform=iOS Simulator,name=iPhone 15' \
          clean build
    
    - name: Test
      run: |
        xcodebuild test -scheme sanitizer \
          -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Code Signing (Manual)

```bash
# 1. Create provisioning profile in Apple Developer Portal
# 2. Download and install

# 3. Build with signing
xcodebuild -scheme sanitizer \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  CODE_SIGN_IDENTITY="Apple Distribution: Your Team" \
  PROVISIONING_PROFILE_SPECIFIER="sanitizer Distribution" \
  archive
```

## Quick Verification

After building, verify Share Extension is embedded:

```bash
# Extract app bundle
cd build/Release-iphoneos

# Check extension exists
ls -la sanitizer.app/PlugIns/

# Should see:
# sanitizer Share Extension.appex/
```

## Common CLI Issues

### Extension Not Building
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/sanitizer-*

# Clean build
xcodebuild clean -scheme sanitizer
```

### Code Signing Issues
```bash
# List available identities
security find-identity -v -p codesigning

# List provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

### Simulator Not Found
```bash
# List available simulators
xcrun simctl list devices

# Create new simulator
xcrun simctl create "iPhone 15" "iPhone 15"
```

## Build Scripts

### build.sh
```bash
#!/bin/bash
set -e

echo "🧹 Cleaning..."
xcodebuild clean -scheme sanitizer

echo "🔨 Building main app..."
xcodebuild -scheme sanitizer \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build

echo "✅ Build complete!"
```

### test.sh
```bash
#!/bin/bash
set -e

echo "🧪 Running tests..."
xcodebuild test -scheme sanitizer \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  | xcpretty

echo "✅ Tests passed!"
```

Make executable:
```bash
chmod +x build.sh test.sh
./build.sh
```

## Performance Benchmarking

```bash
# Run with time profiling
xcodebuild test -scheme sanitizer \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableAddressSanitizer YES \
  -enableThreadSanitizer YES
```

---

For GUI setup instructions, see [README.md](README.md)
