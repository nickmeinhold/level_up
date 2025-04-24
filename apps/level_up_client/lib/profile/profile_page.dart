import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/auth/auth_service.dart';
import 'package:level_up/profile/client_profile_service.dart';
import 'package:level_up_shared/level_up_shared.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(
    text: '',
  );

  bool _nameChanged = false;

  @override
  void initState() {
    super.initState();
    _retrieveUserDetails();
  }

  Future<void> _retrieveUserDetails() async {
    Client client = await locate<ClientProfileService>().retrieveClientUser();
    _nameController.text = client.name;
  }

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
                    locate<ProfileService>().getProfilePicUrl(PicSize.small),
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    onPressed: () {
                      context.push('/edit-profile-pic');
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.0),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _nameChanged = true;
                    });
                  },
                ),
              ),
              IconButton(
                onPressed:
                    (_nameChanged)
                        ? () {
                          locate<ProfileService>().updateName(
                            _nameController.text,
                          );
                          setState(() {
                            _nameChanged = false;
                          });
                        }
                        : null,
                icon: Icon(Icons.save),
              ),
            ],
          ),
          SizedBox(height: 16.0),

          // Email field
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          SizedBox(height: 24.0),

          // Subscription button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Subscription page')));
            },
            icon: Icon(Icons.card_membership),
            label: Text('Manage Subscription'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0),
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

          // Support button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Support page')));
            },
            icon: Icon(Icons.help),
            label: Text('Support'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0),
            ),
          ),
          SizedBox(height: 24.0),

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
                          onPressed: () => context.pop(),
                          child: Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            // SharedPreferences.getInstance().then((prefs) {
                            //   prefs.clear();
                            // });
                            context.pop();
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
