import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_client/workout/services/workouts_service.dart';
import 'package:level_up_shared/level_up_shared.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  late TabController _tabController;
  List<Workout> _workouts = [];
  bool _loadingWorkouts = true;
  String? _error;

  Future<void> _retrieveWorkouts() async {
    try {
      _workouts = await locate<WorkoutsService>().retrieveWorkouts();
    } catch (e) {
      _error = 'Could not load workouts. Please check your connection.';
    }
    if (mounted) {
      setState(() {
        _loadingWorkouts = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _retrieveWorkouts();
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
      body:
          (_loadingWorkouts)
              ? Center(child: CircularProgressIndicator())
              : (_error != null)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadingWorkouts = true;
                          _error = null;
                        });
                        _retrieveWorkouts();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Column(
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
                                  pathParameters: {
                                    'workoutId': _workouts[index].id,
                                  },
                                );
                              },
                              child: Image.network(
                                locate<WorkoutsService>().getWorkoutImageUrl(
                                  _workouts[index].id,
                                ),
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
