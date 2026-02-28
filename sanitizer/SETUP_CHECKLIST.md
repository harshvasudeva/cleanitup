# Share Extension Setup Checklist

Complete these steps **after** creating the Share Extension target in Xcode.

## ✅ Pre-Setup (Do First)

- [ ] Open Xcode project
- [ ] Ensure main app builds successfully
- [ ] Test main app in simulator
- [ ] Have Apple Developer account ready (for App Groups)

---

## 🎯 Step 1: Create Share Extension Target

1. **File → New → Target**
2. Filter for "Share"
3. Select **Share Extension**
4. Configure:
   - Product Name: `sanitizer Share Extension`
   - Language: **Swift**
   - Include UI Tests: **No**
5. Click **Finish**
6. Click **Activate** when prompted

**Verify**: You should see a new folder in Project Navigator:
```
sanitizer Share Extension/
├── ShareViewController.swift
├── MainInterface.storyboard
└── Info.plist
```

---

## 📋 Step 2: Configure Info.plist

### Option A: Remove Storyboard (Recommended for SwiftUI)

1. **Delete** `MainInterface.storyboard`
2. Open `sanitizer Share Extension/Info.plist`
3. Find `NSExtension` → `NSExtensionMainStoryboard`
4. **Delete** the `NSExtensionMainStoryboard` key
5. **Add** new key: `NSExtensionPrincipalClass`
6. Set value: `$(PRODUCT_MODULE_NAME).ShareViewController`

**Or** use the provided template:
- Copy contents from `ShareExtension-Info.plist` file
- Paste into `sanitizer Share Extension/Info.plist`

### Option B: Keep Storyboard

If you prefer Interface Builder, keep the storyboard and manually connect it to a UIHostingController.

**Check**: Info.plist should have:
```xml
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
```

---

## 📁 Step 3: Replace/Update Files

### Delete Template File
1. **Delete** the auto-generated `ShareViewController.swift` in the Share Extension folder

### Add New Files
1. Copy `ShareExtensionViewController.swift` to the Share Extension folder
2. In Xcode, verify it's in the correct target

### Add Shared Files to Both Targets

For each of these files, select them and in **File Inspector** (⌥⌘1):

**URLSanitizer.swift**:
- [x] sanitizer (main app)
- [x] sanitizer Share Extension

**SettingsManager.swift**:
- [x] sanitizer
- [x] sanitizer Share Extension

**RecentURLsManager.swift**:
- [x] sanitizer
- [x] sanitizer Share Extension

**ShareView.swift**:
- [x] sanitizer
- [x] sanitizer Share Extension

**How to check target membership**:
1. Select file in Project Navigator
2. Open File Inspector (right panel)
3. Check both targets under "Target Membership"

---

## 🔐 Step 4: Setup App Groups (Optional but Recommended)

This allows settings to sync between app and extension.

### In Apple Developer Portal

1. Go to [developer.apple.com](https://developer.apple.com)
2. **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+ (add)**
4. Select **App Groups** → Continue
5. Description: `Sanitizer App Group`
6. Identifier: `group.YOUR_TEAM_ID.sanitizer`
   - Replace `YOUR_TEAM_ID` with your team ID
7. Click **Register**

### In Xcode - Main App Target

1. Select **sanitizer** target
2. **Signing & Capabilities** tab
3. Click **+ Capability**
4. Select **App Groups**
5. Click **+ (add group)**
6. Enter: `group.YOUR_TEAM_ID.sanitizer`
7. Check the box to enable it

### In Xcode - Extension Target

1. Select **sanitizer Share Extension** target
2. **Signing & Capabilities** tab
3. Click **+ Capability**
4. Select **App Groups**
5. Click **+ (add group)**
6. Enter: `group.YOUR_TEAM_ID.sanitizer` (same as above)
7. Check the box to enable it

### Update Code

**In `SettingsManager.swift`**, find:
```swift
// TODO: Update this to use App Group when you add Share Extension
self.defaults = .standard
```

Replace with:
```swift
self.defaults = UserDefaults(suiteName: "group.YOUR_TEAM_ID.sanitizer") ?? .standard
```

**In `RecentURLsManager.swift`**, find:
```swift
// TODO: Use App Group suite name
self.defaults = .standard
```

Replace with:
```swift
self.defaults = UserDefaults(suiteName: "group.YOUR_TEAM_ID.sanitizer") ?? .standard
```

---

## ⚙️ Step 5: Build Settings

### Main App Target (sanitizer)

1. Select **sanitizer** target
2. **Build Settings** tab
3. Search for "deployment"
4. Set **iOS Deployment Target** to **16.0**

### Extension Target (sanitizer Share Extension)

1. Select **sanitizer Share Extension** target
2. **Build Settings** tab
3. Set **iOS Deployment Target** to **16.0**
4. Search for "bundle identifier"
5. Verify it's: `YOUR_BUNDLE_ID.ShareExtension`

---

## 🔨 Step 6: Build and Test

### Build Main App
1. Select **sanitizer** scheme
2. Select iPhone simulator
3. **Product → Build** (⌘B)
4. Fix any errors

### Build Extension
1. Extension builds automatically with main app
2. Check for any errors in both targets

### Test in Simulator
1. Run the main app (⌘R)
2. App should launch and show home screen
3. Close the app
4. Open **Safari** in simulator
5. Navigate to: `https://example.com?utm_source=test&fbclid=123`
6. Tap **Share** button in toolbar
7. Scroll right in the bottom row of share actions
8. Look for **"Sanitize Link"** (or your app name)
9. Tap it
10. Extension should open and clean the URL

### Expected Result
```
Original:  https://example.com?utm_source=test&fbclid=123
Cleaned:   https://example.com
Removed:   utm_source, fbclid
```

---

## 🐛 Troubleshooting

### Extension Doesn't Appear in Share Sheet

**Problem**: App doesn't show up when sharing URLs

**Solutions**:
- [ ] Clean Build Folder (⇧⌘K)
- [ ] Delete app from simulator
- [ ] Rebuild and run
- [ ] Restart simulator
- [ ] Check Info.plist activation rules
- [ ] Verify extension target is being built

### Build Errors

**Problem**: "Cannot find 'URLSanitizer' in scope"

**Solution**: Check target membership for all shared files

**Problem**: "No such module 'sanitizer'"

**Solution**: Clean build folder and rebuild

### Settings Don't Persist

**Problem**: Toggle settings in extension, but they reset

**Solution**: Verify App Groups are configured correctly in both targets

### Extension Crashes on Launch

**Problem**: Extension opens but immediately crashes

**Solutions**:
- [ ] Check Console for error messages
- [ ] Verify ShareViewController class name matches Info.plist
- [ ] Check all files compile for extension target
- [ ] Ensure no Core Data references in extension code

---

## ✨ Step 7: Polish

### App Icon
1. Add app icon to Assets.xcassets
2. Minimum 1024x1024 PNG
3. No transparency, no rounded corners

### Display Name
1. Select **sanitizer** target
2. **General** tab
3. Change **Display Name** to: `URL Sanitizer`

### Extension Display Name
1. Select **sanitizer Share Extension** target
2. **General** tab
3. Change **Display Name** to: `Sanitize Link`

This is what users see in the Share Sheet!

---

## 📱 Step 8: Test on Real Device

### Why Physical Device?
- Share Extension behavior differs on device
- Performance is more realistic
- Share Sheet integration may vary

### How to Test
1. Connect iPhone via USB
2. Select your iPhone as destination
3. Build and run (⌘R)
4. Test same workflow as simulator
5. Verify performance < 300ms

---

## 📦 Step 9: Prepare for Release

### Version and Build Number
1. Select **sanitizer** target
2. **General** tab
3. Set **Version**: 1.0
4. Set **Build**: 1

### Do Same for Extension
1. Select **sanitizer Share Extension** target
2. Set **Version**: 1.0
3. Set **Build**: 1

**Note**: These should match!

### Create Archive
1. Select **Any iOS Device (arm64)**
2. **Product → Archive**
3. Wait for build
4. Should see in **Organizer**

---

## ✅ Final Verification Checklist

Before submitting to App Store:

### Functionality
- [ ] Main app launches without errors
- [ ] Share extension appears in share sheet
- [ ] URL sanitization works correctly
- [ ] Copy button copies to clipboard
- [ ] Share button opens system share sheet
- [ ] Settings persist between app and extension
- [ ] Recent URLs appear in main app
- [ ] Toggle settings work
- [ ] No crashes or hangs

### Performance
- [ ] Extension opens in < 500ms
- [ ] Sanitization completes in < 300ms
- [ ] No memory leaks
- [ ] Smooth animations

### Accessibility
- [ ] VoiceOver works correctly
- [ ] Dynamic Type supported
- [ ] High Contrast mode works
- [ ] Buttons have proper labels

### Privacy
- [ ] No network requests (except optional expand)
- [ ] No tracking code
- [ ] No third-party SDKs
- [ ] Data stored locally only

### Polish
- [ ] App icon added
- [ ] Display names set
- [ ] Dark mode looks good
- [ ] Layout works on all iPhone sizes

---

## 🚀 Next Steps

1. **Test thoroughly** with real URLs from different apps
2. **Get beta feedback** via TestFlight
3. **Create App Store screenshots**
4. **Write App Store description**
5. **Submit for review**

---

## 📚 Additional Resources

- [README.md](README.md) - Full setup guide
- [CLI_SETUP.md](CLI_SETUP.md) - Command line build instructions
- [UI_SPEC.md](UI_SPEC.md) - UI design specifications
- [URLSanitizerTests.swift](URLSanitizerTests.swift) - Test suite

---

## 🆘 Getting Help

If stuck, check:
1. Console logs in Xcode
2. Target membership for all files
3. Info.plist configuration
4. App Groups setup
5. Build settings for both targets

Common issues are 99% configuration problems, not code problems!

---

**You're all set!** 🎉

After completing this checklist, you should have a fully functional URL Sanitizer app with Share Extension ready for testing and deployment.
