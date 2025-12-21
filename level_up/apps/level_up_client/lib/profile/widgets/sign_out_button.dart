import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Sign Out'),
                content: Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () {
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.clear();
                      });
                      context.pop();
                      locate<AuthService>().signOut();
                      context.go('/signin');
                    },
                    child: Text('SIGN OUT'),
                  ),
                ],
              ),
        );
      },
      icon: Icon(Icons.logout, color: Colors.red),
      label: Text('Sign Out', style: TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        side: BorderSide(color: Colors.red),
      ),
    );
  }
}
