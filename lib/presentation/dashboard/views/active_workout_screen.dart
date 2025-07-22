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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GymCubit, GymState>(
      builder: (context, state) {
        final workout = state.currentWorkout;
        
        if (workout == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Workout')),
            body: const Center(
              child: Text('No active workout'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(workout.name),
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
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
                  const PopupMenuItem(
                    value: 'finish',
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Finish Workout'),
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
                  color: Colors.green[50],
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExerciseSelectionScreen(
                    isSelectingForWorkout: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
            backgroundColor: Colors.green[600],
          ),
        );
      },
    );
  }

  Widget _buildTimerStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[600], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
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
            Icon(
              Icons.fitness_center,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises added yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
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

  Widget _buildExerciseCard(WorkoutExercise workoutExercise, int exerciseIndex) {
    return Card(
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showAddSetDialog(exerciseIndex);
                  },
                  icon: const Icon(Icons.add_circle),
                  color: Colors.green[600],
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 40),
                        const Expanded(child: Text('Reps', style: TextStyle(fontWeight: FontWeight.w600))),
                        const Expanded(child: Text('Weight', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(width: 40),
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
          Expanded(
            child: Text(
              '${set.reps}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '${set.weight}kg',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            child: Checkbox(
              value: set.isCompleted,
              onChanged: (value) {
                if (value == true) {
                  context.read<GymCubit>().completeSet(exerciseIndex, setIndex);
                }
              },
              activeColor: Colors.green[600],
            ),
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
        title: const Text('Add Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reps = int.tryParse(repsController.text);
              final weight = double.tryParse(weightController.text);

              if (reps != null && weight != null) {
                context.read<GymCubit>().addSetToExercise(exerciseIndex, reps, weight);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Set'),
          ),
        ],
      ),
    );
  }

  void _showFinishWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Workout'),
        content: const Text('Are you sure you want to finish this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GymCubit>().finishWorkout();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close workout screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout completed! 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _showCancelWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Workout'),
        content: const Text(
          'Are you sure you want to cancel this workout? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Workout'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GymCubit>().cancelWorkout();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close workout screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Workout'),
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
