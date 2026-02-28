# URL Sanitizer for iOS

A privacy-focused iOS app that removes tracking parameters from URLs via the Share Sheet.

## 🎯 Features

- **Share Extension**: Clean URLs directly from any app
- **No Tracking**: All processing happens locally on device
- **Fast**: Sub-300ms sanitization
- **Privacy First**: No analytics, no accounts, no background activity
- **Recent History**: Last 5 cleaned URLs (stored locally)
- **Customizable**: Aggressive cleaning mode for power users

## 📦 Project Structure

```
sanitizer/
├── sanitizerApp.swift              # App entry point
├── ContentView.swift               # Main app UI
├── URLSanitizer.swift              # Core sanitization engine
├── SettingsManager.swift           # User preferences
├── RecentURLsManager.swift         # Recent URLs storage
├── ShareView.swift                 # Share extension UI
└── ShareExtensionViewController.swift  # Share extension host
```

## 🛠️ Setup Instructions

### 1. Add Share Extension Target

In Xcode:

1. **File → New → Target**
2. Select **Share Extension** (iOS)
3. Name it: `sanitizer Share Extension`
4. Language: **Swift**
5. Click **Activate**

### 2. Configure Share Extension

#### Add Info.plist Keys

Open `sanitizer Share Extension/Info.plist` and add:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>NSExtensionActivationRule</key>
        <dict>
            <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
            <integer>1</integer>
            <key>NSExtensionActivationSupportsText</key>
            <true/>
        </dict>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
</dict>
```

**OR** if using purely SwiftUI (no storyboard):

Delete the `MainInterface.storyboard` and replace with:

```xml
<key>NSExtensionPrincipalClass</key>
<string>$(PRODUCT_MODULE_NAME).ShareViewController</string>
```

### 3. Add Files to Share Extension Target

Select these files and add them to **both targets** in the File Inspector:
- ✅ `URLSanitizer.swift`
- ✅ `SettingsManager.swift`
- ✅ `RecentURLsManager.swift`
- ✅ `ShareView.swift`
- ✅ `ShareExtensionViewController.swift` (Share Extension only)

### 4. Setup App Groups (Optional - for shared preferences)

This allows settings to be shared between the main app and extension.

#### In Apple Developer Portal:
1. Go to **Certificates, Identifiers & Profiles**
2. Create new **App Group**: `group.com.yourteam.sanitizer`

#### In Xcode:
1. Select main **sanitizer** target
2. **Signing & Capabilities** → **+ Capability** → **App Groups**
3. Check `group.com.yourteam.sanitizer`
4. Repeat for **sanitizer Share Extension** target

#### Update Code:
In `SettingsManager.swift` and `RecentURLsManager.swift`, change:

```swift
// From:
self.defaults = .standard

// To:
self.defaults = UserDefaults(suiteName: "group.com.yourteam.sanitizer") ?? .standard
```

### 5. Build Configuration

**Minimum Deployment Target**: iOS 16.0

Set for both targets:
- Main app target: iOS 16.0
- Share Extension target: iOS 16.0

### 6. Remove Old Core Data Files (Optional)

Since we're not using Core Data, you can delete:
- `Persistence.swift`
- `sanitizer.xcdatamodeld`

Update any references if needed.

## 🧪 Testing

### Test in Simulator

1. Build and run the main app
2. Open Safari
3. Navigate to a URL with tracking parameters:
   ```
   https://example.com/page?utm_source=test&utm_campaign=demo&fbclid=12345
   ```
4. Tap Share button
5. Select "Sanitize Link"
6. Should show cleaned URL instantly

### Test Cases

| Input | Expected Output |
|-------|----------------|
| `https://example.com?utm_source=test` | `https://example.com` |
| `https://youtube.com/watch?v=abc123&si=xyz` | `https://youtube.com/watch?v=abc123` |
| `https://amazon.com/dp/B08?ref_=xyz` | `https://amazon.com/dp/B08` |

## 📱 Usage

### From Main App
1. Open app
2. Configure settings (aggressive cleaning, etc.)
3. View recently cleaned URLs
4. Tap any recent URL to copy

### From Share Extension
1. In any app with a URL (Safari, Twitter, etc.)
2. Tap Share button
3. Select "Sanitize Link"
4. View cleaned URL
5. Tap "Copy" or "Share"

## 🔧 Customization

### Add More Tracking Parameters

Edit `URLSanitizer.swift`:

```swift
private static let trackingParameters: Set<String> = [
    // Add your parameters here
    "your_tracking_param",
]
```

### Change Recent URLs Limit

Edit `RecentURLsManager.swift`:

```swift
private let maxRecords = 10  // Change from 5 to 10
```

### Adjust UI Colors

Edit `ShareView.swift` to customize appearance.

## 🚀 App Store Submission

Before submitting:

1. ✅ Update bundle IDs to your team ID
2. ✅ Add App Icon (1024x1024)
3. ✅ Create screenshots
4. ✅ Write privacy policy (even if minimal)
5. ✅ Test on physical device
6. ✅ Verify Share Extension appears in Share Sheet

### Privacy Declaration

Since this app:
- ✅ No network requests (except optional link expansion)
- ✅ No third-party SDKs
- ✅ No analytics
- ✅ No user accounts
- ✅ All data stored locally

Your privacy policy can be minimal. Example:

> "URL Sanitizer processes all URLs locally on your device. No data is collected, stored remotely, or shared with third parties."

## 📋 Checklist

- [ ] Share Extension target added
- [ ] Files added to correct targets
- [ ] Info.plist configured
- [ ] App Groups setup (optional)
- [ ] Deployment target set to iOS 16+
- [ ] Tested in simulator
- [ ] Tested on device
- [ ] Share Sheet shows extension
- [ ] URL sanitization works
- [ ] Copy/Share actions work
- [ ] Settings persist
- [ ] Recent URLs save

## 🐛 Troubleshooting

### Share Extension Doesn't Appear
- Check Info.plist activation rules
- Verify target membership for all files
- Clean build folder (Cmd+Shift+K)
- Restart simulator/device

### Settings Don't Persist
- Verify App Groups are enabled
- Check suite name matches in UserDefaults
- Ensure both targets have same App Group

### Build Errors
- Check all files are added to correct targets
- Verify deployment target is iOS 16+
- Ensure SwiftUI imports are present

## 📝 License

This is a template project. Use freely for your own apps.

---

**Built with**: Swift 5.9+ | SwiftUI | iOS 16+
**Platform**: iPhone only (iPad support can be added)
