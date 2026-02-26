---
description: "General project rules, architecture, and code conventions."
globs: "**/*.dart"
---
# Rules: Flutter Project Standards

## 1. Project Context
- **Framework**: Flutter (Web, Android, iOS)
- **Language**: Dart
- **Architecture**: Feature-based Clean Architecture.
    - `lib/core/`: Shared resources, services, and config.
    - `lib/features/`: Isolated features with their own logic/UI.
- **Dependency Injection**: `get_it` (via `locator.dart`).
- **Backend**: Firebase (Core, Auth, Firestore).

## 2. Tech Stack & Libraries
- **GetIt**: For service locator/dependency injection.
- **Firebase**:
    - `firebase_core`, `firebase_auth`, `cloud_firestore`.
    - **Emulators**: MUST be used for local development (Auth: 9099, Firestore: 8080).
    - **Credentials**: `firebase_options.dart` MUST be placed in `lib/core/config/secret/`.

## 3. Code Conventions (CRITICAL)
- **Clean Code**:
    - Variables and functions must have descriptive, English names.
    - Functions should be small and do one thing well.
- **DRY (Don't Repeat Yourself)**:
    - Never duplicate logic. Extract to `core/shared` or feature-specific utilities.
- **Widgets**:
    - Split large build methods into smaller private widgets or separate files.
- **formatting**:
    - Always use trailing commas for better formatting.

## 4. Agent Behavior
- **Refactoring**: If you see messy code, propose a refactor immediately.
- **Language**: logic/comments in English. User communication in **Spanish** (as per global user preference).
