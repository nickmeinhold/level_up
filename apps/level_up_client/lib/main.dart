import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/onboarding/free_workout/intro_screen.dart';
import 'package:level_up/main_screen.dart';
import 'package:level_up/onboarding/free_workout/name_screen.dart';
import 'package:level_up/onboarding/free_workout/terms_and_conditions_screen.dart';
import 'package:level_up/onboarding/opening_screen.dart';
import 'package:level_up/profile/client_profile_service.dart';
import 'package:level_up/video/video_recorder_screen.dart';
import 'package:level_up/video/video_service.dart';
import 'package:level_up/workout/exercises/exercise_details_screen.dart';
import 'package:level_up/workout/exercises/widgets/time_up_screen.dart';
import 'package:level_up/workout/services/workouts_service.dart';
import 'package:level_up/workout/workout_details_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'firebase_options.dart';

final _router = GoRouter(
  initialLocation:
      locate<AuthService>().currentUserId == null ? '/signin' : '/',
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const MainScreen(),
      redirect: (BuildContext context, GoRouterState state) async {
        bool onboarded = await locate<AuthService>().userHasOnboarded;
        if (!onboarded) {
          return '/opening-screen';
        } else {
          return null;
        }
      },
    ),
    GoRoute(
      path: '/opening-screen',
      builder: (context, state) => OpeningScreen(),
    ),
    GoRoute(
      name: 'signin',
      path: '/signin',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/intro-screen',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/name-screen',
      builder: (context, state) => const NameScreen(),
    ),
    GoRoute(
      path: '/terms-screen',
      builder: (context, state) => TermsAndConditionsScreen(),
    ),
    GoRoute(
      name: 'workout-screen',
      path: '/workout-screen/:workoutId',
      builder:
          (context, state) => WorkoutDetailsScreen(
            workoutId: state.pathParameters['workoutId']!,
          ),
    ),
    GoRoute(
      name: 'exercise-screen',
      path: '/exercise-screen/exerciseId/:exerciseId',
      builder:
          (context, state) => ExerciseDetailsScreen(
            exerciseId: state.pathParameters['exerciseId']!,
          ),
    ),
    GoRoute(
      path: '/time-up',
      builder: (context, state) => const TimeUpScreen(),
    ),
    GoRoute(
      path: '/video-form',
      builder: (context, state) => const VideoRecorderScreen(),
    ),
    GoRoute(
      path: '/edit-profile-pic',
      builder: (context, state) => const EditProfilePicScreen(),
    ),
    GoRoute(
      name: 'chat-screen',
      path:
          '/chat-screen/conversationId/:conversationId/currentUserId/:currentUserId',
      builder:
          (context, state) => ChatScreen(
            conversationId: state.pathParameters['conversationId']!,
            currentUserId: state.pathParameters['currentUserId']!,
          ),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup the data layer of the "data layer architecture"
  final firestore = FirebaseFirestore.instance;
  final clientFormVideosStorage = FirebaseStorage.instanceFor(
    bucket: 'client-form-videos',
  );
  final profilePicStorage = FirebaseStorage.instanceFor(
    bucket: 'lu-profile-pics',
  );
  final auth = FirebaseAuth.instance;
  // final cloudFunctions = FirebaseFunctions.instance;

  // The services make up the repositories layer of the "data layer architecture"
  Locator.add<AuthService>(AuthService(auth: auth, firestore: firestore));
  Locator.add<WorkoutsService>(WorkoutsService(firestore: firestore));
  Locator.add<VideoService>(
    VideoService(clientFormVideosStorage: clientFormVideosStorage, auth: auth),
  );
  Locator.add<ProfileService>(
    ProfileService(
      profilePicStorage: profilePicStorage,
      firestore: firestore,
      auth: auth,
    ),
  );
  Locator.add<ClientProfileService>(
    ClientProfileService(auth: auth, firestore: firestore),
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
