import 'package:flutter/material.dart';
import 'package:lift_life/data/model/workout_models.dart';
import 'package:lift_life/helper/TextHelper.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workout.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout summary card
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TextHelper.workoutSummary,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          TextHelper.duration,
                          '${workout.duration ?? 0}m',
                          Icons.timer,
                        ),
                        _buildSummaryItem(
                          TextHelper.exercises,
                          '${workout.exercises.length}',
                          Icons.fitness_center,
                        ),
                        _buildSummaryItem(
                          TextHelper.sets,
                          '${workout.totalSets}',
                          Icons.repeat,
                        ),
                        _buildSummaryItem(
                          TextHelper.calories,
                          '${workout.estimatedCalories ?? 0}',
                          Icons.local_fire_department,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Exercises
            Text(TextHelper.exercises, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            ...workout.exercises.map(
              (exercise) => _buildExerciseDetail(exercise),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildExerciseDetail(WorkoutExercise exercise) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.exercise.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (exercise.sets.isNotEmpty) ...[
              const Row(
                children: [
                  SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      TextHelper.reps,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      TextHelper.weight,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...exercise.sets.asMap().entries.map((entry) {
                final setIndex = entry.key;
                final set = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(width: 40, child: Text('${setIndex + 1}')),
                      Expanded(child: Text('${set.reps}')),
                      Expanded(child: Text('${set.weight}kg')),
                    ],
                  ),
                );
              }).toList(),
            ] else
              const Text(TextHelper.noSetsRecorded),
          ],
        ),
      ),
    );
  }
}
