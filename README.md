# CultureMap

A Flutter app for discovering and collecting historical and cultural landmarks. Built around a vintage manuscript aesthetic inspired by *One Hundred Years of Solitude*, CultureMap turns cultural exploration into a personal, gamified journey.

**Live demo:** https://yserena60-yyy.github.io/culture_map/

---

## Features

**Interactive Map**
Mapbox-powered map that surfaces nearby cultural landmarks — temples, museums, heritage sites, monuments — automatically sourced from Wikidata and Wikipedia. Each landmark type gets a distinct icon derived from Wikidata's instance-of data.

**Landmark Detail**
Each site includes a historical summary, photos, a timeline view showing the site across different eras, community ratings, and user-written travel stories.

**Cultural Passport**
A stamp-collection system tied to real-world visits. Check in at a landmark to unlock its unique passport stamp and track your exploration history.

**Curated Routes**
Themed itineraries that guide users through a sequence of related cultural sites — from ancient trade routes to colonial architecture trails.

**Community**
Users can post travel stories, comment on landmarks, save favourite places, and progress through an XP and level system as they explore.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Web + Android + iOS) |
| Map | Mapbox, flutter_map |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| Landmark Data | Wikidata SPARQL, Wikipedia REST API |
| Fonts | Google Fonts — Crimson Text, Cinzel, Noto Serif SC |
| Localisation | flutter_localizations, flutter gen-l10n |

---

## Getting Started

**Requirements:** Flutter SDK ≥ 3.0.0

```bash
# Install dependencies
flutter pub get

# Run in browser
flutter run -d chrome

# Build for web
flutter build web --no-tree-shake-icons

# Build APK
flutter build apk --release
```

---

## Configuration

Set your own keys in `lib/main.dart` before running:

```dart
// Supabase
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';

// Mapbox
const String mapboxAccessToken = 'YOUR_MAPBOX_TOKEN';
const String mapboxStyleUrl = 'YOUR_MAPBOX_STYLE_URL';
```

---

## Project Structure

```
lib/
├── main.dart                     # App entry, map page, Wikidata integration
├── locale_controller.dart        # Global language state (ValueNotifier)
├── supabase_service.dart         # All Supabase queries
├── models.dart                   # Data models
├── solitude_explorer_theme.dart  # Theme colours and typography
├── stamp_detail_sheet.dart       # Passport stamp detail
├── check_in_sheet.dart           # Check-in flow
├── landmark_detail_page_new.dart # Landmark detail page
├── landmark_preview_card.dart    # Map bottom-sheet card
├── settings_page.dart            # App settings
├── language_settings_page.dart   # Language selection
└── l10n/
    ├── app_en.arb                # English strings
    └── app_zh.arb                # Chinese strings
```

---

## Deployment

Deployed automatically to GitHub Pages via GitHub Actions on every push to `main`.

---

## License

MIT
