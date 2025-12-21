import 'package:flutter/material.dart';
import 'package:level_up_coach/conversations/conversations_screen.dart';
import 'package:level_up_coach/profile/coach_profile_service.dart';
import 'package:level_up_coach/profile/profile_screen.dart';
import 'package:level_up_coach/workouts/screens/workouts_screen.dart';
import 'package:level_up_shared/level_up_shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isCoach = false;

  final List<Widget> _screens = [
    ConversationsScreen(),
    WorkoutsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: locate<CoachProfileService>().isCoach(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text(snapshot.error.toString())));
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        _isCoach = snapshot.data!;
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1 && !_isCoach) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coach features are not yet available'),
                  ),
                );
                return;
              }
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Conversations',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_card),
                label: 'Workouts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
