import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'package:level_up_web/screens/home_screen.dart';
import 'package:level_up_web/screens/program_details_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'program/:id',
          builder:
              (context, state) =>
                  ProgramDetailsScreen(programId: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);

void main() {
  // Setup the data layer of the "data layer architecture"
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // Add services to the Locator
  Locator.add<AuthService>(AuthService(auth: auth, firestore: firestore));

  runApp(const LevelUpApp());
}

class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LevelUp Coaching',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
