# Level Up

A basketball coaching platform connecting athletes with coaches through personalized workouts, form check videos, and real-time chat.

Three Flutter apps, one shared package, Cloud Functions — all in a Dart 3.7 workspace monorepo.

## What It Does

**Athletes** get a mobile app where they follow coach-assigned workouts, record form check videos for feedback, and chat directly with their coach.

**Coaches** get a mobile app where they build workouts, manage their exercise library, and communicate with clients.

**Everyone** gets a web portal for signing up, managing their Stripe subscription, and account settings.

## Project Structure

```
level_up/
├── apps/
│   ├── level_up_client/     # Athlete mobile app (Flutter)
│   ├── level_up_coach/      # Coach mobile app (Flutter)
│   └── level_up_web/        # Web portal (Flutter Web)
├── packages/
│   └── level_up_shared/     # Models, services, widgets, Cloud Functions
│       ├── lib/src/
│       │   ├── auth/        # AuthService, Firebase Auth wrappers
│       │   ├── chat/        # ChatService, message models
│       │   ├── profile/     # ProfileService, image handling
│       │   ├── users/       # Sealed User → Client/Coach hierarchy
│       │   ├── workouts/    # Workout & Exercise models + services
│       │   └── utils/       # Service locator, shared utilities
│       └── functions/       # Firebase Cloud Functions (TypeScript)
├── pubspec.yaml             # Workspace root
└── plan.md                  # Audit & improvement plan
```

## Architecture

**Service Locator** — Services register at startup via `Locator.add<T>()`, consumed anywhere with `locate<T>()`. No DI framework, no code generation. Simple and explicit.

**Sealed Classes** — `User` is sealed into `Client` and `Coach`. `ChatMessage` splits into `Text` and `Video` variants. Dart's exhaustive pattern matching means the compiler catches missed cases.

**Three-Layer Data Flow** — Firebase services at the bottom, custom service wrappers in the middle, UI at the top. Services expose `BehaviorSubject` streams (RxDart) for reactive state. Firestore snapshots provide real-time sync.

**Routing** — GoRouter with named routes in each app's `main.dart`. Path parameters for dynamic content (`/workout-screen/:workoutId`).

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter (mobile + web) |
| State | RxDart `BehaviorSubject`, Firestore snapshots |
| Auth | Firebase Auth |
| Database | Cloud Firestore |
| Storage | Firebase Storage (form videos, profile pics, workout images) |
| Functions | Firebase Cloud Functions (TypeScript, Node 20) |
| Payments | Stripe (webhooks with signature verification) |
| Video | `video_player`, `camera`, `youtube_player_flutter` |
| CI | GitHub Actions — analyze, test shared + web + functions |

## Getting Started

Requires Flutter (stable channel) and Dart SDK 3.7+.

```bash
# Clone and get dependencies for the entire workspace
flutter pub get

# Run the athlete app
cd apps/level_up_client && flutter run

# Run the coach app
cd apps/level_up_coach && flutter run

# Run the web portal
cd apps/level_up_web && flutter run -d chrome

# Analyze everything
flutter analyze

# Run tests
cd packages/level_up_shared && flutter test
cd apps/level_up_web && flutter test

# Cloud Functions
cd packages/level_up_shared/functions
npm ci && npm run build && npm test
```

## Firebase

Project: `level-up-e4147`

**Storage buckets:**
- `client-form-videos` — Athlete-submitted form check videos
- `lu-profile-pics` — Profile pictures (with auto-resized variants via Cloud Function)
- `workout-images` — Exercise demonstration images

**Firestore collections:**
- `/profiles/{userId}` — User profiles (typed as client or coach)
- `/workouts/{workoutId}` — Workout definitions
- `/exercises/{exerciseId}` — Exercise library
- `/conversations/{conversationId}/messages/{messageId}` — Chat

## Current State

Actively maintained. A comprehensive audit on 2026-03-18 identified and fixed all P0 (crash) and P1 (data corruption/leak) bugs. 68 regression tests passing. CI pipeline runs on every push and PR to `main`, with a smart skip for docs-only changes.

The codebase is clean — analyzer passes, TypeScript compiles clean, and each subproject has its own `CLAUDE.md` with context for AI-assisted development.

See `plan.md` for the full audit: remaining P2/P3 items, assumptions baked into the code, and the test strategy.

## Future Directions

Things that would make this better, roughly in order of impact:

- **Push notifications** — Coaches and athletes need to know when messages arrive or workouts are assigned without having the app open.
- **Offline support** — Firestore has offline persistence, but the UI doesn't gracefully handle offline states. Athletes in gyms with spotty wifi will hit this.
- **Video annotation** — Coaches reviewing form check videos should be able to draw on frames or leave timestamped comments, not just text replies.
- **Workout templates & scheduling** — Coaches currently build workouts from scratch each time. Templates, recurring schedules, and periodization would save real time.
- **Analytics dashboard** — Both sides want to see progress over time. Workout completion rates, volume trends, streak tracking.
- **Test coverage expansion** — The client and coach apps have minimal test coverage compared to the shared package and web app. Widget and integration tests would catch regressions earlier.
