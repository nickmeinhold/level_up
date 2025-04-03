import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_coach/auth/auth_service.dart';
import 'package:level_up_coach/auth/sign_in_screen.dart';
import 'package:level_up_coach/conversations/chat/chat_page.dart';
import 'package:level_up_coach/conversations/services/conversations_service.dart';
import 'package:level_up_coach/home_screen.dart';
import 'package:level_up_coach/profile/profile_service.dart';
import 'package:level_up_coach/utils/locator.dart';
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
      path: '/chat/client/:clientId',
      builder:
          (context, state) =>
              ChatPage(clientId: state.pathParameters['clientId']!),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup the data layer of the "data layer architecture"
  final firestore = FirebaseFirestore.instance;
  // final storage = FirebaseStorage.instance;
  final auth = FirebaseAuth.instance;
  // final cloudFunctions = FirebaseFunctions.instance;

  // The services make up the repositories layer of the "data layer architecture"
  Locator.add<AuthService>(
    AuthService(firebaseAuth: auth, firestore: firestore),
  );
  Locator.add<ConversationsService>(ConversationsService());
  Locator.add<ProfileService>(
    ProfileService(firebaseAuth: auth, firestore: firestore),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
