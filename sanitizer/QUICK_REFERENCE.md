# Quick Reference Card

## 🚀 Getting Started (5 Minutes)

### 1. Add Share Extension Target
```
Xcode → File → New → Target → Share Extension
Name: "sanitizer Share Extension"
```

### 2. Add Files to Extension
Select these files, check **both targets** in File Inspector:
- ✅ URLSanitizer.swift
- ✅ SettingsManager.swift  
- ✅ RecentURLsManager.swift
- ✅ ShareView.swift

### 3. Configure Info.plist
Copy from `ShareExtension-Info.plist` to extension's Info.plist

### 4. Build & Run
```
⌘ + B (Build)
⌘ + R (Run)
```

### 5. Test
```
Safari → https://example.com?utm_source=test
Tap Share → Select "Sanitize Link"
```

---

## 📁 Project Structure

```
sanitizer/
│
├── Main App
│   ├── sanitizerApp.swift           # Entry point
│   ├── ContentView.swift            # Main UI
│   └── Assets.xcassets              # Icons
│
├── Shared Code (both targets)
│   ├── URLSanitizer.swift           # Core engine ⚡
│   ├── SettingsManager.swift        # Preferences
│   ├── RecentURLsManager.swift      # History
│   └── ShareView.swift              # Extension UI
│
├── Extension Only
│   ├── ShareExtensionViewController.swift
│   └── Info.plist
│
└── Documentation
    ├── README.md                    # Full guide
    ├── SETUP_CHECKLIST.md           # Step-by-step
    ├── CLI_SETUP.md                 # Command line
    ├── UI_SPEC.md                   # Design specs
    └── URLSanitizerTests.swift      # Tests
```

---

## 🎯 Key Files Explained

### URLSanitizer.swift
**What**: Core sanitization logic  
**Does**: Removes 50+ tracking parameters  
**Used by**: Both app and extension  
**Modify**: To add/remove parameters

### SettingsManager.swift
**What**: User preferences storage  
**Does**: Syncs settings via App Groups  
**Used by**: Both targets  
**Modify**: To add new settings

### ShareView.swift
**What**: Share Extension UI  
**Does**: Displays cleaned URL with actions  
**Used by**: Extension only  
**Modify**: To change UI/layout

### ContentView.swift
**What**: Main app interface  
**Does**: Settings + recent URLs  
**Used by**: Main app only  
**Modify**: To change main app

---

## ⚙️ Configuration Quick Hits

### Target Membership
All shared files need **both** targets checked:
```
File Inspector → Target Membership
[x] sanitizer
[x] sanitizer Share Extension
```

### Info.plist (Extension)
Must have:
```xml
<key>NSExtensionActivationRule</key>
<dict>
    <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
    <integer>1</integer>
    <key>NSExtensionActivationSupportsText</key>
    <true/>
</dict>
```

### App Groups (Optional)
Both targets need same group:
```
Signing & Capabilities → App Groups
[x] group.YOUR_TEAM.sanitizer
```

Then update in code:
```swift
UserDefaults(suiteName: "group.YOUR_TEAM.sanitizer")
```

---

## 🧪 Testing Checklist

### In Simulator
- [ ] Main app launches
- [ ] Extension appears in Safari share sheet
- [ ] URL gets cleaned
- [ ] Copy button works
- [ ] Share button opens share sheet
- [ ] Settings toggle works
- [ ] Recent URLs show in app

### Test URLs
```
https://example.com?utm_source=test&fbclid=123
→ Should become: https://example.com

https://youtube.com/watch?v=ABC123&si=xyz
→ Should become: https://youtube.com/watch?v=ABC123
```

---

## 🐛 Common Issues & Fixes

### "Extension doesn't appear"
```bash
# Fix 1: Clean build
⇧ + ⌘ + K

# Fix 2: Delete app from simulator
# Fix 3: Rebuild and run
```

### "Cannot find URLSanitizer"
```
→ Check target membership for URLSanitizer.swift
→ Must be in BOTH targets
```

### "Settings don't persist"
```
→ Check App Groups are configured
→ Verify suite name matches in code
→ Both targets need same group
```

### "Extension crashes"
```
→ Check Console (⌘ + ⇧ + C)
→ Look for missing files in extension
→ Verify Info.plist principal class
```

---

## 📝 Customization Quick Guide

### Add Tracking Parameter
```swift
// In URLSanitizer.swift
private static let trackingParameters: Set<String> = [
    "your_new_param",  // ← Add here
    "utm_source",
    // ...
]
```

### Change Recent URL Limit
```swift
// In RecentURLsManager.swift
private let maxRecords = 10  // ← Change from 5
```

### Modify UI Colors
```swift
// In ShareView.swift
.foregroundStyle(.blue)  // ← Change to your color
```

---

## 🎨 UI Components

### Main App Sections
1. **How It Works** - Instructions
2. **Settings** - Toggles
3. **Recently Cleaned** - Last 5 URLs

### Share Extension States
1. **Loading** - Shows spinner
2. **Success** - Clean URL + actions
3. **Error** - Error message

---

## 📊 Performance Targets

| Action | Target | Max |
|--------|--------|-----|
| Extension launch | <200ms | 500ms |
| URL sanitization | <50ms | 300ms |
| Copy to clipboard | <10ms | 50ms |

---

## 🔐 Privacy Features

### What We DON'T Do
❌ Network requests  
❌ Analytics  
❌ Clipboard monitoring  
❌ Background execution  
❌ Third-party SDKs  

### What We DO
✅ Local processing  
✅ On-device storage  
✅ User-controlled settings  

---

## 📱 Platform Support

- **Minimum**: iOS 16.0
- **Target**: iOS 17+
- **Device**: iPhone only
- **Orientation**: Portrait

---

## 🚀 Deployment

### Version Numbers
```
Main App:       1.0 (1)
Extension:      1.0 (1)
← Must match!
```

### Bundle IDs
```
Main:      com.yourteam.sanitizer
Extension: com.yourteam.sanitizer.ShareExtension
```

### Create Archive
```
Select: Any iOS Device (arm64)
Product → Archive
```

---

## 📚 Documentation Map

| Need | Read |
|------|------|
| First time setup | SETUP_CHECKLIST.md |
| Command line build | CLI_SETUP.md |
| Full documentation | README.md |
| UI design details | UI_SPEC.md |
| What was built | IMPLEMENTATION_SUMMARY.md |
| This overview | QUICK_REFERENCE.md (you are here!) |

---

## 💡 Pro Tips

1. **Always clean build** after target changes
2. **Test on real device** before submitting
3. **Use App Groups** for better UX
4. **Check target membership** if imports fail
5. **Read Console logs** when debugging

---

## 🎯 Success Criteria

Your app is ready when:
- ✅ Builds without errors
- ✅ Runs on simulator
- ✅ Extension appears in share sheet
- ✅ URLs get cleaned correctly
- ✅ Settings persist
- ✅ No crashes or hangs
- ✅ Looks good in light/dark mode

---

## 📞 Help Resources

**Stuck on setup?**
→ Read SETUP_CHECKLIST.md section by section

**Need full docs?**
→ See README.md

**Want to customize?**
→ Check UI_SPEC.md

**Need tests?**
→ Run URLSanitizerTests.swift

**CLI issues?**
→ See CLI_SETUP.md

---

## 🎉 You're Ready!

**Files**: All created ✅  
**Architecture**: Solid ✅  
**Tests**: Included ✅  
**Docs**: Complete ✅  

**Next**: Open SETUP_CHECKLIST.md and follow along!

---

*Keep this file handy for quick reference during development.*
