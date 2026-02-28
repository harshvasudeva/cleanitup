# Clean it Up!

A privacy-focused iOS app that strips tracking parameters from URLs. Works as a standalone app and as a Share Extension, so you can clean links directly from Safari, Twitter, Reddit, or any app with a share sheet.

## Why

Every link you share or click is full of tracking junk — `utm_source`, `fbclid`, `gclid`, and dozens more. These parameters let advertisers follow you across the web. Clean it Up! removes them before you share a link, giving you cleaner URLs and better privacy.

**Before:**
```
https://example.com/article?id=42&utm_source=twitter&utm_medium=social&fbclid=abc123&gclid=xyz
```

**After:**
```
https://example.com/article?id=42
```

## Features

- **Share Extension** — Clean URLs from any app via the iOS share sheet without opening the app
- **Manual cleaning** — Paste or type a URL in the app to clean it
- **Paste & Clean** — One-tap clipboard cleaning
- **Aggressive mode** — Optional setting to strip additional non-essential parameters
- **Recent history** — Stores the last 5 cleaned URLs locally for quick access
- **100% offline** — All processing happens on-device. No servers, no network calls
- **No tracking** — Zero analytics, zero telemetry, zero third-party SDKs

## Supported Trackers

Removes parameters from 60+ tracking systems including:

| Source | Parameters |
|--------|-----------|
| Google Analytics | `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`, and more |
| Google Ads | `gclid`, `gclsrc`, `dclid` |
| Facebook | `fbclid`, `fb_action_ids`, `fb_action_types`, `fb_source`, `fb_ref` |
| Instagram | `igshid`, `igsh` |
| TikTok | `tt_medium`, `tt_content` |
| Twitter/X | `twclid` |
| LinkedIn | `li_fat_id`, `trk` |
| HubSpot | `_hsenc`, `_hsmi`, `__hssc`, `__hstc`, `__hsfp`, `hsCtaTracking` |
| Mailchimp | `mc_cid`, `mc_eid` |
| Amazon | `ref_`, `pf_rd_r`, `pf_rd_p`, `pf_rd_m`, `pf_rd_s`, `pf_rd_t`, `pf_rd_i` |
| YouTube | `si`, `feature` |
| Microsoft | `msclkid` |
| Others | `yclid`, `wickedid`, `vero_id`, `_openstat`, `mbid`, `mkt_tok`, `s_cid` |

With **aggressive mode** enabled, also strips: `source`, `ref`, `share`, `referrer`, `campaign`, `affiliate`, `from`, `via`, and more.

## How It Works

### Share Extension (primary use)
1. Tap the **Share** button in any app (Safari, Messages, etc.)
2. Select **Clean it Up!** from the share sheet
3. The cleaned URL is displayed instantly
4. Tap **Copy** or **Share** to use the clean link

### Main App
1. Open the app
2. Paste a URL into the text field, or tap **Paste & Clean**
3. The cleaned URL appears with a list of removed parameters
4. Copy or share the result

The sanitizer works by parsing the URL, checking each query parameter against the known tracking parameter list, and removing matches. It also catches any parameter prefixed with `utm_` or `mc_` that might not be in the explicit list. Non-tracking parameters (like `id`, `page`, `q`) are preserved.

## Project Structure

```
sanitizer/
├── sanitizerApp.swift                  # App entry point
├── ContentView.swift                   # Main app UI (input, settings, history, about)
├── URLSanitizer.swift                  # Core sanitization engine
├── SettingsManager.swift               # User preferences (App Group shared)
├── RecentURLsManager.swift             # Recent URL history (App Group shared)
├── ShareView.swift                     # Share Extension UI + FlowLayout
├── ShareExtensionViewController.swift  # Share Extension host controller
└── sanitizer.entitlements              # App Group entitlement

ShareExtension/
├── ShareExtensionViewController.swift  # Extension entry point
├── ShareView.swift                     # Extension UI
├── URLSanitizer.swift                  # Sanitization engine (shared copy)
├── SettingsManager.swift               # Settings (shared copy)
├── RecentURLsManager.swift             # Recent history (shared copy)
├── ShareExtension.entitlements         # App Group entitlement
└── Info.plist                          # Extension configuration

PRIVACY_POLICY.md                       # Privacy policy
```

The main app and Share Extension share data via an App Group (`group.sic.sanitizer`) so that settings and recent URL history stay in sync.

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Building

1. Clone the repository:
   ```
   git clone https://github.com/harshvasudeva/cleanitup.git
   ```
2. Open `sanitizer.xcodeproj` in Xcode
3. Select your development team in **Signing & Capabilities** for both targets (`sanitizer` and `ShareExtension`)
4. Build and run on a simulator or device

> **Note:** The Share Extension requires testing on a physical device or running in the simulator with a host app (e.g., Safari). Build the main app target first, then test sharing from Safari.

## Contributing

Contributions are welcome. Some ideas:

- Add more tracking parameters from new ad networks
- Add support for cleaning AMP URLs
- Add URL shortener expansion
- Localization for other languages
- iPad layout optimization
- macOS support

To contribute:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## Privacy

Clean it Up! does not collect, transmit, or share any data. All URL processing happens locally on your device. No analytics, no crash reporting, no third-party SDKs. See [PRIVACY_POLICY.md](../PRIVACY_POLICY.md) for the full policy.

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contact

Harsh Vasudeva — harshvasudeva11@gmail.com

GitHub: [@harshvasudeva](https://github.com/harshvasudeva)
