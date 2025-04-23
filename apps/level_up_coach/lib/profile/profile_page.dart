import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_coach/auth/auth_service.dart';
import 'package:level_up_coach/profile/coach_profile_service.dart';
import 'package:level_up_shared/level_up_shared.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(
    text: 'John Doe',
  );

  bool _isLoading = true;
  bool _isCoach = false;
  bool _hasPendingApplication = false;

  @override
  void initState() {
    super.initState();
    _checkCoachStatus();
  }

  Future<void> _checkCoachStatus() async {
    _isCoach = await locate<CoachProfileService>().isCoach();

    if (_isCoach) {
      setState(() {
        _isCoach = true;
        _isLoading = false;
      });
      return;
    }

    _hasPendingApplication =
        await locate<CoachProfileService>().hasPendingCoachApplication();
    if (_hasPendingApplication) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _applyToBeCoach() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await locate<CoachProfileService>().applyToBeCoach();

      setState(() {
        _hasPendingApplication = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application submitted successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit application: $e')),
        );
      }
    }
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

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child:
                  _isLoading
                      ? CircularProgressIndicator()
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isCoach)
                            ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                disabledForegroundColor: Colors.white,
                              ),
                              child: Text('You are a coach'),
                            )
                          else if (_hasPendingApplication)
                            ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                disabledForegroundColor: Colors.white,
                              ),
                              child: Text('Application pending...'),
                            )
                          else
                            ElevatedButton(
                              onPressed: _applyToBeCoach,
                              child: Text('Apply to be a coach'),
                            ),
                          SizedBox(height: 20),
                          Text(
                            _isCoach
                                ? 'You have coach privileges'
                                : _hasPendingApplication
                                ? 'Your application is under review'
                                : 'Submit your application to become a coach',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
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
                          onPressed: () => context.pop(),
                          child: Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
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
