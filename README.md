# Waypoint

An AI travel ranking app. You ask a question ("top 10 romantic restaurants in Rome"), Waypoint always answers with exactly ten, ranked, with the reason each one beats the next and the sources behind it. Never a star rating you have to take on faith.

## Why

- Travel decisions are infrequent, expensive, and cut across too many fragmented sources (Skyscanner, Booking, Tripadvisor, Maps)
- Review trust is eroding: Tripadvisor reported roughly 8% of its 2024 reviews as fake, and review-boosting accounts for over half of detected fraud
- Waypoint's answer: a hard limit of ten results, each with a reasoned, sourced explanation

## Features

- Natural-language query → up to 10 ranked results, each with a real description (what it is, why it's ranked where it is, what not to miss), never a bare star rating
- A real photo and a static map on the detail screen, resolved via Google Places (optional)
- Local, on-device search history shown inline below the search box; tapping a past search reopens it without a new API call
- Localized in English, Spanish, and French
- Product analytics (Amplitude, optional)

## Architecture

Clean Architecture, layer-first, following [Flutter's own architecture guide](https://docs.flutter.dev/app-architecture/guide):

```
lib/
  domain/     interfaces + entities, no I/O (ranking/, history/, places/, analytics/)
  data/       implementations of those interfaces (ranking/, history/, places/, analytics/, services/)
  ui/
    design_system/   atoms + theming, presentation only
    screens/          one folder per screen: <screen>_screen.dart, its own
                       <screen>_view_model.dart, and (where it tracks anything)
                       a <screen>_analytics.dart wrapper
  l10n/       generated from lib/l10n/*.arb
```

MVVM: one ViewModel per screen. State: Riverpod.

## Tech stack

Flutter · [Riverpod](https://pub.dev/packages/flutter_riverpod) (state + DI) · [Dio](https://pub.dev/packages/dio) (networking) · [shared_preferences](https://pub.dev/packages/shared_preferences) (local history) · [url_launcher](https://pub.dev/packages/url_launcher) · [amplitude_flutter](https://pub.dev/packages/amplitude_flutter) (optional analytics) · [mocktail](https://pub.dev/packages/mocktail) for tests · fonts (Archivo, Onest) bundled as assets, not fetched at runtime, so tests never depend on the network.

## Running locally

Requirements: Flutter 3.13+ (Dart SDK ^3.13.0), an iOS simulator/device or Android emulator/device.

```bash
git clone <repo-url> waypoint
cd waypoint
flutter pub get
```

Waypoint needs an OpenAI API key to generate rankings. Get one at [platform.openai.com](https://platform.openai.com/api-keys), then run with it as a `--dart-define` — never hardcode it in source:

```bash
flutter run --dart-define=OPENAI_API_KEY=sk-...
```

Two more keys are optional — the app runs exactly the same without either, just with a placeholder instead of a photo/map, or with no analytics tracked:

```bash
flutter run \
  --dart-define=OPENAI_API_KEY=sk-... \
  --dart-define=GOOGLE_PLACES_API_KEY=AIza... \
  --dart-define=AMPLITUDE_API_KEY=...
```

- `GOOGLE_PLACES_API_KEY`: Text Search (New) + Maps Static API enabled, both billed under the same key — adds a real photo and map to the detail screen.
- `AMPLITUDE_API_KEY`: an Amplitude project's API key — enables event tracking.

## Known limitations

- gpt-5-nano isn't fully deterministic: the exact same query can come back with slightly different item phrasing across separate calls. History doesn't try to detect "this is the same search as before" — an exact repeat creates a separate entry.
- No automatic retry on a failed search — a manual back-and-retry is the only path today.
- History is local-only and per-device (`shared_preferences`), no account, no sync.

## Future work

Ideas that are out of scope for now but worth naming rather than pretending they were never considered:

- **Deterministic re-runs.** Cache by the input (query + locale), not the output, so repeating the exact same search returns the exact same result instead of a fresh (and possibly differently-worded) one, and doesn't create a new history entry.
- **An interactive map that opens the native Maps app** — would add a second tappable target and a second failure mode; worth it only with a clearer idea of what it should do beyond what tapping a source link already does.
- **Search parameters / trip context** (traveling as a couple, with friends, for business, solo) that bias the ranking and its reasoning, not just the query text.
- **Save / share a ranking**, and an account to keep it across devices — would need a backend (Firebase was the original candidate) that this build deliberately doesn't have.
