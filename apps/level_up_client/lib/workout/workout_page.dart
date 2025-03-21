import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/utils/locator.dart';
import 'package:level_up/workout/models/workout.dart';
import 'package:level_up/workout/services/workouts_service.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  late TabController _tabController;
  late List<Workout> _workouts;

  @override
  void initState() {
    super.initState();
    _workouts = locate<WorkoutsService>().retrieveWorkouts();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.sports_basketball), text: 'Basketball'),
            Tab(icon: Icon(Icons.electric_bolt), text: 'Performance'),
            Tab(icon: Icon(Icons.add_moderator_outlined), text: 'Strength'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _workouts.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          'workout-screen',
                          pathParameters: {'workoutId': _workouts[index].id},
                        );
                      },
                      child: Image.asset(
                        _workouts[index].image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _workouts.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                width: 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
