import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/presentation/dashboard/cubit/gym_cubit.dart';
import 'package:lift_life/presentation/dashboard/views/cycling_screen.dart';
import 'package:lift_life/presentation/dashboard/views/gym_screen.dart';
import 'package:lift_life/presentation/dashboard/views/walking_screen.dart';
import 'package:lift_life/helper/ColorHelper.dart';
import 'package:lift_life/helper/TextHelper.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';

class ActiveScreen extends StatefulWidget {
  const ActiveScreen({super.key});

  @override
  State<ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.only(top: 30.0, left: 10.0, bottom: 10.0),
          child: Text(
            'Activities',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),

            // 'Activities' replaced with TextHelper.status
          ),
        ),
        // backgroundColor: ColorHelper.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Activity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorHelper.textColor,
                // fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildActivityCard(
              context,
              title: TextHelper.walking,
              subtitle: TextHelper.stepsToday + ' & ' + TextHelper.distance,
              icon: Icons.directions_walk,
              color: ColorHelper.successColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalkingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Cycling Card (uncomment if needed)
            // _buildActivityCard(
            //   context,
            //   title: TextHelper.cycling,
            //   subtitle: TextHelper.distanceCycled + ' & ' + TextHelper.duration,
            //   icon: Icons.pedal_bike,
            //   color: ColorHelper.caloriesColor,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const CyclingScreen(),
            //       ),
            //     );
            //   },
            // ),
            const SizedBox(height: 16),
            _buildActivityCard(
              context,
              title: TextHelper.gymWorkout,
              subtitle: TextHelper.workout + ' & ' + TextHelper.duration,
              icon: Icons.fitness_center,
              color: ColorHelper.errorColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => GymCubit(),
                      child: GymScreen(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(1.0),
                Colors.white.withOpacity(1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorHelper.textColor,
                        // fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorHelper.borderColor,
                        // fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: ColorHelper.borderColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Cycling Screen


// Gym Screen

