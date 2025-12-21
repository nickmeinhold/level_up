import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_client/profile/client_profile_service.dart';
import 'package:level_up_client/profile/widgets/sign_in_button.dart';
import 'package:level_up_client/profile/widgets/sign_out_button.dart';
import 'package:level_up_shared/level_up_shared.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(
    text: '',
  );

  bool _nameChanged = false;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    if (locate<AuthService>().currentUserId != null) {
      _signedIn = true;
      _retrieveUserDetails();
    }
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
          if (_signedIn) ...[
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
                      icon: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
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
                context.pushNamed(
                  'chat-screen',
                  pathParameters: {
                    'conversationId': locate<AuthService>().currentUserId!,
                    'currentUserId': locate<AuthService>().currentUserId!,
                  },
                );
              },
              icon: Icon(Icons.help),
              label: Text('Support'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
            SizedBox(height: 24.0),

            // Sign out button
            SignOutButton(),
          ],

          if (!_signedIn) SignInButton(),
        ],
      ),
    );
  }
}
