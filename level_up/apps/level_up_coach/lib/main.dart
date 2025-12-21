import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_coach/profile/coach_profile_service.dart';
import 'package:level_up_coach/workouts/screens/create_workout_screen.dart';
import 'package:level_up_coach/workouts/screens/record_video_screen.dart';
import 'package:level_up_coach/workouts/screens/upsert_exercise_screen.dart';
import 'package:level_up_coach/workouts/screens/workout_detail_screen.dart';
import 'package:level_up_coach/workouts/services/workouts_service.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'package:level_up_coach/conversations/services/conversations_service.dart';
import 'package:level_up_coach/home_screen.dart';
import 'firebase_options.dart';

final _router = GoRouter(
  initialLocation:
      locate<AuthService>().currentUserId == null ? '/signin' : '/',
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: 'signin',
      path: '/signin',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      name: 'chat',
      path: '/chat/client/:clientId/coach:coachId',
      builder:
          (context, state) => ChatScreen(
            conversationId: state.pathParameters['clientId']!,
            currentUserId: state.pathParameters['coachId']!,
            isCoach: true,
          ),
    ),
    GoRoute(
      name: 'upsert-exercise',
      path: '/upsert-exercise/workoutId/:workoutId',
      builder:
          (context, state) => UpsertExerciseScreen(
            workoutId: state.pathParameters['workoutId']!,
            exerciseId: state.uri.queryParameters['exerciseId'],
          ),
    ),
    GoRoute(
      name: 'workout-details',
      path: '/workout-details/workoutId/:workoutId',
      builder:
          (context, state) => WorkoutDetailScreen(
            workoutId: state.pathParameters['workoutId']!,
          ),
    ),
    GoRoute(
      path: '/edit-profile-pic',
      builder: (context, state) => const EditProfilePicScreen(),
    ),
    GoRoute(
      path: '/create-workout',
      builder: (context, state) => const CreateWorkoutScreen(),
    ),
    GoRoute(
      path: '/record-video',
      builder: (context, state) => const RecordVideoScreen(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup the data layer of the "data layer architecture"
  final firestore = FirebaseFirestore.instance;
  final workoutImagesStorage = FirebaseStorage.instanceFor(
    bucket: 'workout-images',
  );
  final profilePicStorage = FirebaseStorage.instanceFor(
    bucket: 'lu-profile-pics',
  );
  final auth = FirebaseAuth.instance;
  // final cloudFunctions = FirebaseFunctions.instance;

  // The services make up the repositories layer of the "data layer architecture"
  Locator.add<AuthService>(AuthService(auth: auth, firestore: firestore));
  Locator.add<ConversationsService>(ConversationsService(firestore: firestore));
  Locator.add<CoachProfileService>(
    CoachProfileService(auth: auth, firestore: firestore),
  );
  Locator.add<ProfileService>(
    ProfileService(
      auth: auth,
      firestore: firestore,
      profilePicStorage: profilePicStorage,
    ),
  );
  Locator.add<WorkoutsService>(
    WorkoutsService(
      firestore: firestore,
      workoutImagesStorage: workoutImagesStorage,
    ),
  );
  Locator.add<ChatService>(ChatService(firestore: firestore));

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
