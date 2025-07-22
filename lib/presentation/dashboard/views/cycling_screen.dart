import 'package:flutter/material.dart';
import 'package:lift_life/helper/ColorHelper.dart';
import 'package:lift_life/helper/TextHelper.dart';

class CyclingScreen extends StatefulWidget {
  const CyclingScreen({super.key});

  @override
  State<CyclingScreen> createState() => _CyclingScreenState();
}

class _CyclingScreenState extends State<CyclingScreen> {
  double distanceKm = 12.5;
  String duration = '45:30';
  double avgSpeed = 16.7;
  int caloriesBurned = 420;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorHelper.backgroundColor,
      appBar: AppBar(
        title: Text(
          TextHelper.cycling,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: ColorHelper.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Distance Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [ColorHelper.caloriesColor.withOpacity(0.7), ColorHelper.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.pedal_bike,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      TextHelper.distanceCycled,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Statistics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCyclingStatCard(
                  'Duration',
                  duration,
                  Icons.timer,
                  Colors.blue,
                ),
                _buildCyclingStatCard(
                  'Avg Speed',
                  '${avgSpeed.toStringAsFixed(1)} km/h',
                  Icons.speed,
                  Colors.green,
                ),
                _buildCyclingStatCard(
                  'Calories',
                  '$caloriesBurned cal',
                  Icons.local_fire_department,
                  Colors.red,
                ),
                _buildCyclingStatCard(
                  'Elevation',
                  '245 m',
                  Icons.terrain,
                  Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Start Cycling Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Start cycling session
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cycling session started!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Cycling',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclingStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}