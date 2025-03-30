import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_coach/auth/auth_service.dart';
import 'package:level_up_coach/utils/locator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(
    text: 'John Doe',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Profile picture
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    'https://picsum.photos/id/1012/200',
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    onPressed: () {
                      // Handle profile picture update
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update profile picture')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.0),

          // Name field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 16.0),

          // Settings button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Settings page')));
            },
            icon: Icon(Icons.settings),
            label: Text('Settings'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0),
            ),
          ),
          SizedBox(height: 16.0),

          // Logout button
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            locate<AuthService>().signOut();
                            context.go('/signin');
                          },
                          child: Text('LOGOUT'),
                        ),
                      ],
                    ),
              );
            },
            icon: Icon(Icons.logout, color: Colors.red),
            label: Text('Logout', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              side: BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
