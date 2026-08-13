# Architecture

This document is the source of truth for the app's general code organization,
dependency boundaries, design patterns, and technical conventions. User-visible
behavior belongs in [features.md](features.md), environment setup belongs in
[ENVIRONMENT.md](ENVIRONMENT.md), and required checks belong in
[VERIFICATION.md](VERIFICATION.md).

## Layers

The app is organized into three main areas. The intended dependency flow is
from screens to feature view models, then to data abstractions and concrete
services:

```
Screen ─▶ Feature view model ─▶ Repository/interface ─▶ Concrete service
            │                       │                     │
            └──────────── Bill domain model ─────────────┘
```

1. **UI and feature logic** (`lib/ui/`): Flutter screens, shared widgets, and
  feature view models. Screens handle interaction. View models hold
  feature-specific business rules and asynchronous state.
2. **Domain** (`lib/domain/`): Plain business models. It currently contains
  `Bill` (`lib/domain/models/bill.dart`) and its hand-written SQLite map
  conversion.
3. **Data** (`lib/data/`): Repository interfaces and implementations plus
  concrete integrations for SQLite, local notifications, WorkManager, and
  SharedPreferences.

Each production screen must have one corresponding view model. The data layer
does not need a 1-to-1 match: one repository or service can support multiple
features.

### Implementation Order

The domain model, data-layer interfaces/implementations, and view-model
business logic are plain Dart and UI-agnostic — they don't depend on widgets
and are verified with the plain `test` package (not `flutter_test`), using
hand-written fakes instead of a real UI. In principle this core logic could
back a different front end (e.g. a CLI) with no changes, aside from swapping
the Flutter-plugin-backed concrete services (sqflite, flutter_local_notifications,
workmanager, shared_preferences) for non-Flutter equivalents.

When building a new feature, implement and unit-test this core logic first,
in this order, before writing any screen/widget code:

1. Domain model changes, if any (`lib/domain/`).
2. Data layer: interface, then implementation (`lib/data/repositories/`,
   `lib/data/services/`), or extend a fake under `lib/testing/fakes/` if the
   real backend isn't ready yet.
3. View model business rules and state (loading/error/data), unit-tested
   against a fake per the [Testing Conventions](#testing-conventions) below.

Only once that logic is implemented and tested should the screen
(`lib/ui/<feature>/<feature>_screen.dart`) be written to consume the view
model.

### Known deviation

`lib/ui/settings/notifications/notifications_settings_view_model.dart`
imports concrete data-layer classes directly (`BillsServiceDatabase`,
`NotificationServiceLocal`, `BackgroundServiceLocal`,
`PreferenceServiceLocal`) instead of going through a repository. This breaks
the "only talk to the layer directly below" rule. Treat this as legacy debt,
not as a pattern to copy — new features should go through a repository.

## Dependency Injection

The app uses the `provider` package (not Riverpod/get_it). All singletons are
registered in `lib/dependencies/local_providers.dart` as a
`List<SingleChildWidget>` of plain `Provider`s, cast to their interface type
(e.g. `BillsServiceDatabase() as BillsService`). This list is passed into a
`MultiProvider` in `lib/main.dart`.

Screens read dependencies with `context.read<T>()` inside `initState()` to
construct their view model — there is no app-wide `ChangeNotifierProvider`
for view models.

## MVVM Pattern

View models generally extend `ChangeNotifier` and expose `isLoading`/`error`/
data getters, following a try/catch/finally + `notifyListeners()` pattern
(see `lib/ui/home/home_view_model.dart`). There is no shared `BaseViewModel`
class — each view model is a plain, independent class.

Each `StatefulWidget` screen instantiates its own view model in `initState()`
and rebuilds the UI using `ListenableBuilder(listenable: _viewModel, ...)`.
One screen (`lib/ui/bills/edit/bills_edit_screen.dart`) instead wraps the view
model in `ChangeNotifierProvider.value` — a mixed pattern; prefer the plain
`ListenableBuilder` approach used elsewhere for new screens unless there's a
specific reason to use `ChangeNotifierProvider`.

Not every view model is a `ChangeNotifier`: `bills_create_view_model.dart` is
a plain class because bill creation has no loading/error state to observe.

All view models log through the `logging` package with a per-class named
`Logger` (e.g. `Logger('HomeViewModel')`).

## Data Layer Conventions

Every data-layer concept is split into an abstract interface file and one (or
more) concrete implementation files, named `<name>.dart` /
`<name>_<impl>.dart`, where `<impl>` identifies the storage/technology used:

| Interface | Implementation | Backing technology |
|---|---|---|
| `data/repositories/bills/bills_repository.dart` (`BillsRepository`) | `bills_repository_local.dart` (`BillsRepositoryLocal`) | composes `BillsService` + `NotificationService` |
| `data/services/database/bills_service.dart` (`BillsService`) | `bills_service_database.dart` (`BillsServiceDatabase`) | sqflite (raw SQL, no ORM/codegen) |
| `data/services/notification/notification_service.dart` (`NotificationService`) | `notification_service_local.dart` (`NotificationServiceLocal`) | flutter_local_notifications + timezone |
| `data/services/background/background_service.dart` (`BackgroundService`) | `background_service_local.dart` (`BackgroundServiceLocal`) | workmanager |
| `data/services/preference/preference_service.dart` (`PreferenceService`) | `preference_service_local.dart` (`PreferenceServiceLocal`) | shared_preferences, keyed by the `PreferenceBool` enum |

When adding a new data source, follow this same interface/impl split so
alternative implementations (e.g. a remote API) can be swapped in later
without touching the UI or domain layers.

`PreferenceBool` (`lib/data/services/preference/preference_bool.dart`)
centralizes all preference keys and their defaults (`startup`, `perBill`,
`daily`, all default `true`).

`DatabaseAccessor` (`lib/data/services/database/database.dart`) is a
singleton wrapping `sqflite.openDatabase` with a single `bills` table
(`id, name, date, notification, recurrence, paid, value`). Booleans are
stored as `0`/`1` ints. There is no code generation (no freezed/json_serializable);
`Bill` (`lib/domain/models/bill.dart`) has hand-written `copyWith`, `toMap`,
`fromMap`.

Background isolate entrypoints (e.g. the daily reminder task in
`background_service_local.dart`, marked `@pragma('vm:entry-point')`)
instantiate concrete service classes directly instead of going through
`Provider`, since a background isolate has no widget tree to read providers
from.

## UI Conventions

Screen/view-model pairs live together in a feature folder, e.g.:
```
lib/ui/bills/create/bills_create_screen.dart
lib/ui/bills/create/bills_create_view_model.dart
```
Same pattern for `lib/ui/bills/edit/`, `lib/ui/calendar/`,
`lib/ui/settings/notifications/`, `lib/ui/home/`.

Shared, reusable widgets live under `lib/ui/core/bills/` (e.g.
`bill_list_view.dart`, `bill_list_item.dart`, `bills_form.dart` — a single
form shared by create/edit via an `isEdit` flag, `text_currency_form_field.dart`).

Debug-only widgets live under `lib/ui/debug/` and are gated behind
`kDebugMode` checks at the call site (see `home_screen.dart`).

## Code Organization

- Keep each feature screen and its view model together under `lib/ui/`.
- Keep reusable bill widgets under `lib/ui/core/bills/`.
- Keep domain models under `lib/domain/`.
- Keep repository and service interfaces separate from their concrete local
  implementations.
- Register foreground dependencies through Provider in
  `lib/dependencies/local_providers.dart`.
- Preserve the local-only storage and privacy constraints defined in
  [features.md](features.md) unless the behavior specification changes first.
- Give asynchronous user actions explicit loading, success, and error
  behavior.

## Routing

Navigation uses `go_router`. Routes are centralized in
`lib/routing/routes.dart`, and the router configuration is in
`lib/routing/router.dart`.

| Screen | Route |
|---|---|
| Home | `/` |
| Create bill | `/bills/create` |
| Edit bill | `/bills/:id` |
| Calendar | `/calendar` |
| Notification settings | `/settings/notifications` |

## Supporting Runtime Packages

The main architecture packages are:

- `flutter`: UI framework.
- `provider`: Dependency injection and state propagation.
- `go_router`: Declarative navigation.
- `logging`: Named application loggers.
- `intl`: Locale-aware date and currency formatting.
- `sqflite` and `path`: SQLite persistence and database path handling.
- `flutter_local_notifications`: Local notification delivery.
- `timezone` and `flutter_timezone`: Device-timezone scheduling.
- `workmanager`: Background task registration.
- `shared_preferences`: Local preference persistence.

See `pubspec.yaml` for current package versions. The app does not use remote
push notifications; all notifications are local.

## Testing Conventions

- Unit tests use the plain `test` package (`package:test/test.dart`), not
  `flutter_test`, for view-model/logic-layer tests. Test files mirror the
  source path: `lib/ui/home/home_view_model.dart` →
  `test/ui/home/home_view_model_test.dart`.
- No mocking framework (mockito/mocktail) is used. Hand-written fakes live
  under `lib/testing/fakes/<layer>/fake_<name>.dart`, e.g.
  `lib/testing/fakes/repositories/fake_booking_repository.dart` implements
  `BillsRepository` in-memory.
- Tests use `// Arrange` / `// Act` / `// Assert` comments inside
  `test('description', () async {...})` blocks.
- Widget tests (via `flutter_test`) are intended for the UI layer and
  integration tests for the data layer, but neither currently exist in the
  repo — only logic-layer unit tests are implemented today. New UI/data-layer
  changes should add the corresponding test type per
  [VERIFICATION.md](VERIFICATION.md).

## Linting

`analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` (via
`flutter_lints ^6.0.0`) and excludes generated build and platform directories.
Do not add custom lint suppressions without a good reason; fix the underlying
issue instead.
