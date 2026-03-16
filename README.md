# Buryak

A comprehensive cookbook and meal planning app built with Flutter. Manage recipes, discover new ideas, plan weekly meals, and generate shopping lists — all in one place.

## Features

- **Recipe Feed** — browse and search your saved recipes
- **Explore** — discover new recipes
- **Meal Planner** — schedule meals across the week
- **Shopping List** — auto-generated from planned meals
- **Import** — add recipes from external sources
- **Authentication** — login/register with JWT-based sessions

## Getting Started

### Prerequisites

- Flutter 3.41+ / Dart 3.11+
- A running backend (API base URL required)

### Setup

```bash
# Install dependencies
flutter pub get

# Generate code (Riverpod providers, JSON serializers)
dart run build_runner build --delete-conflicting-outputs

# Create a .env file with your API base URL
echo 'API_BASE_URL=http://localhost:8080' > .env

# Run with environment config
flutter run --dart-define-from-file=.env
```

### Running tests

```bash
flutter test
```

## Project Structure

```
lib/
├── main.dart              # Entry point — initializes env and storage
├── shared/
│   ├── app.dart           # Root widget (theme + router)
│   ├── router.dart        # GoRouter configuration
│   ├── repositories/      # API service layers
│   ├── providers/         # Global state (theme, user, storage)
│   └── views/             # RootLayout, AdaptiveNavigation
└── features/
    ├── recipes/           # Feed, recipe view, import
    ├── explore/           # Discovery screen
    ├── planner/           # Meal planning calendar
    ├── shopping/          # Shopping list
    └── profile/           # Auth (login/register) and settings
```

## Tech Stack

| Concern | Package |
|---|---|
| Navigation | `go_router` ^17 |
| State management | `flutter_riverpod` + `flutter_hooks` |
| Code generation | `riverpod_generator`, `json_serializable` |
| HTTP client | `http` |
| Auth | `jwt_decoder`, `flutter_secure_storage` |
| Images | `cached_network_image`, `flutter_svg` |

## API

The backend API is defined in [`swagger.yaml`](swagger.yaml) at the project root. All network calls go through `lib/shared/repositories/` using `RequestHandler` for auth header injection and error handling.

The base URL is injected at build time via `--dart-define-from-file=.env`:

```
API_BASE_URL=https://your-api-host.example.com
```
