import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/data/model/workout_models.dart';
import 'package:lift_life/presentation/dashboard/cubit/gym_cubit.dart';
import 'exercise_selection_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final Color baseBlue = Colors.blue[100]!;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // This will update the duration display
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GymCubit, GymState>(
      builder: (context, state) {
        final workout = state.currentWorkout;

        if (workout == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Workout')),
            body: const Center(child: Text('No active workout')),
          );
        }

        return PopScope(
          onPopInvoked: (didPop) {
            // Handle back navigation
            if (didPop) {
              // Optional: Add any cleanup logic here
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(workout.name),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'finish') {
                      _showFinishWorkoutDialog();
                    } else if (value == 'cancel') {
                      _showCancelWorkoutDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'finish',
                      child: Row(
                        children: [
                          Icon(Icons.check, color: baseBlue),
                          const SizedBox(width: 8),
                          const Text('Finish Workout'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.close, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Cancel Workout'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                // Workout timer and stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimerStat(
                        'Duration',
                        _getWorkoutDuration(workout.startTime!),
                        Icons.timer,
                      ),
                      _buildTimerStat(
                        'Exercises',
                        '${workout.exercises.length}',
                        Icons.fitness_center,
                      ),
                      _buildTimerStat(
                        'Sets',
                        '${workout.totalSets}',
                        Icons.repeat,
                      ),
                    ],
                  ),
                ),

                // Exercises list
                Expanded(
                  child: workout.exercises.isEmpty
                      ? _buildEmptyExercisesList()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: workout.exercises.length,
                          itemBuilder: (context, index) {
                            return _buildExerciseCard(
                              workout.exercises[index],
                              index,
                            );
                          },
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<GymCubit>(),
                      child: const ExerciseSelectionScreen(
                        isSelectingForWorkout: true,
                      ),
                    ),
                  ),
                );
                // No need to call loadData() since using same cubit instance
              },
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Add Exercise',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 170, 160, 160), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmptyExercisesList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No exercises added yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to add exercises to your workout',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    WorkoutExercise workoutExercise,
    int exerciseIndex,
  ) {
    return Card(
      elevation: 8,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutExercise.exercise.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        workoutExercise.exercise.category,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showAddSetDialog(exerciseIndex);
                  },
                  icon: const Icon(Icons.add_circle),
                  color: Colors.black,
                ),
                IconButton(
                  onPressed: () {
                    _showRemoveExerciseDialog(
                      exerciseIndex,
                      workoutExercise.exercise.name,
                    );
                  },
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Sets
            if (workoutExercise.sets.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No sets added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Sets header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            'Set',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            'Reps',
                            style: TextStyle(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            'Weight',
                            style: TextStyle(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Sets list
                  ...workoutExercise.sets.asMap().entries.map((entry) {
                    final setIndex = entry.key;
                    final set = entry.value;
                    return _buildSetRow(exerciseIndex, setIndex, set);
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, WorkoutSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(child: Text('${set.reps}', textAlign: TextAlign.center)),
          const SizedBox(width: 20),
          Expanded(child: Text('${set.weight}kg', textAlign: TextAlign.center)),
          SizedBox(
            width: 40,
            child: Checkbox(
              value: set.isCompleted,
              onChanged: (value) {
                if (value == true) {
                  context.read<GymCubit>().completeSet(exerciseIndex, setIndex);
                }
              },
              activeColor: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveExerciseDialog(int exerciseIndex, String exerciseName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Remove Exercise'),
        content: Text(
          'Are you sure you want to remove "$exerciseName" from your workout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<GymCubit>().removeExerciseFromWorkout(
                exerciseIndex,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$exerciseName removed from workout'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSetDialog(int exerciseIndex) {
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                focusColor: Colors.black,
                labelText: 'Reps',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reps = int.tryParse(repsController.text);
              final weight = double.tryParse(weightController.text);

              if (reps != null && weight != null && reps > 0 && weight >= 0) {
                await context.read<GymCubit>().addSetToExercise(
                  exerciseIndex,
                  reps,
                  weight,
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid reps and weight values'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: baseBlue),
            child: const Text('Add Set', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showFinishWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Finish Workout'),
        content: const Text('Are you sure you want to finish this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              await context.read<GymCubit>().finishWorkout();

              if (mounted) {
                Navigator.pop(context); // Close workout screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workout completed! 🎉'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Finish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Cancel Workout'),
        content: const Text(
          'Are you sure you want to cancel this workout? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Workout',
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              await context.read<GymCubit>().cancelWorkout();

              if (mounted) {
                Navigator.pop(context); // Close workout screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workout cancelled'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Cancel Workout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getWorkoutDuration(DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
