import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/auth/auth_service.dart';
import 'package:level_up/onboarding/free_workout/email_screen.dart';
import 'package:level_up/onboarding/free_workout/intro_screen.dart';
import 'package:level_up/main_screen.dart';
import 'package:level_up/onboarding/free_workout/name_screen.dart';
import 'package:level_up/onboarding/opening_screen.dart';
import 'package:level_up/onboarding/free_workout/terms_and_conditions_screen.dart';
import 'package:level_up/utils/locator.dart';
import 'package:level_up/workout/exercises/exercise_details_screen.dart';
import 'package:level_up/workout/exercises/widgets/time_up_screen.dart';
import 'package:level_up/workout/services/workouts_service.dart';
import 'package:level_up/workout/workout_details_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => OpeningScreen()),
    GoRoute(
      path: '/intro-screen',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/name-screen',
      builder: (context, state) => const NameScreen(),
    ),
    GoRoute(path: '/email-screen', builder: (context, state) => EmailScreen()),
    GoRoute(
      path: '/terms-screen',
      builder: (context, state) => TermsAndConditionsScreen(),
    ),
    GoRoute(path: '/main-screen', builder: (context, state) => MainScreen()),
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
      path: '/exercise-screen/:workoutId/:exerciseNum',
      builder:
          (context, state) => ExerciseDetailsScreen(
            workoutId: state.pathParameters['workoutId']!,
            exerciseNum: state.pathParameters['exerciseNum']!,
          ),
    ),
    GoRoute(
      path: '/time-up',
      builder: (context, state) => const TimeUpScreen(),
    ),
  ],
);

void main() {
  // The services make up the repositories layer of the "data layer architecture"
  Locator.add<AuthService>(AuthService());
  Locator.add<WorkoutsService>(WorkoutsService());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
