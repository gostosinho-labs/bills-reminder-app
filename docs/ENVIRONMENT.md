# Environment

## Requirements

- Flutter SDK compatible with Dart `^3.8.1` (see `environment.sdk` in
  `pubspec.yaml`). Use the `stable` channel (matches CI, see
  `.github/workflows/build-and-publish.yml`).
- Dart SDK (bundled with Flutter).
- Android Studio or VS Code with the Flutter/Dart extensions, for editing
  and running on emulators/devices.
- Xcode, if building/running for iOS.

Check your installed version against the project's constraint:

```
flutter --version
```

## First-Time Setup

```
git clone https://github.com/gostosinho-labs/bills-reminder-app.git
cd bills-reminder-app
flutter pub get
```

Run the app on a connected device or simulator:

```
flutter run
```

## Managing Dependencies

To update the pub packages to the latest versions allowed by the constraints
in `pubspec.yaml`, run:

```
flutter pub upgrade
```

To add a new dependency, edit `pubspec.yaml` and run `flutter pub get`.
Prefer adding the narrowest version constraint that matches the current style
(caret constraints, e.g. `^6.1.2`).

`pubspec.lock` is committed to the repo — do not hand-edit it; let
`flutter pub get`/`upgrade` regenerate it, and commit the resulting diff.

### Key runtime dependencies

| Purpose | Package |
|---|---|
| Routing | `go_router` |
| Logging | `logging` |
| State management / DI | `provider` |
| Formatting/i18n | `intl` |
| Local database | `sqflite`, `path` |
| Local notifications | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Background tasks | `workmanager` |
| Key-value storage | `shared_preferences` |

### Key dev dependencies

| Purpose | Package |
|---|---|
| Widget testing | `flutter_test` (SDK) |
| Lint ruleset | `flutter_lints` |
| Plain unit testing | `test` |
| App icon generation | `flutter_launcher_icons` |

## App Icons

App icons are generated from `assets/icon/` via `flutter_launcher_icons`
(config lives at the bottom of `pubspec.yaml`). After changing the source
images, regenerate platform icons with:

```
dart run flutter_launcher_icons
```

## Wireless Android Debugging

`scripts/debug.sh` contains `adb pair`/`adb connect` commands for debugging
over Wi-Fi on Android. Edit the placeholder host/port/pairing code in the
script before use.

## Platforms

The repo contains `android/` and `ios/` platform folders. There is no web,
desktop, or Linux/Windows platform configured — this is a mobile-only app.
