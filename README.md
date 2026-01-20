# GlowGuide - AI Makeup Advisor

An iOS app that provides personalized makeup recommendations based on occasion and mood.

## Project Status: MVP Scaffold Complete

### What's Built
- Complete SwiftUI views (Onboarding, Home, Result, Saved Looks)
- Data models (UserProfile, MakeupLook, ColorPalette)
- Mock service with contextual looks based on occasion + mood
- Local storage for user preferences and saved looks
- Color palette display with hex color support

### What's Next
- [ ] Backend API (Claude for advice, DALL-E for images)
- [ ] Real AI-generated recommendations
- [ ] Image generation integration
- [ ] App Store deployment

---

## Setup Instructions

### Option 1: Create Xcode Project Manually

1. **Open Xcode** → File → New → Project
2. Choose **App** → Next
3. Settings:
   - Product Name: `GlowGuide`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Uncheck "Include Tests" (for now)
4. Save to `/Users/vvx/Documents/GlowGuide/`
5. **Delete the auto-generated files** (ContentView.swift, GlowGuideApp.swift)
6. **Drag the `GlowGuide` folder** from `iOS/GlowGuide/` into Xcode
   - Choose "Create groups"
   - Check "Copy items if needed"

### Option 2: Use XcodeGen (Recommended)

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```

2. Create `project.yml` in `/Users/vvx/Documents/GlowGuide/iOS/`:
   ```yaml
   name: GlowGuide
   options:
     bundleIdPrefix: com.yourname
     deploymentTarget:
       iOS: "17.0"

   targets:
     GlowGuide:
       type: application
       platform: iOS
       sources: [GlowGuide]
       settings:
         base:
           INFOPLIST_FILE: GlowGuide/Info.plist
           PRODUCT_BUNDLE_IDENTIFIER: com.yourname.glowguide
   ```

3. Run:
   ```bash
   cd /Users/vvx/Documents/GlowGuide/iOS
   xcodegen generate
   open GlowGuide.xcodeproj
   ```

---

## File Structure

```
GlowGuide/
├── iOS/
│   └── GlowGuide/
│       ├── App/
│       │   ├── GlowGuideApp.swift      # App entry point
│       │   └── AppState.swift          # Global state management
│       │
│       ├── Models/
│       │   ├── Enums.swift             # SkinTone, Occasion, Mood, etc.
│       │   ├── MakeupLook.swift        # Look data model
│       │   └── UserProfile.swift       # User preferences
│       │
│       ├── Services/
│       │   └── LookGeneratorService.swift  # Mock API service
│       │
│       ├── Features/
│       │   ├── Onboarding/
│       │   │   └── OnboardingView.swift
│       │   ├── Home/
│       │   │   └── HomeView.swift
│       │   ├── Result/
│       │   │   └── LookResultView.swift
│       │   └── SavedLooks/
│       │       └── SavedLooksView.swift
│       │
│       └── Components/
│           └── ColorSwatchView.swift
│
└── README.md
```

---

## User Flow

```
Onboarding (first launch)
    ├── Select Skin Tone
    └── Select Style Preference
           ↓
Home Screen
    ├── Select Occasion (Business, Date, Party, etc.)
    └── Select Mood (Confident, Fresh, Mysterious, etc.)
           ↓
     [Get My Look]
           ↓
Result Screen
    ├── Look Name & Vibe
    ├── Color Palette (Eyes, Lips, Blush, Brows)
    └── Step-by-Step Guide
           ↓
    [Save] or [Try Another]
```

---

## Tech Stack

- **iOS**: SwiftUI, Swift 5.9+
- **Minimum iOS**: 17.0
- **State Management**: @StateObject, @EnvironmentObject
- **Storage**: UserDefaults (MVP), migrate to Core Data later

---

## Future Backend (Phase 2)

```
POST /api/generate-look
{
  "skinTone": "medium",
  "occasion": "dateNight",
  "mood": "confident"
}

Response:
{
  "lookName": "Sultry Siren",
  "vibe": "Bold & Seductive",
  "colorPalette": {...},
  "steps": [...],
  "imageUrl": "https://..."  // DALL-E generated
}
```

---

## Development Notes

- All looks are currently mock data in `LookGeneratorService.swift`
- The service has contextual responses for different occasion + mood combinations
- Colors are stored as hex strings and converted to SwiftUI Color
- User profile persists across app launches via UserDefaults
