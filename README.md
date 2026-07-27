# Culture Map - Historical Cultural Heritage Explorer

A Flutter-based historical cultural heritage exploration app with complete GPS navigation features.

## ✨ Core Features

### 📍 Map Exploration
- Display global historical and cultural heritage landmarks
- Integrated Wikidata data source
- Fetch real content and images from Wikipedia
- Vintage parchment-style UI design

### 🧭 Complete Navigation System
- **Three Navigation Modes**: Walking 🚶 / Cycling 🚴 / Driving 🚗
- **Real-time GPS Positioning**: High-precision tracking, updates every 5 meters
- **Real Route Planning**: Uses OSRM API to fetch actual roads
- **Turn-by-turn Guidance**: Voice prompts (turn left, turn right, etc.)
- **Auto Map Rotation**: Heading-up mode, map follows your orientation
- **Voice Navigation**: Full voice guidance via TTS
- **Screen Wakelock**: Auto keep screen on during navigation

### 🎨 UI Design
- Vintage parchment theme (inspired by "One Hundred Years of Solitude")
- Crimson Text font (body text)
- Cinzel font (titles)
- Burgundy red + gold color scheme

### 💾 Backend Features
- Supabase user authentication
- Bookmark collection system
- Comment system
- User profile management

### 📱 User Features
- Rate and review landmarks
- View community comments
- Save favorite places
- Track exploration statistics
- Level progression system

## 🚀 Quick Start

### Requirements
- Flutter SDK >=3.0.0
- Android Studio / Xcode
- Android device (for full navigation features)

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
# Web preview (limited navigation)
flutter run -d chrome

# Android phone (full features)
flutter run
```

### Build APK
```bash
flutter build apk --release
```

## 📦 Main Dependencies

| Package | Purpose |
|-----|------|
| flutter_map | Map display |
| geolocator | GPS positioning |
| flutter_tts | Voice prompts |
| wakelock_plus | Screen wakelock |
| supabase_flutter | Backend service |
| google_fonts | Font support |
| http | API requests |
| image_picker | Profile photo upload |
| cached_network_image | Image caching |

## 📱 Permissions

The app requires the following permissions:
- **Location** - Required for GPS navigation
- **Background Location** - For continuous navigation
- **Network** - Load maps and data
- **Screen Wakelock** - Keep screen on during navigation
- **Storage** - Save profile photos (mobile only)

## 🗺️ Navigation Features

### Usage Flow
1. Tap a landmark card on the map
2. Click the "Navigate" button
3. Choose navigation mode (walking/cycling/driving)
4. Follow the map and voice instructions

### Key Features
- ✅ Real-time position updates (every 5 meters)
- ✅ Real road route planning
- ✅ Turn-by-turn instructions
- ✅ Voice alerts 50-100 meters in advance
- ✅ Arrival notification within 50 meters
- ✅ Estimated arrival time calculation
- ✅ Compass direction indicator

## 📂 Project Structure

```
lib/
├── main.dart                          # Main app entry, map page
├── navigation_page.dart               # Navigation page (core feature)
├── landmark_preview_card.dart         # Landmark card component
├── landmark_detail_page_new.dart      # Landmark detail page
├── my_drafts_page.dart                # User contributions page
├── saved_places_page.dart             # Saved places page
├── edit_profile_page.dart             # Profile editing page
├── comments_page.dart                 # Comments view page
├── solitude_explorer_theme.dart       # Theme configuration
└── l10n/                              # Localization files
    ├── app_en.arb                     # English translations
    └── app_zh.arb                     # Chinese translations
```

## 🔧 Configuration

### Supabase Setup
Configure your Supabase project in `lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

### Map Tiles
Uses OpenStreetMap by default:
```dart
urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
```

### Routing API
Uses free OSRM API:
```
https://router.project-osrm.org/route/v1/{profile}/...
```

## 🌐 Internationalization

The app supports multiple languages and automatically adapts to your device's system language:
- English (en)
- Chinese (zh)

All UI text is localized, including:
- Navigation instructions
- Menu items
- Buttons and labels
- Error messages
- Level titles

To add a new language, create a new `.arb` file in `lib/l10n/` directory.

## ⚠️ Important Notes

### Web Browser Limitations
- ❌ Cannot get real GPS position
- ❌ Cannot get device orientation
- ❌ Map rotation feature unavailable

**Conclusion: Navigation features require Android/iOS device!**

### Device Requirements
- ✅ GPS hardware required
- ✅ Compass sensor required
- ✅ Network connection required
- ✅ Recommended to test outdoors (GPS signal)

## 🐛 Troubleshooting

### GPS Not Working
1. Confirm GPS is enabled
2. Go to an open outdoor area
3. Check app location permissions

### Route Planning Failed
1. Check network connection
2. Ensure destination is not too close (>100m)

### Voice Not Working
1. Check volume settings
2. Ensure voice toggle is on (top-right 🔊)

## 🚀 Deployment

This app is deployed on GitHub Pages at:
https://yserena60-yyy.github.io/culture_map/

The deployment is automated via GitHub Actions on every push to the main branch.

## 📄 License

MIT License

## 👥 Contributing

Issues and Pull Requests are welcome!

## 📞 Contact

For questions or suggestions, please submit an Issue.

---

**Enjoy your cultural exploration journey!** 🗺️✨
