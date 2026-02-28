# URL Sanitizer - UI Specification

## Main App Interface

### Home Screen Layout

```
┌─────────────────────────────┐
│  ← URL Sanitizer            │  ← Navigation Bar
├─────────────────────────────┤
│                             │
│  HOW IT WORKS               │
│  ┌─────────────────────────┐│
│  │ 📤 Share from any app   ││
│  │                         ││
│  │ Use the Share button to ││
│  │ clean links and remove  ││
│  │ tracking parameters     ││
│  └─────────────────────────┘│
│                             │
│  SETTINGS                   │
│  ┌─────────────────────────┐│
│  │ Aggressive Cleaning  ◯  ││
│  │ May remove non-essential││
│  │ parameters              ││
│  │                         ││
│  │ Expand Shortened     ◯  ││
│  │ Links                   ││
│  │ Follows redirects       ││
│  └─────────────────────────┘│
│                             │
│  RECENTLY CLEANED    [Clear]│
│  ┌─────────────────────────┐│
│  │ example.com/page        ││
│  │ 2 minutes ago • 3 rem.  ││
│  ├─────────────────────────┤│
│  │ youtube.com/watch?v=... ││
│  │ 5 minutes ago • 1 rem.  ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

### Features:
- ✅ Clean, minimal design
- ✅ Native iOS components
- ✅ Dynamic Type support
- ✅ Dark mode adaptive
- ✅ Tap recent URL to copy
- ✅ Haptic feedback on copy

---

## Share Extension Interface

### Initial Loading State

```
┌─────────────────────────────┐
│  Close              ⓧ       │  ← Navigation Bar
├─────────────────────────────┤
│                             │
│  🔗 Sanitize Link           │  ← Header
│     Tracking parameters     │
│     removed                 │
│                             │
├─────────────────────────────┤
│                             │
│         ⏳                  │
│                             │
│    Cleaning link…           │
│                             │
│                             │
└─────────────────────────────┘
```

### Success State (Clean URL Found)

```
┌─────────────────────────────┐
│  Close              ⓧ       │
├─────────────────────────────┤
│                             │
│  🔗 Sanitize Link           │
│     3 tracking parameters   │
│     removed                 │
│                             │
├─────────────────────────────┤
│  CLEAN URL                  │
│  ┌─────────────────────────┐│
│  │ https://example.com/    ││
│  │ page?id=123             ││
│  │                         ││ ← Monospaced
│  └─────────────────────────┘│  ← Selectable
│  [Show More]                │
│                             │
│  ┌───────────┐ ┌───────────┐│
│  │   Copy    │ │   Share   ││ ← Primary
│  └───────────┘ └───────────┘│    Actions
│                             │
│  ┌─────────────────────────┐│
│  │ Aggressive Cleaning  ◯  ││ ← Toggle
│  │ May remove non-         ││
│  │ essential parameters    ││
│  └─────────────────────────┘│
│                             │
│  REMOVED PARAMETERS         │
│  ┌─────────────────────────┐│
│  │ utm_source  fbclid      ││ ← Tags
│  │ gclid                   ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

### Success State (URL Already Clean)

```
┌─────────────────────────────┐
│  Close              ⓧ       │
├─────────────────────────────┤
│                             │
│  🔗 Sanitize Link           │
│     No tracking parameters  │
│     found                   │
│                             │
├─────────────────────────────┤
│  CLEAN URL                  │
│  ┌─────────────────────────┐│
│  │ https://example.com/    ││
│  │ page                    ││
│  └─────────────────────────┘│
│                             │
│  ┌───────────┐ ┌───────────┐│
│  │   Copy    │ │   Share   ││
│  └───────────┘ └───────────┘│
│                             │
│  ✅ This URL is already     │
│     clean!                  │
│                             │
└─────────────────────────────┘
```

### Error State

```
┌─────────────────────────────┐
│  Close              ⓧ       │
├─────────────────────────────┤
│                             │
│                             │
│         ⚠️                  │
│                             │
│    No valid URL found       │
│                             │
│                             │
│    ┌─────────────┐          │
│    │    Close    │          │
│    └─────────────┘          │
│                             │
│                             │
└─────────────────────────────┘
```

---

## Color Palette

### Light Mode
- **Background**: System Background (white)
- **Secondary Background**: System Secondary Background (light gray)
- **Primary Text**: Label (black)
- **Secondary Text**: Secondary Label (gray)
- **Accent**: System Blue
- **Success**: System Green
- **Warning**: System Orange
- **Error**: System Red

### Dark Mode
- **Background**: System Background (black)
- **Secondary Background**: System Secondary Background (dark gray)
- **Primary Text**: Label (white)
- **Secondary Text**: Secondary Label (light gray)
- All other colors adapt automatically

---

## Typography

### Fonts
- **Title**: System Bold, 17pt
- **Body**: System Regular, 17pt (Dynamic Type)
- **Caption**: System Regular, 12pt
- **Monospaced URLs**: System Monospaced, 15pt

### Dynamic Type Support
All text scales with user's accessibility settings:
- ✅ Extra Small → Extra Extra Large
- ✅ Accessibility sizes supported

---

## Interactions

### Main App

| Action | Feedback | Result |
|--------|----------|--------|
| Tap Recent URL | Success haptic | Copy to clipboard + Alert |
| Toggle Setting | Selection haptic | Setting saved |
| Tap Clear | None | Confirmation (if needed) |

### Share Extension

| Action | Feedback | Result |
|--------|----------|--------|
| Tap Copy | Success haptic | Copy + Auto-close (500ms) |
| Tap Share | None | System share sheet |
| Toggle Aggressive | Selection haptic | Re-sanitize URL |
| Tap Show More/Less | None | Expand/collapse text |
| Tap Close | None | Dismiss extension |

---

## Accessibility

### VoiceOver Labels

**Main App**:
- Settings toggles: "Aggressive cleaning, off/on, switch"
- Recent URLs: "Cleaned URL, [domain], [time], [count] parameters removed, button"

**Share Extension**:
- Copy button: "Copy cleaned URL to clipboard"
- Share button: "Share cleaned URL"
- Close button: "Close and return"

### Dynamic Type
- All text respects user's preferred reading size
- Layout adjusts automatically
- No text truncation at larger sizes

### High Contrast
- All colors meet WCAG AA standards (4.5:1)
- System colors adapt in High Contrast mode
- No information conveyed by color alone

### Reduced Motion
- No decorative animations
- Essential state transitions remain
- Respects user's motion preferences

---

## Component Specifications

### Button Styles

**Primary (Copy)**:
- Style: `.borderedProminent`
- Size: `.large`
- Icon: `doc.on.doc`
- Full width in container

**Secondary (Share)**:
- Style: `.bordered`
- Size: `.large`
- Icon: `square.and.arrow.up`
- Full width in container

**Tertiary (Close, Show More)**:
- Style: `.plain` or default
- Size: `.regular`
- Context-appropriate placement

### Toggle Style
- Native iOS toggle
- Label on left, control on right
- Caption below label for description

### Text Fields
- Background: Secondary system background
- Corner radius: 8pt
- Padding: 12pt
- Monospaced font for URLs
- Text selection enabled

### List Rows
- Height: Dynamic (fits content)
- Separator: System default
- Background: System background
- Tap highlight: System default

---

## Animation Timing

| Element | Duration | Curve |
|---------|----------|-------|
| URL expansion | 200ms | ease-in-out |
| Loading spinner | Continuous | linear |
| Copy → Close | 500ms | ease-out |
| Setting change | 150ms | ease-in-out |
| List updates | 300ms | spring |

---

## Platform Support

### iOS
- Minimum: iOS 16.0
- Optimized: iOS 17+
- Device: iPhone only (portrait)

### Screen Sizes
- iPhone SE (3rd gen): 4.7" - Minimum
- iPhone 15 Pro Max: 6.7" - Maximum
- All sizes supported with adaptive layout

### Orientations
- Portrait: ✅ Supported
- Landscape: ⚠️ Optional (recommended portrait only)

---

## Share Sheet Integration

### Appearance in Share Menu

```
┌─────────────────────────────┐
│  Share                      │
│                             │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐   │
│  │ ✉️│ │ 💬│ │ 📋│ │ 🔗│   │  ← Your app icon here
│  │MSG│ │AirD│ │Cpy│ │San│   │     with "Sanitize Link"
│  └───┘ └───┘ └───┘ └───┘   │
│                             │
└─────────────────────────────┘
```

### Accepted Content Types
1. **URLs** (`public.url`)
   - Direct URL objects from browsers
   - Most common scenario

2. **Plain Text** (`public.plain-text`)
   - Text containing URLs
   - Extracts first valid URL found

### Activation Rule
- Accepts: 1 URL OR text containing URL
- Rejects: Multiple URLs, images, files

---

## User Flow

### Primary Use Case: Clean from Safari

```
1. User browsing in Safari
   ↓
2. Taps Share button (toolbar)
   ↓
3. Scrolls to find "Sanitize Link"
   ↓
4. Taps app icon
   ↓
5. Extension opens (< 300ms)
   ↓
6. URL instantly cleaned and displayed
   ↓
7. Taps "Copy"
   ↓
8. Haptic feedback + Extension closes
   ↓
9. User pastes clean URL elsewhere
```

### Secondary Use Case: Settings Change

```
1. User opens main app
   ↓
2. Toggles "Aggressive Cleaning" on
   ↓
3. Setting saved
   ↓
4. Next time in Share Extension
   ↓
5. Aggressive cleaning applied automatically
```

---

## Performance Targets

| Metric | Target | Maximum |
|--------|--------|---------|
| Extension launch | < 200ms | 500ms |
| URL sanitization | < 50ms | 300ms |
| Copy to clipboard | < 10ms | 50ms |
| Settings save | < 10ms | 50ms |

---

## Privacy Features

### What We DON'T Do
- ❌ No network requests (except optional expand)
- ❌ No analytics or tracking
- ❌ No clipboard monitoring
- ❌ No background execution
- ❌ No third-party SDKs
- ❌ No user accounts
- ❌ No remote storage

### What We DO
- ✅ Process URLs locally only
- ✅ Store recent URLs on device
- ✅ Use App Groups for settings
- ✅ Respect user privacy settings
- ✅ Clear data on demand

---

This specification ensures a clean, fast, privacy-focused user experience that meets App Store guidelines.
