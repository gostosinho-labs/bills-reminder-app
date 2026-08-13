# Bills Reminder App - Current Features

This document is the source of truth for the behavior currently implemented in
the Bills Reminder Flutter app. It describes current features and known
limitations. Items under **Future Enhancement Opportunities** are not
implemented unless stated otherwise.

## Overview

Bills Reminder is a local personal-finance app. It lets users:

- Create, edit, and delete bills.
- Separate pending bills from paid bills.
- View bills in a monthly calendar.
- Schedule local bill notifications.
- Create the next occurrence of a recurring bill when the current bill is paid.

The app has no backend, account system, cloud synchronization, analytics, or
external data sharing.

## Core Features

### 1. Bill Management

#### Bill Entity

Each bill contains:

- **ID**: Local SQLite identifier.
- **Name**: Required description, such as "Electricity" or "Rent".
- **Value**: Optional monetary amount stored as a `double`. A zero value is
   stored as `null`.
- **Date**: Due date stored as an ISO 8601 string in SQLite.
- **Notification**: Whether this bill requests an individual notification.
- **Recurrence**: Whether paying this bill creates a bill for the next month.
- **Paid**: Current payment status.

#### Bill Operations

- **Create**: Add a bill with a name, value, date, notification setting,
   recurrence setting, and an initial pending status.
- **Read**: Load one bill by ID or load all bills ordered by date.
- **Edit**: Change any user-editable bill field.
- **Delete**: Delete one bill or delete all bills.
- **Pay or unpay**: Use the edit screen's **Pay Bill** or **Unpay Bill** button
   to change payment status.

#### Recurrence Behavior

Recurrence is payment-triggered. When a bill changes from pending to paid and
recurrence is enabled, the app creates one pending copy dated one month after
the paid bill. The copy retains the name, value, notification, and recurrence
settings.

The app does not generate recurring bills on a timer. Dart date overflow rules
apply to month-end dates. For example, adding one month to a date that does not
exist in the next month can move the result into the following month.

### 2. Home Screen

The home screen provides:

- **Pending and Paid tabs**: Bills are split by their `paid` value.
- **Bill lists**: Bills are loaded in ascending date order and grouped by
   month.
- **Bill rows**: Each row shows the name, localized value, formatted date,
   notification state, and recurrence state.
- **Add action**: A floating action button opens the create screen.
- **Calendar action**: A floating action button opens the calendar.
- **Menu actions**: Open notification settings, delete all bills after
   confirmation, or create sample bills in debug builds.

#### Date Indicators

- Dates use the locale's abbreviated month-and-day format, such as "Aug 12".
- The app does not display relative labels such as "today" or "tomorrow."
- An unpaid bill's date is red and bold when `bill.date` is before the current
   timestamp.
- Because bill dates normally represent midnight, an unpaid bill due today is
   highlighted after midnight as if it is due or overdue.
- The app does not use separate colors for future due-date states.

### 3. Calendar View

The calendar provides:

- A Monday-to-Sunday monthly grid.
- Previous-month and next-month buttons.
- Horizontal swipe navigation between months.
- A date picker for selecting a month and year from 2020 through 2030.
- A dot on dates that contain bills.
- A primary-color dot when at least one bill on the date is pending.
- An outline-color dot when all bills on the date are paid.
- A highlight around the current date.
- A bottom sheet listing bills when a date with bills is selected.
- A message when a selected date has no bills.
- Navigation from a bill in the bottom sheet to its edit screen.

### 4. Notification System

The app uses `flutter_local_notifications` for local notifications and
WorkManager for startup and periodic background work.

#### Initialization and Permissions

At application startup, before the main UI appears, the app:

1. Initializes timezone data and selects the device timezone.
2. Initializes the local-notification plugin.
3. Requests Android notification and exact-alarm permissions.
4. Initializes WorkManager.

On iOS, the notification plugin requests alert, badge, and sound permissions
during initialization. The app does not defer permission requests until the
user enables a notification setting. It does not provide a dedicated control
for opening or inspecting system notification settings.

#### Per-Bill Notifications

- A bill with notification enabled can receive one scheduled notification at
   08:00 on its due date.
- Creating or updating a bill schedules it only when its stored date is after
   the current timestamp.
- Updating a bill cancels its scheduled notification when its notification
   setting is off or its date is not in the future.
- Deleting a bill cancels its scheduled notification.
- Deleting all bills cancels all local notifications.
- A recurring copy is passed through normal bill creation, so it can receive a
   new scheduled notification.

#### Startup Notifications

When the startup preference is enabled, app construction registers a one-off
WorkManager task. The task loads all bills and immediately shows one
notification for each unpaid bill whose date is before the current timestamp.
Execution is asynchronous and can occur after the UI opens.

#### Setting Named "Daily Notification"

When this preference is enabled, WorkManager schedules the first execution for
the next 09:00 and then requests execution every hour. Each execution shows one
notification for every unpaid bill whose date is before the current timestamp.
It does not produce one daily summary notification.

Actual execution time remains subject to Android and iOS background scheduling
rules.

#### Notification Settings

The settings screen contains three switches. All three preferences default to
enabled.

- **On Startup**: Saves whether startup work is registered on a later app
   construction. Changing the switch does not immediately register or cancel a
   startup task.
- **Per Bill**: Saves a global preference and starts unawaited background work.
   Enabling it schedules every future bill, including bills whose own
   notification setting is off. Disabling it cancels all local notifications.
- **Daily Notification**: Saves the preference and starts unawaited background
   work to register or cancel the periodic task.

Known limitation: normal bill creation and editing do not read the global
**Per Bill** preference. A bill can therefore schedule a notification after
the global preference is disabled. Errors from the unawaited settings work are
not reported back to the settings screen.

### 5. Data Management

#### Local Storage

- SQLite stores bills in one `bills` table.
- SharedPreferences stores the three notification preferences.
- Boolean bill fields are stored as `0` or `1`.
- All app data remains on the device.
- The SQLite database is not encrypted.

#### Data Access

- The data service supports full CRUD operations.
- The database orders bill queries by date.
- Home and calendar filtering occurs in memory after all bills are loaded.
- The bill form requires a nonempty name and accepts currency digits through a
   fixed two-decimal input.
- The date picker allows dates from the first day of the current month through
   January 1 of the following year.
- View models expose loading and error state for many foreground operations,
   but error handling is not uniform across all services and background work.

## Debug Features

- **Create Sample Bills**: A debug-only home-menu action creates 15 pending,
   recurring bills in the current month.
- **Logging**: Named loggers cover feature view models, repositories, services,
   and background work.
- **Debug notification widgets**: `DebugNotifications` and
   `DebugBackgroundWork` can inspect pending notifications and WorkManager
   state.

## Storage and Privacy

- Bill data and preferences remain in local app storage.
- The app has no cloud synchronization.
- The app makes no external network requests.
- The app includes no analytics or tracking SDK.
- Notification permission requests occur during startup, not only after a
   user enables a setting.

## Future Enhancement Opportunities

The following items are not implemented:

- Cloud backup and synchronization.
- Bill categories and tags.
- Spending analytics and reports.
- Multiple currency selection.
- Bill photo attachments.
- Payment method tracking.
- Budget planning.
- Export and import.
- Home-screen widgets.
- User-selectable light and dark themes. The app currently follows the system
   theme.
- Full internationalization. The app formats dates and currency by locale, but
   UI text is hard-coded in English.
- Advanced notification schedules and user-selected reminder times.
- Database encryption.
- Dedicated accessibility behavior and tests.
- Broader error handling and automated test coverage.
- Measured performance optimization.

The app is already local and offline by design. "Offline-first architecture"
is therefore current behavior, not a future enhancement.

## Development Guidelines

### Adding or Changing Features

Treat this document as the behavior specification. Update it first when a
feature's intended behavior changes, then propagate the change to source code
and tests.

Follow the boundaries and conventions in
[`ARCHITECTURE.md`](ARCHITECTURE.md). Follow the required checks in
[`VERIFICATION.md`](VERIFICATION.md).