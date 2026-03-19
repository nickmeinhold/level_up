# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Level Up is a basketball coaching platform with three Flutter apps and a shared package, structured as a Dart workspace monorepo (requires Dart SDK 3.7+).

- **level_up_client**: Mobile app for athletes to follow workouts, record form videos, chat with coaches
- **level_up_coach**: Mobile app for coaches to create workouts, manage exercises, communicate with clients
- **level_up_web**: Web portal for marketing, subscriptions, and Stripe payments
- **level_up_shared**: Shared models, services, and widgets used across all apps

## Common Commands

```bash
# Run any app (from workspace root or app directory)
flutter run -d <device>

# Run specific app from root
cd apps/level_up_client && flutter run
cd apps/level_up_coach && flutter run
cd apps/level_up_web && flutter run -d chrome

# Get dependencies for entire workspace
flutter pub get

# Analyze code
flutter analyze

# Generate app icons (in app directory)
dart run flutter_launcher_icons:main

# Generate native splash screens (in app directory)
dart run flutter_native_splash:create
```

## Architecture

### Service Locator Pattern
Services are registered in `main()` and accessed via the global `locate<T>()` function:

```dart
// Registration (in main.dart)
Locator.add<AuthService>(AuthService(auth: auth, firestore: firestore));

// Usage (anywhere)
final authService = locate<AuthService>();
```

### Data Layer Architecture
Three-layer pattern used throughout:
1. **Data Layer**: Firebase services (Firestore, Storage, Auth)
2. **Repository/Service Layer**: Custom service classes wrapping Firebase
3. **UI Layer**: Screens and widgets consuming services

### Sealed Classes for Polymorphism
Models use Dart sealed classes with factory constructors for type-safe deserialization:

```dart
// Example: User type hierarchy
sealed class User { ... }
class Client extends User { ... }
class Coach extends User { ... }

// Example: ChatMessage variants
sealed class ChatMessage { ... }
class TextChatMessage extends ChatMessage { ... }
class VideoChatMessage extends ChatMessage { ... }
```

Factory constructors follow the pattern `fromJsonWithId(String id, Map<String, dynamic> json)`.

### Routing
All apps use `go_router` with named routes defined in `main.dart`. Path parameters are used for dynamic routes (e.g., `/workout-screen/:workoutId`).

### State Management
- **RxDart BehaviorSubject**: For reactive service state
- **Firestore snapshots**: Real-time data sync via stream subscriptions

## Firebase Configuration

Firebase project: `level-up-e4147`

**Storage buckets:**
- `client-form-videos`: User-submitted form check videos
- `lu-profile-pics`: Profile pictures (with size variants)
- `workout-images`: Exercise demonstration images

**Firestore collections:**
- `/profiles/{userId}`: User profiles (type: client/coach)
- `/workouts/{workoutId}`: Workout definitions
- `/exercises/{exerciseId}`: Exercise definitions
- `/conversations/{conversationId}/messages/{messageId}`: Chat messages

## Package Dependencies

Shared package (`level_up_shared`) exports all public APIs from `lib/level_up_shared.dart`. Apps import shared code via:
```dart
import 'package:level_up_shared/level_up_shared.dart';
```

## Improvement Plan

See [plan.md](plan.md) for the comprehensive codebase audit and improvement plan, including:
- All known bugs (P0-P3) with file locations and fix descriptions
- Assumptions baked into the code
- Full test strategy (unit, widget, integration, E2E) with prioritized checklists
