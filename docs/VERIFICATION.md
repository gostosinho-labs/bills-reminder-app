# Verification

**All code changes must be verified using the steps below before a task is
considered done.** The CI pipeline (`.github/workflows/build-and-publish.yml`)
only builds release APK/IPA artifacts — it does **not** run `flutter analyze`
or `flutter test`. Verification is the developer's/agent's responsibility,
not CI's.

Run these from the repo root, in this order:

## Testing and Verification Status

The repository currently contains one test file with two unit tests for
`HomeViewModel`. It has no widget tests and no data-layer integration tests.
Notification delivery has no automated device-level coverage.

As of August 12, 2026:

- Static analysis reports no errors.
- Both existing unit tests pass.

## Testing Requirements for New Work

- Add widget tests for new or changed screen behavior.
- Add unit tests for new or changed view-model behavior.
- Add integration tests for new or changed data-layer behavior.
- Add a regression test for each bug fix.
- Use hand-written fakes under `lib/testing/fakes/` instead of a mocking
  framework unless the project standard changes.
- Run `flutter analyze` and `flutter test` before completion.
- Perform device-level checks for notification or platform changes that unit
  and widget tests cannot validate.

## 1. Get dependencies

```
flutter pub get
```

## 2. Static analysis (lint)

```
flutter analyze
```

Fix all reported issues. `analysis_options.yaml` uses the default
`flutter_lints` ruleset (see `ARCHITECTURE.md`) — do not add suppressions to
silence a warning without a good reason; fix the underlying code instead.

## 3. Unit tests

```
flutter test
```

This runs everything under `test/`. Today that's only logic-layer
(view-model) tests written with the plain `test` package, e.g.
`test/ui/home/home_view_model_test.dart`. `flutter test` runs both
`flutter_test` widget tests and plain `test`-package tests, so this single
command is sufficient.

When adding or changing a view model, add/update its unit test following the
existing convention:
- Mirror the source path under `test/` (e.g.
  `lib/ui/foo/foo_view_model.dart` → `test/ui/foo/foo_view_model_test.dart`).
- Use `// Arrange` / `// Act` / `// Assert` comments inside
  `test('description', () async { ... })`.
- Don't add a mocking library — use or extend a hand-written fake under
  `lib/testing/fakes/` (see `lib/testing/fakes/repositories/fake_booking_repository.dart`).

## 4. Widget tests (UI layer)

New or changed screen behavior requires widget tests (`flutter_test`). None
exist in the repo yet. When you add the first one, place it under
`test/ui/<feature>/` mirroring the screen's path. `flutter test` will pick it
up automatically.

## 5. Integration tests (data layer)

New or changed data-layer behavior in repositories or services requires
integration tests. None exist in the repo yet. If you add the
`integration_test` package and tests, run them with:

```
flutter test integration_test
```

## 6. Compilation / build check

Confirm the app still builds for at least one platform before finishing a
task that touches non-trivial code (new dependencies, platform channels,
native config changes, etc.):

```
flutter build apk --debug
```

Use `flutter build ios --debug --no-codesign` instead/also if the change
touches iOS-specific code or plugin configuration. For quick changes that
only affect a single screen's Dart code, `flutter analyze` + `flutter test`
is normally enough; reserve the build step for changes where analyze/test
wouldn't catch a break (e.g. native manifest/plist edits, new plugin
dependencies).

## 7. Manual smoke check (when relevant)

For UI changes, run the app (`flutter run`) and manually exercise the
affected screen(s), since widget test coverage is currently sparse. Pay
attention to:
- Debug-only menu items in `lib/ui/debug/` (only visible in debug builds).
- Notification scheduling/cancellation, since it depends on device timezone
  and OS-level permissions that are hard to fully cover with unit tests.

Perform a device-level check for notification and platform changes whenever
automated tests cannot validate the platform behavior.

## Summary Checklist

Before declaring a task complete, confirm:

- [ ] `flutter pub get` succeeds
- [ ] `flutter analyze` reports no issues
- [ ] `flutter test` passes
- [ ] New/changed view models have unit tests
- [ ] New/changed screens have widget tests
- [ ] New/changed data-layer code has integration tests
- [ ] Bug fixes have regression tests
- [ ] The app still builds (`flutter build apk --debug`, and
      `flutter build ios --debug --no-codesign` if iOS-relevant) when the
      change could plausibly break compilation beyond what analyze/test cover
