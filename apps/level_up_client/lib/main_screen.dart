import 'package:flutter/material.dart';
import 'package:level_up/profile/profile_screen.dart';
import 'package:level_up/workout/workout_screen.dart';
import 'package:level_up_shared/level_up_shared.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    WorkoutScreen(),
    ChatScreen(
      conversationId: locate<AuthService>().currentUserId!,
      currentUserId: locate<AuthService>().currentUserId!,
    ),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
