# smart_fee

A fully offline, student-side app for managing school fees payment reminders.
It does **not** process payments and does **not** connect to any school
payment portal — it only tracks due dates, sends local notifications, and
keeps a history of what's been marked paid.

## Features implemented

- Optional local user/student profile (stored on-device only, no account/server)
- Add / edit / delete fee reminders
- Schedule local notifications (no internet required) via `flutter_local_notifications`
- Upcoming reminders view (sorted by soonest due date)
- Full reminder history (paid + unpaid, newest first)
- Mark reminders as paid / unpaid
- Search reminders by title, description, or amount
- 100% offline persistence using `shared_preferences` (JSON-encoded local storage)

## Architecture

```
lib/
 ├── main.dart                     # App entry, MultiProvider setup
 ├── models/
 │    ├── reminder.dart            # Reminder data model (+ JSON (de)serialization)
 │    └── user_profile.dart        # Optional local user profile model
 ├── providers/
 │    ├── reminder_provider.dart   # ChangeNotifier: CRUD, search, paid state
 │    └── user_provider.dart       # ChangeNotifier: local profile registration
 ├── services/
 │    ├── storage_service.dart     # shared_preferences read/write (offline)
 │    └── notification_service.dart# flutter_local_notifications wrapper
 ├── screens/
 │    ├── home_screen.dart
 │    ├── upcoming_reminders_screen.dart
 │    ├── reminder_history_screen.dart
 │    ├── add_edit_reminder_screen.dart
 │    ├── search_screen.dart
 │    └── profile_screen.dart
 └── widgets/
      └── reminder_card.dart
```

State management uses the **provider** package exclusively:
- `ReminderProvider` (ChangeNotifier) owns the list of reminders and exposes
  derived getters (`upcomingReminders`, `history`, `searchResults`, etc.).
- `UserProvider` (ChangeNotifier) owns the optional local profile.
- Widgets read state with `context.watch<T>()` / `Consumer<T>` and mutate it
  with `context.read<T>()`, so the UI updates automatically after every change.

## Getting started

1. Install Flutter (stable channel) — https://docs.flutter.dev/get-started/install
2. From the project root:
   ```bash
   flutter pub get
   flutter run
   ```

### Android notification permissions
`android/app/src/main/AndroidManifest.xml` already declares the permissions
needed for exact-alarm local notifications (`POST_NOTIFICATIONS`,
`SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`) and the boot receivers
required by `flutter_local_notifications` so reminders survive a device
restart.

### iOS
No extra setup is required beyond what `flutter_local_notifications`
documents — the app requests alert/badge/sound permission on first launch
(see `NotificationService.init()`).

## Notes on scope

- No network calls are made anywhere in the codebase.
- No payment processing, gateways, or school portal integrations are included,
  per the proposal — the app is a reminder/tracking tool only.
- Notification scheduling defaults to "1 day before the due date" but is
  user-adjustable per reminder from the Add/Edit screen.

## Suggested next steps (not included, for future scope)

- SQLite (`sqflite`) migration if reminder volume grows large
- Recurring/termly reminder templates
- Data export/import (e.g. CSV) for backup
- Biometric lock for the local profile
