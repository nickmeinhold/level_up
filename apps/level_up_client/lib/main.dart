import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/free_workout/email_screen.dart';
import 'package:level_up/free_workout/intro_screen.dart';
import 'package:level_up/main_screen.dart';
import 'package:level_up/free_workout/name_screen.dart';
import 'package:level_up/opening_screen.dart';
import 'package:level_up/free_workout/terms_and_conditions_screen.dart';

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
  ],
);
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
