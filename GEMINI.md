# Muslim Mate — Architecture Guide
---

## Architecture

**Feature-first architecture — no use case layer.**

Repositories are called directly from Cubits.

```text
lib/features/<feature>/
  domain/
    entities/
    repositories/

  data/
    models/
    sources/
    repositories/

  presentation/
    cubit/
    pages/
    widgets/
```

---

## Project Structure

```text
lib/
  app/
    router/

  core/
    constants/
    theme/
    network/
    services/
    storage/
    utils/
    errors/
    extensions/

  shared/
    widgets/
    helpers/
    enums/

  features/
    home/
    prayer/
    quran/
    dzikir/
    profile/
```

---

## Feature Rules

Each feature must be isolated.

Do not:
- import presentation layer directly from another feature
- access Cubit from another feature directly
- place feature-specific business logic inside shared layer

Reusable widgets belong in:

```text
shared/widgets/
```

Reusable helpers belong in:

```text
core/utils/
shared/helpers/
```

---

## Widget Guidelines

- Use `StatelessWidget` first.
- Use `StatefulWidget` only for local lifecycle management.
- One public widget per file.
- Private widgets (`_WidgetName`) may live in the same file.
- Avoid large page files containing many widgets.

---

## Naming Conventions

### Files

Use snake_case.

```text
prayer_schedule_page.dart
prayer_schedule_cubit.dart
primary_button.dart
```

---

### Classes

Use PascalCase.

```dart
class PrayerSchedulePage {}
class PrayerScheduleCubit {}
class PrayerRepositoryImpl {}
```

---

### Folders

Use lowercase.

```text
features/
presentation/
repositories/
```

---

## State Management — Cubit/BLoC

Use:
- `flutter_bloc`
- Cubit as default

Use Bloc only for complex event-driven flows.

State rules:
- immutable state
- use `copyWith`
- use `Equatable` or `Freezed`

Cubit responsibilities:
- business logic
- repository calls
- emit state

Cubit must NOT:
- navigate routes
- depend on `BuildContext`
- contain UI formatting logic

Navigation should happen in:

```dart
BlocListener
```

---

## Dependency Injection — GetIt

Use:

```dart
final sl = GetIt.instance;
```

Location:

```text
core/services/injection.dart
```

Register order:

```text
Datasource → Repository → Service
```

Cubits must NOT be registered in GetIt.

Cubits should be created via:

```dart
BlocProvider(
  create: (_) => PrayerCubit(sl()),
)
```

---

## Routing — GoRouter

Location:

```text
app/router/app_router.dart
```

Rules:
- all routes centralized
- do not hardcode route strings in widgets
- use route constants

Example:

```dart
context.go(AppRoutes.home);
```

---

## Theme & Design System

Theme must be centralized.

Location:

```text
core/theme/
```

Separate:
- colors
- typography
- spacing
- radius
- theme data

Do not hardcode:
- colors
- font sizes
- spacing
- border radius

inside widgets.

---

## Layer Responsibilities

| Layer | Responsibility |
|---|---|
| Presentation | UI rendering, state listening, user interaction |
| Cubit | Business logic and state management |
| Repository | Data coordination |
| Source | API/local storage access |
| Model | JSON serialization/deserialization |
| Entity | Pure domain object |

---

## Domain Layer Rules

Entities:
- pure Dart objects
- no Flutter dependency
- no JSON parsing
- no Dio/API dependency

Repository abstraction example:

```dart
abstract class PrayerRepository {
  Future<List<PrayerSchedule>> getTodayPrayer();
}
```

---

## Data Layer Rules

Models:
- handle JSON parsing
- contain `fromJson()`
- contain `toEntity()` mapper

Repositories:
- return entities
- never return raw JSON
- never expose Dio exceptions to UI

UI and Cubit must NEVER:
- receive raw JSON
- parse JSON manually
- access API directly

---

## Networking — Dio

Recommended stack:
- dio
- retrofit
- json_serializable

Structure:

```text
core/network/
```

Separate:
- api client
- interceptor
- endpoints
- exceptions

---

## Shared Components

Reusable widgets belong in:

```text
shared/widgets/
```

Examples:

```text
primary_button.dart
loading_indicator.dart
app_scaffold.dart
```

Avoid duplicate widgets across features.

---

## Responsive Rules

Do not hardcode:

```dart
width: 40
height: 16
fontSize: 14
```

Use centralized spacing and typography tokens.

---

## Freezed

All new entities and models should use `freezed`.

Rules:
- no manual equality
- no manual copyWith
- generated files committed to git

Run codegen:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Recommended Packages

```yaml
flutter_bloc:
get_it:
go_router:
dio:
retrofit:
freezed_annotation:
json_annotation:
equatable:
```

Codegen:

```yaml
build_runner:
freezed:
json_serializable:
retrofit_generator:
```

---

## What NOT To Do

- No API calls inside widgets
- No business logic inside UI
- No global feature widgets folder
- No hardcoded styling values
- No direct JSON parsing in presentation layer
- No navigation inside Cubit
- No Cubit registration in GetIt
- No giant page files with many widgets
- No duplicate reusable components

---

## One Class Per File Rule

Each public class must have its own file.

Correct:

```text
prayer_time_card.dart
next_prayer_banner.dart
prayer_header.dart
```

Wrong:

```text
prayer_page.dart
```

containing many public widgets.

---

## Source of Truth

This file is the main architecture reference for the Muslim Mate project.

All new features and modules must follow this structure and convention.
