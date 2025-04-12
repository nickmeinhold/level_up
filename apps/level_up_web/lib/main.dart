// main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_web/firebase_options.dart';
import 'package:level_up_web/screens/home_screen.dart';
import 'package:level_up_web/services/auth_service.dart';
import 'package:level_up_web/services/payment_service.dart';
import 'package:level_up_web/screens/sign_in_screen.dart';
import 'package:level_up_web/utils/locator.dart';

final _router = GoRouter(
  initialLocation: '/',
  // locate<AuthService>().currentUserId == null ? '/signin' : '/',
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
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup the data layer of the "data layer architecture"
  final firestore = FirebaseFirestore.instance;
  // final storage = FirebaseStorage.instance;
  final auth = FirebaseAuth.instance;
  // final cloudFunctions = FirebaseFunctions.instance;

  // The services make up the repositories layer of the "data layer architecture"
  Locator.add<AuthService>(AuthService(auth: auth, firestore: firestore));
  Locator.add<PaymentService>(PaymentService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
