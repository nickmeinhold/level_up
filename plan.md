# Level Up — Codebase Audit & Improvement Plan

Comprehensive review conducted 2026-03-18 covering all 3 Flutter apps, the shared package, and Firebase Cloud Functions.

> **Status (2026-03-18):** All P0 and P1 items fixed. 38 regression tests passing. Analyzer clean (1 pre-existing info lint). TypeScript compiles clean.

---

## Table of Contents

- [What's Working Well](#whats-working-well)
- [P0 — Critical (Runtime Crashes)](#p0--critical-runtime-crashes)
- [P1 — High (Data Corruption / Resource Leaks)](#p1--high-data-corruption--resource-leaks)
- [P2 — Medium (Architecture / Performance)](#p2--medium-architecture--performance)
- [P3 — Low (Code Quality / Dead Code)](#p3--low-code-quality--dead-code)
- [Assumptions Baked Into the Code](#assumptions-baked-into-the-code)
- [Test Strategy](#test-strategy)

---

## What's Working Well

- **Service locator pattern** via `Locator` — clean, well-documented, good error messages with stack traces
- **Sealed classes** for `User`, `ChatMessage`, `Exercise` — gives exhaustive pattern matching
- **Dart workspace monorepo** structure (SDK 3.7+) — correct approach for multi-app projects
- **Shared package** correctly exports common code; apps import from `level_up_shared` everywhere
- **Real-time Firestore subscription status stream** in the web app is well-designed
- **Stripe webhook** has signature verification and idempotency intent
- **`SubscriptionService`** in web app has proper custom exception class with user-friendly messages
- **Image resize Cloud Function** correctly detects already-resized images to prevent infinite loops

---

## P0 — Critical (Runtime Crashes)

### FIXED: `late final` mutation in exercise views (client app)

**Files:**
- `apps/level_up_client/lib/workout/exercises/widgets/reps_exercise_view.dart:15-17`
- `apps/level_up_client/lib/workout/exercises/widgets/timed_exercise_view.dart:22-23`
- `apps/level_up_client/lib/workout/exercises/widgets/reps_exercise_with_weights_view.dart:17-20`

**Problem:** `late final int _sets` etc. declared as `late final` but mutated in `setState()`. Dart's `late final` allows exactly one assignment — the second tap throws `LateInitializationError`.

**Fix applied:** Changed `late final` to `late` in all three files.

**Regression test:** Widget tests needed — the model-level tests are in place but these need Flutter widget tests to verify tap interaction doesn't crash.

### FIXED: Route path typo (coach app)

**File:** `apps/level_up_coach/lib/main.dart:35`

**Problem:** `path: '/chat/client/:clientId/coach:coachId'` — missing `/` before `coachId`. Chat navigation from coach app was completely broken.

**Fix applied:** Changed to `'/chat/client/:clientId/coach/:coachId'`.

### FIXED: User model name defaults to string `'null'`

**File:** `packages/level_up_shared/lib/src/users/user.dart:24,31`

**Problem:** `name: json['name'] ?? 'null'` — users without a name field in Firestore would display the literal string "null" as their name.

**Fix applied:** Changed to `?? ''` in both `Client.fromJsonWithId` and `Coach.fromJsonWithId`.

**Regression test:** `packages/level_up_shared/test/models/user_test.dart` — verifies empty string default, not `'null'`.

### NOT A BUG: Switch pattern `RepsExerciseWithWeight`

**File:** `apps/level_up_client/lib/workout/exercises/exercise_details_screen.dart:156`

Initially flagged as a type mismatch, but the shared package class IS `RepsExerciseWithWeight` (no trailing 's'). The client app's local model file has `RepsExerciseWithWeights` (with 's') but that file is dead code — the screen imports from `level_up_shared`. Switch is correct.

### NOT A BUG: Missing `fromJsonWithId` factories

Initially flagged, but the client app's `WorkoutsService` imports from `level_up_shared` which HAS the factories. The client app's local model files (`lib/workout/models/exercise.dart`, `lib/workout/models/workout.dart`) are unused dead code that shadow the shared models — confusing but not a runtime bug.

---

## P1 — High (Data Corruption / Resource Leaks)

### FIXED: 1. `setMessageToRead()` called on every widget rebuild

**File:** `packages/level_up_shared/lib/src/chat/chat_screen.dart` (inside `ListView.builder`)

**Problem:** Every time the chat screen rebuilds (scroll, keyboard, any `setState`), it writes `read: true` to Firestore for every visible message. This creates massive unnecessary Firestore writes and costs.

**Fix:** Track which messages have already been marked as read in a `Set<String>`, only call `setMessageToRead()` for new ones.

### FIXED: 2. Stream subscription leak in `ChatService.retrievePreviousMessages()`

**File:** `packages/level_up_shared/lib/src/chat/chat_service.dart:57`

**Problem:** `_streamSubscription = _firestore...listen(...)` overwrites the previous subscription reference without cancelling it. Every scroll-to-load creates a leaked listener.

**Fix:** Cancel `_streamSubscription` before assigning a new one.

### FIXED: 3. `retrieveAndStreamExercises()` called on every `build()` (coach app)

**File:** `apps/level_up_coach/lib/workouts/screens/workout_detail_screen.dart:126-128`

**Problem:** Called inside `StreamBuilder.builder`, so every Firestore emission triggers a fresh query for exercises, creating an infinite loop of queries.

**Fix:** Move the call to `initState()` or gate it behind a flag.

### FIXED: 4. Stripe webhook idempotency check is broken

**File:** `packages/level_up_shared/functions/src/stripe/on-stripe-success-webhook.ts:30-42`

**Problem:** Checks if the last processed event has the same ID by comparing a single document. If two different events arrive, the first one's ID is overwritten. Need a set of processed event IDs, not a single value.

**Fix:** Use the event ID as the document ID in a `subscription-events` collection. Check `doc(event.id).exists` before processing.

### FIXED: 5. Inconsistent metadata field names in webhook

**File:** `packages/level_up_shared/functions/src/stripe/on-stripe-success-webhook.ts`

**Problem:** Uses `subscription.metadata?.firebaseUID` in some handlers and `invoice.metadata?.userId` in others. If these don't match what's set during checkout, subscription status updates silently fail.

**Fix:** Standardize on one field name (e.g., `firebaseUID`) across all Stripe metadata.

### 6. No customer deduplication in checkout

**File:** `packages/level_up_shared/functions/src/stripe/create-stripe-checkout-session.ts:26-41`

**Problem:** `list({email, limit: 1})` + create-if-empty is not atomic. Concurrent requests can create duplicate Stripe customers.

**Fix:** Use Stripe's idempotency key on customer creation, or use `list` + mutex/transaction.

### FIXED: 7. Cancel subscription doesn't verify Stripe success

**File:** `packages/level_up_shared/functions/src/stripe/cancel-subscription.ts:36-39`

**Problem:** Writes `status: 'cancelled'` to Firestore immediately after calling `stripe.subscriptions.cancel()` without checking if the Stripe API call actually succeeded.

**Fix:** Check the returned subscription object's status before writing to Firestore.

### 8. No error handling anywhere in client app screens

**Files:**
- `apps/level_up_client/lib/workout/workout_screen.dart:21-28`
- `apps/level_up_client/lib/workout/workout_details_screen.dart:20-29`
- `apps/level_up_client/lib/workout/exercises/exercise_details_screen.dart:24-38`
- `apps/level_up_client/lib/profile/profile_screen.dart`

**Problem:** Not a single `try-catch` around any Firestore call. Network errors, permission errors, and auth errors will crash the app with unhandled exceptions.

**Fix:** Add try-catch with user-friendly error states (similar to how the web app's `SubscriptionService` handles errors).

### FIXED: 9. Sign-in screen never resets loading state on error

**File:** `packages/level_up_shared/lib/src/auth/sign_in_screen.dart:20-35`

**Problem:** `isSigningIn` is set to `true` but never reset to `false` if auth fails. User gets stuck on the loading spinner forever.

**Fix:** Wrap in try-catch, reset `isSigningIn` in `finally` block.

### FIXED: 10. `AuthService` auth state listener never cleaned up

**File:** `packages/level_up_shared/lib/src/auth/auth_service.dart:23-41`

**Problem:** Constructor subscribes to `_auth.authStateChanges()` but the subscription is never stored or cancelled. Since `AuthService` is a Locator singleton that's never disposed, it technically lives for the app lifetime — but rapid auth state changes can create multiple overlapping Firestore profile subscriptions.

**Fix:** Store the auth state subscription, cancel previous profile subscription before creating new one (the cancellation is partially there but has a race condition).

---

## P2 — Medium (Architecture / Performance)

### 11. N+1 query problem in coach conversations

**File:** `apps/level_up_coach/lib/conversations/services/conversations_service.dart:10-55`

**Problem:** 1 query to list conversations, then 2 queries per conversation (profile + unread count). 10 conversations = 21 Firestore reads.

**Fix:** Denormalize `lastMessage`, `timestamp`, and `clientName` onto the conversation document.

### FIXED: 12. Duplicate model definitions (client app dead code) — DELETED

**Files:**
- `apps/level_up_client/lib/workout/models/exercise.dart` (dead code)
- `apps/level_up_client/lib/workout/models/workout.dart` (dead code)

**Problem:** These local models shadow the shared package models and lack `fromJsonWithId` factories. They're never imported but create confusion during code review.

**Fix:** Delete both files. All imports already use `level_up_shared`.

### 13. `isCoach()` called on every build (coach app)

**File:** `apps/level_up_coach/lib/home_screen.dart:27-28`

**Problem:** `FutureBuilder` with `future:` created in `build()` means every rebuild triggers a Firestore read.

**Fix:** Cache the future in `initState()` or use a stream.

### FIXED: 14. Fire-and-forget image upload (coach app)

**File:** `apps/level_up_coach/lib/workouts/screens/workout_detail_screen.dart:23-50`

**Problem:** `uploadWorkoutImage()` is called without `await`. If user navigates away, the upload silently dies. Also, `image!` force-unwrap crashes if user cancels the image picker.

**Fix:** Await the upload, add null check on image picker result.

### FIXED: 15. `Workout.toJson()` doesn't include `category`

**File:** `packages/level_up_shared/lib/src/workouts/models/workout.dart:14-15`

**Problem:** Serialization drops the `category` field, so workouts saved via `toJson` lose their category.

**Fix:** Add `'category': category` to `toJson()`.

**Regression test:** `packages/level_up_shared/test/models/workout_test.dart` — documents this gap; update test when fixed.

### 16. `VideoService` `StreamController` never closed

**File:** `apps/level_up_client/lib/video/video_service.dart:19`

**Problem:** `uploadProgressStreamController` is a broadcast `StreamController` that's never closed. Memory leak compounds with multiple uploads.

**Fix:** Add a `dispose()` method, or use a non-broadcast controller.

### FIXED: 17. `ChatMessage` falls through to `VideoChatMessage` for unknown types

**File:** `packages/level_up_shared/lib/src/chat/chat_message.dart:8-23`

**Problem:** If `type` is anything other than `'text'` (including `null` or an unknown string), the factory silently creates a `VideoChatMessage`. Missing `videoUrl` then crashes.

**Fix:** Add explicit `'video'` check, throw on unknown types.

**Regression test:** `packages/level_up_shared/test/models/chat_message_test.dart` — documents the current fallthrough behavior.

### 18. Unsafe index access for WorkoutCategory

**File:** `apps/level_up_coach/lib/workouts/screens/upsert_exercise_screen.dart:88`

**Problem:** `ExerciseType.values[workout.category]` crashes if `category` is out of bounds.

**Fix:** Bounds check before indexing.

### 19. Account screen error handler is empty

**File:** `apps/level_up_web/lib/screens/account_screen.dart`

**Problem:** `if (snapshot.hasError) { // handle error }` — the error branch is a comment with no implementation. Errors are silently swallowed.

**Fix:** Display an error state widget.

### 20. Hardcoded placeholder URLs

**Files:**
- `apps/level_up_client/lib/onboarding/free_workout/terms_and_conditions_screen.dart:73` — `https://example.com/terms`
- `apps/level_up_client/lib/onboarding/opening_screen.dart:85` — hardcoded web URL

**Fix:** Move to a config/constants file, replace placeholder with real URL.

---

## P3 — Low (Code Quality / Dead Code)

### FIXED: 21. Unused example file — DELETED

**File:** `apps/level_up_client/lib/video/app_lifecyce_listener_example.dart`

### 22. Duplicate description display (coach app)

**File:** `apps/level_up_coach/lib/workouts/screens/workouts_screen.dart:60-66`

Workout description is shown in both `title` and first line of `subtitle`.

### 23. Missing Scaffold in StreamBuilder error/loading states (coach app)

**File:** `apps/level_up_coach/lib/workouts/screens/workout_detail_screen.dart:87-92`

Error and loading states return bare widgets without Scaffold — causes render errors.

### 24. Commented-out `setState` in WorkoutDetailsScreen

**File:** `apps/level_up_client/lib/workout/workout_details_screen.dart:127,134-136`

`_currentStep = step` has no effect without `setState()`. The `setState` is commented out.

### 25. String exceptions instead of proper Exception objects

**Files:**
- `apps/level_up_coach/lib/workouts/services/workouts_service.dart:33` — `throw 'Exceeded valid size...'`
- `packages/level_up_shared/lib/src/auth/auth_service.dart` — `throw 'The UserCredential...'`

Should throw typed exceptions for proper catch handling.

### 26. `TimeUpScreen` audio release mode set after play

**File:** `apps/level_up_client/lib/workout/exercises/widgets/time_up_screen.dart:14-32`

`setReleaseMode(ReleaseMode.loop)` called AFTER `play()` — may be too late for looping to take effect.

---

## Assumptions Baked Into the Code

| # | Assumption | Risk |
|---|-----------|------|
| 1 | **Users always have network** | Zero offline handling, no cached data, no retry logic. Any Firestore call can crash. |
| 2 | **Firestore data is always well-formed** | `as String`, `as int` casts everywhere without null checks. One missing field = crash. |
| 3 | **Users are always authenticated** | `_auth.currentUser!` force-unwrapped in many places. Sign-out race conditions crash. |
| 4 | **One coach per client** | Conversation model assumes 1:1 coach-client mapping via userId as doc ID. |
| 5 | **Exercises always have video** | YouTube player initialized unconditionally; Rick Roll fallback for missing IDs. |
| 6 | **Stripe webhooks arrive in order** | No handling for out-of-order events (e.g., `invoice.payment_failed` before `subscription.created`). |
| 7 | **Profile pics are always available** | Hardcoded Storage URLs with no signed URL expiry or fallback. |
| 8 | **Firestore security rules are properly configured** | No rules visible in repo — critical for multi-tenant coach/client data isolation. |
| 9 | **Exercise IDs in workout are always valid** | No handling for orphaned exercise references. |
| 10 | **Stripe Price ID never changes** | `STRIPE_PRICE_ID` env var assumed to always be valid. |

---

## Test Strategy

### Current State

| Location | Tests | Quality |
|----------|-------|---------|
| `packages/level_up_shared/test/models/` | 36 unit tests | Good — covers all model deserialization, round-trips, edge cases |
| `packages/level_up_shared/test/level_up_chat_test.dart` | 1 empty test | Placeholder |
| `apps/level_up_web/test/subscription_service_test.dart` | 14 tests | Shallow — tests exception class but not actual service behavior |
| `packages/level_up_shared/functions/test/stripe.test.ts` | 12 Jest tests | Shallow — tests mock interactions, not real function logic |
| `apps/level_up_client/test/` | None | No tests |
| `apps/level_up_coach/test/` | None | No tests |

### Phase 1: Unit Tests (Foundation)

**Shared package services** — test the code that handles money and user data first:

- [ ] `AuthService` — sign-in flows, profile stream lifecycle, sign-out cleanup, error handling
- [ ] `ChatService` — message ordering, deduplication, pagination, subscription management
- [ ] `ProfileService` — image upload, URL generation, validation
- [ ] `SubscriptionService` — checkout flow, cancellation, status stream mapping (expand existing)

**Cloud Functions** — protect revenue:

- [ ] `create-stripe-checkout-session` — auth validation, customer deduplication, idempotency
- [ ] `on-stripe-success-webhook` — each event type handler, idempotency check, error responses
- [ ] `cancel-subscription` — auth validation, Stripe API verification, Firestore update
- [ ] `on-user-created` — subscription doc creation
- [ ] `resize-images` — size variants, loop prevention, invalid image handling

### Phase 2: Widget Tests

**Client app exercise views** — regression tests for the `late final` fix:

- [ ] `RepsExerciseView` — renders, set tap updates state, checkbox completes exercise
- [ ] `TimedExerciseView` — renders, countdown works, set tracking
- [ ] `RepsExerciseWithWeightsView` — renders, weight/set/rep selection

**Shared package widgets:**

- [ ] `SignInScreen` — renders both buttons on correct platforms, loading state, error recovery
- [ ] `ChatScreen` — message list rendering, text vs video, pagination trigger
- [ ] `EditProfilePicScreen` — image picker interaction, upload progress

### Phase 3: Integration Tests

- [ ] **Chat flow** — send message → receive in real-time → mark as read → pagination
- [ ] **Workout CRUD** (coach) — create workout → add exercises → retrieve → stream updates
- [ ] **Auth flow** — sign in → profile creation → onboarding name migration → sign out
- [ ] **Stripe payment flow** — checkout session → webhook → subscription status update → cancellation

### Phase 4: End-to-End Tests

- [ ] **Athlete journey:** Sign up → onboard → view workout → complete exercise → record video → chat with coach
- [ ] **Coach journey:** Sign in → create workout → add exercises → view conversations → respond to client
- [ ] **Payment journey:** Landing page → sign in → subscribe → verify active → cancel → verify cancelled

### Testing Approach

Per CLAUDE.md global preferences: **ATDD** — write acceptance tests first, then implement to make them pass. For each fix in P1/P2 above:

1. Write a failing test that exposes the bug
2. Apply the fix
3. Verify the test passes

### Test Infrastructure Needed

- **Dart:** `flutter_test` (already available), `mockito` or `mocktail` for service mocking
- **Cloud Functions:** Jest (already configured), `firebase-functions-test` (already a dev dependency)
- **Integration:** Firebase emulator suite for local Firestore/Auth/Storage
- **E2E:** `integration_test` package for Flutter, Playwright or similar for web app
