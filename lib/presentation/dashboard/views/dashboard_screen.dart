import 'package:flutter/material.dart';
import 'package:lift_life/presentation/dashboard/views/active_screen.dart';
import 'package:lift_life/presentation/dashboard/views/caloriesTracker_screen.dart';
import 'package:lift_life/presentation/dashboard/views/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    FoodTrackerHomeScreen(),
    CaloriesTrackerScreen(),
    ActiveScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.connect_without_contact_sharp),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Activities',
          ),
        ],
      ),
    );
  }
}
