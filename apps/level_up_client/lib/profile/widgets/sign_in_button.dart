import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        context.go('/signin');
      },
      icon: Icon(Icons.login, color: Colors.black),
      label: Text('Sign In', style: TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        side: BorderSide(color: Colors.black),
      ),
    );
  }
}
