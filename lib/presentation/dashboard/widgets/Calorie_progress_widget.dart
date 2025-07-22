import 'package:flutter/material.dart';

class CalorieProgressWidget extends StatelessWidget {
  final double currentCalories;
  final double goalCalories;

  const CalorieProgressWidget({
    Key? key,
    required this.currentCalories,
    required this.goalCalories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (currentCalories / goalCalories).clamp(0.0, 1.0);
    final remaining = (goalCalories - currentCalories).clamp(0.0, goalCalories);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[200]!),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                // Progress Circle
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? Colors.green[500]! : Colors.orange[500]!,
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                // Center Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: progress >= 1.0 ? Colors.green[500] : Colors.orange[500],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${currentCalories.toInt()}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "of ${goalCalories.toInt()} kcal",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            remaining > 0 
                ? "${remaining.toInt()} kcal remaining"
                : "Goal reached! 🎉",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: remaining > 0 ? Colors.blue[600] : Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }
}