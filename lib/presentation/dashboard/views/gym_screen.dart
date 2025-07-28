import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/data/model/workout_models.dart';
import 'package:lift_life/helper/nav_helper/nav_helper.dart';
import 'package:lift_life/helper/routes.dart';
import 'package:lift_life/presentation/dashboard/cubit/gym_cubit.dart';
import 'active_workout_screen.dart';
import 'workout_detail_screen.dart';
import 'package:lift_life/helper/ColorHelper.dart';
import 'package:lift_life/helper/TextHelper.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load data when screen initializes
    print('Second time');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GymCubit>().loadData();
      // Future.delayed(Duration.zero,() => context.read<GymCubit>().loadData(),);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This will be called when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      context.read<GymCubit>().loadData();
    }
  }

  void refreshIndicator() {
    setState(() {
      print('refresh sucess');
       context.read<GymCubit>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    refreshIndicator();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TextHelper.gymWorkout,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          BlocBuilder<GymCubit, GymState>(
            builder: (context, state) {
              if (state.isWorkoutActive) {
                return IconButton(
                  icon: const Icon(Icons.fitness_center),
                  onPressed: () async {
                    // Use the same cubit instance, don't create new one
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<GymCubit>(),
                          child: const ActiveWorkoutScreen(),
                        ),
                      ),
                    );
                    // Refresh data when coming back
                    if (mounted) {
                      context.read<GymCubit>().loadData();
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<GymCubit, GymState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Reload data
              await context.read<GymCubit>().loadData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error handling
                  if (state.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ColorHelper.errorColor.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: ColorHelper.errorColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: const TextStyle(
                                color: ColorHelper.errorColor,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: ColorHelper.errorColor,
                            ),
                            onPressed: () {
                              context.read<GymCubit>().clearError();
                            },
                          ),
                        ],
                      ),
                    ),

                  // Active workout or start workout card
                  if (state.isWorkoutActive)
                    _buildActiveWorkoutCard(state.currentWorkout!)
                  else
                    _buildStartWorkoutCard(),

                  const SizedBox(height: 16),

                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildGymStatCard(
                          TextHelper.thisWeek,
                          '${state.thisWeekWorkouts} ${TextHelper.exercises}',
                          Icons.calendar_today,
                          ColorHelper.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGymStatCard(
                          TextHelper.totalTime,
                          _formatDuration(state.totalMinutesThisWeek),
                          Icons.timer,
                          ColorHelper.secondaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Additional stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildGymStatCard(
                          TextHelper.calories,
                          '${state.totalCaloriesThisWeek} ${TextHelper.calories}',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGymStatCard(
                          TextHelper.totalWorkouts,
                          '${state.totalWorkouts}',
                          Icons.fitness_center,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Workout History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        TextHelper.recentWorkouts,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (state.workoutHistory.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            // Navigate to full history
                          },
                          child: const Text(
                            TextHelper.viewAll,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (state.workoutHistory.isEmpty)
                    _buildEmptyState()
                  else
                    ...state.workoutHistory
                        .take(5)
                        .map((workout) => _buildWorkoutHistoryCard(workout)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartWorkoutCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[50]!, Colors.grey[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.fitness_center,
                size: 32,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              TextHelper.readyForToday,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              TextHelper.workouts,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[800]!, Colors.grey[900]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showStartWorkoutDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.play_arrow, size: 20),
                      label: Text(
                        TextHelper.startWorkout,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        navigateToScreen(
                          Routes.exerciseSelectionScreen,
                          arguments: {'isSelectingForWorkout': false},
                        );
                        // Use the same cubit instance, don't create new one
                        // final result =  Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => BlocProvider.value(
                        //       value: context.read<GymCubit>(),
                        //       child: const ExerciseSelectionScreen(),
                        //     ),
                        //   ),
                        // );
                        // Refresh data when coming back
                        if (mounted) {
                          context.read<GymCubit>().loadData();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.grey[700],
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.list, size: 20),
                      label: Text(
                        TextHelper.exercises,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutCard(Workout workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.play_circle_filled,
                  size: 32,
                  color: Colors.blue[700],
                ),
                onPressed: () async {
                  // Use the same cubit instance
                  refreshIndicator();

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: context.read<GymCubit>(),
                        child: const ActiveWorkoutScreen(),
                      ),
                    ),
                  );
                  // Refresh data when coming back
                  if (mounted) {
                    context.read<GymCubit>().loadData();
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              workout.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              TextHelper.workoutInProgress,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${workout.exercises.length} exercises • ${workout.totalSets} sets',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[700]!],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  refreshIndicator();
                  navigateToScreen(Routes.activeWorkoutScreen);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.fitness_center, size: 20),
                label: Text(
                  TextHelper.workoutInProgress,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutHistoryCard(Workout workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          child: Icon(Icons.fitness_center, color: Colors.grey[600], size: 20),
        ),
        title: Text(
          TextHelper.workoutInProgress,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${_formatDate(workout.date)} • ${workout.exercises.length} exercises • ${workout.duration ?? 0}m • ${workout.estimatedCalories ?? 0} cal',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (workout.isCompleted)
              Icon(Icons.check_circle, color: Colors.green[600], size: 16),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
          ],
        ),
        onTap: () {
          // navigateToScreen(Routes.workoutDetailScreen, arguments: {'workout': workout});
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(workout: workout),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            TextHelper.noWorkoutsYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            TextHelper.startYourFirstWorkout,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGymStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[50]!, Colors.grey[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3), width: 0.5),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showStartWorkoutDialog() {
    final controller = TextEditingController(text: 'Fit Time');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(TextHelper.startNewWorkout),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: TextHelper.workoutName,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(TextHelper.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GymCubit>().startWorkout(controller.text);
              refreshIndicator();
              navigateToScreen(Routes.activeWorkoutScreen);
            },
            child: const Text(TextHelper.start),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0
          ? '${hours}h ${remainingMinutes}m'
          : '${hours}h';
    }
  }
}
