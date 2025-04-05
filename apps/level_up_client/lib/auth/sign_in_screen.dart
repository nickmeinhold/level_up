import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/auth/auth_service.dart';
import 'package:level_up/utils/icons/custom_icons.dart';
import 'package:level_up/utils/locator.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isSigningIn = false;

  Future<void> _signInWithApple(BuildContext context) async {
    setState(() {
      isSigningIn = true;
    });
    await locate<AuthService>().signInWithApple();

    if (context.mounted) {
      context.go('/');
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      isSigningIn = true;
    });
    await locate<AuthService>().signInWithGoogle();

    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            (isSigningIn)
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.macOS)
                      SizedBox(
                        width: 185,
                        child: TextButton.icon(
                          icon: const Icon(CustomIcons.apple, size: 16),
                          onPressed: () => _signInWithApple(context),
                          label: const Text('Sign in with Apple'),
                          style: const ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll(
                              Colors.white,
                            ),
                            textStyle: WidgetStatePropertyAll(
                              TextStyle(color: Colors.white),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.black,
                            ),
                            shape:
                                WidgetStatePropertyAll<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    if (kIsWeb ||
                        defaultTargetPlatform == TargetPlatform.android)
                      SizedBox(
                        child: TextButton.icon(
                          icon: Image.asset(
                            'assets/images/google_icon.png',
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () {
                            _signInWithGoogle(context);
                          },
                          label: const Text('Sign in with Google'),
                          style: ButtonStyle(
                            foregroundColor: const WidgetStatePropertyAll(
                              Colors.white,
                            ),
                            textStyle: const WidgetStatePropertyAll(
                              TextStyle(color: Colors.white),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.blue[600],
                            ),
                            shape: const WidgetStatePropertyAll<
                              RoundedRectangleBorder
                            >(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(0.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
      ),
    );
  }
}
