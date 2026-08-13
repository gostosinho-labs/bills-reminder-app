# AGENTS.md

## Overview

Bills Reminder is a Flutter app for tracking and managing personal bills. It
lets users create bills with a name, optional value, and due date, mark them
paid, view them in a calendar, and get notified via three configurable
notification types (startup, per-bill, daily). All data is stored locally
(SQLite + SharedPreferences) — there is no backend, cloud sync, or analytics.

For current behavior, user workflows, and the project summary, see
[FEATURES.md](docs/features.md), [WORKFLOWS.md](docs/WORKFLOWS.md), and
[README.md](README.md).

## Documentation Map

| File | Purpose |
|---|---|
| [README.md](README.md) | Project pitch, screenshots, quick start |
| [FEATURES.md](docs/features.md) | Current behavior and known limitations |
| [WORKFLOWS.md](docs/WORKFLOWS.md) | Current user workflows |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Code organization, layers, conventions, known deviations |
| [ENVIRONMENT.md](docs/ENVIRONMENT.md) | SDK/tooling setup, dependency management |
| [VERIFICATION.md](docs/VERIFICATION.md) | How to test, analyze, and build the app before finishing a task |

## Key Source Locations

- Entry point: `lib/main.dart`
- Dependency injection: `lib/dependencies/local_providers.dart`
- Routing: `lib/routing/router.dart`, `lib/routing/routes.dart`
- Domain model: `lib/domain/models/bill.dart`
- Data layer: `lib/data/repositories/`, `lib/data/services/`
- UI layer (screens + view models): `lib/ui/`
- Shared UI widgets: `lib/ui/core/`
- Debug-only screens: `lib/ui/debug/`
- Test fakes: `lib/testing/fakes/`
- Tests: `test/`
- CI pipeline: `.github/workflows/build-and-publish.yml`

## Working on This Project

1. Read [ARCHITECTURE.md](docs/ARCHITECTURE.md) before adding or changing code —
   it describes the mandatory 3-layer structure (UI → Domain/logic → Data)
   and naming conventions to follow.
2. Read [VERIFICATION.md](docs/VERIFICATION.md) and run the listed checks
   (`flutter analyze`, `flutter test`, build) before considering any task done.
   CI does **not** run analyze/test, so this is the developer's/agent's
   responsibility.
