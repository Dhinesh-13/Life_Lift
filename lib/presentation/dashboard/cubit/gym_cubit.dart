import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/data/model/workout_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GymState extends Equatable {
  final List<Workout> workoutHistory;
  final Workout? currentWorkout;
  final List<Exercise> availableExercises;
  final bool isLoading;
  final String? error;
  final bool isWorkoutActive;
  final DateTime? workoutStartTime;
  final bool showWorkoutCompleteMessage; // Added this missing property

  const GymState({
    this.workoutHistory = const [],
    this.currentWorkout,
    this.availableExercises = const [],
    this.isLoading = false,
    this.error,
    this.isWorkoutActive = false,
    this.workoutStartTime,
    this.showWorkoutCompleteMessage = false, // Added this
  });

  GymState copyWith({
    List<Workout>? workoutHistory,
    Workout? currentWorkout,
    List<Exercise>? availableExercises,
    bool? isLoading,
    String? error,
    bool? isWorkoutActive,
    DateTime? workoutStartTime,
    bool? showWorkoutCompleteMessage, // Added this
    bool clearCurrentWorkout = false, // Added for proper null handling
    bool clearError = false, // Added for proper null handling
  }) {
    return GymState(
      workoutHistory: workoutHistory ?? this.workoutHistory,
      currentWorkout: clearCurrentWorkout ? null : (currentWorkout ?? this.currentWorkout),
      availableExercises: availableExercises ?? this.availableExercises,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isWorkoutActive: isWorkoutActive ?? this.isWorkoutActive,
      workoutStartTime: workoutStartTime ?? this.workoutStartTime,
      showWorkoutCompleteMessage: showWorkoutCompleteMessage ?? this.showWorkoutCompleteMessage,
    );
  }

  // Getters for statistics
  int get totalWorkouts => workoutHistory.length;
  
  int get thisWeekWorkouts {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return workoutHistory
        .where((workout) => workout.date.isAfter(weekStart))
        .length;
  }

  int get totalMinutesThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return workoutHistory
        .where((workout) => workout.date.isAfter(weekStart))
        .fold(0, (sum, workout) => sum + (workout.duration ?? 0));
  }

  int get totalCaloriesThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return workoutHistory
        .where((workout) => workout.date.isAfter(weekStart))
        .fold(0, (sum, workout) => sum + (workout.estimatedCalories ?? 0));
  }

  @override
  List<Object?> get props => [
    workoutHistory,
    currentWorkout,
    availableExercises,
    isLoading,
    error,
    isWorkoutActive,
    workoutStartTime,
    showWorkoutCompleteMessage, // Added this
  ];
}

class GymCubit extends Cubit<GymState> {
  static const String _workoutHistoryKey = 'workout_history';
  static const String _currentWorkoutKey = 'current_workout';

  GymCubit() : super(const GymState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadData();
    _loadAvailableExercises();
  }

  // Added this missing method
  Future<void> refreshWorkoutData() async {
    try {
      if (state.currentWorkout != null) {
        // Trigger a state update to refresh UI
        emit(state.copyWith());
        await _saveCurrentWorkout();
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to refresh workout data: $e'));
    }
  }

  // Added this missing method
  void clearWorkoutCompleteMessage() {
    emit(state.copyWith(showWorkoutCompleteMessage: false));
  }

  Future<void> removeExerciseFromWorkout(int exerciseIndex) async {
    if (state.currentWorkout == null) return;

    try {
      // Check if exerciseIndex is valid
      if (exerciseIndex < 0 || exerciseIndex >= state.currentWorkout!.exercises.length) {
        emit(state.copyWith(error: 'Invalid exercise index'));
        return;
      }

      // Create a new list without the exercise at the specified index
      final exercises = [...state.currentWorkout!.exercises];
      exercises.removeAt(exerciseIndex);

      // Update the current workout with the new exercises list
      final updatedWorkout = state.currentWorkout!.copyWith(exercises: exercises);

      // Emit the new state
      emit(state.copyWith(currentWorkout: updatedWorkout, clearError: true));

      // Save the updated workout to storage
      await _saveCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to remove exercise: $e'));
    }
  }

  Future<void> loadData() async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));

      final prefs = await SharedPreferences.getInstance();

      // Load workout history
      final historyJson = prefs.getStringList(_workoutHistoryKey) ?? [];
      final history = historyJson
          .map((json) {
            try {
              return Workout.fromJson(jsonDecode(json));
            } catch (e) {
              print('Error parsing workout: $e');
              return null;
            }
          })
          .where((workout) => workout != null)
          .cast<Workout>()
          .toList();

      // Load current workout
      final currentWorkoutJson = prefs.getString(_currentWorkoutKey);
      Workout? currentWorkout;
      if (currentWorkoutJson != null && currentWorkoutJson.isNotEmpty) {
        try {
          currentWorkout = Workout.fromJson(jsonDecode(currentWorkoutJson));
        } catch (e) {
          print('Error parsing current workout: $e');
          // Clear corrupted data
          await prefs.remove(_currentWorkoutKey);
        }
      }

      emit(
        state.copyWith(
          workoutHistory: history,
          currentWorkout: currentWorkout,
          isWorkoutActive: currentWorkout != null,
          workoutStartTime: currentWorkout?.startTime,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to load workout data: $e',
          isLoading: false,
        ),
      );
    }
  }

  void _loadAvailableExercises() {
    try {
      // Sample exercises - you can load from a database or API
      final exercises = [
        const Exercise(
          id: '1',
          name: 'Bench Press',
          category: 'Chest',
          description: 'Compound exercise for chest, shoulders, and triceps',
          targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
          difficulty: 'intermediate',
        ),
        const Exercise(
          id: '2',
          name: 'Squats',
          category: 'Legs',
          description: 'Compound exercise for legs and glutes',
          targetMuscles: ['Quadriceps', 'Glutes', 'Hamstrings'],
          difficulty: 'beginner',
        ),
        const Exercise(
          id: '3',
          name: 'Deadlift',
          category: 'Back',
          description: 'Full body compound exercise',
          targetMuscles: ['Back', 'Glutes', 'Hamstrings', 'Traps'],
          difficulty: 'advanced',
        ),
        const Exercise(
          id: '4',
          name: 'Pull-ups',
          category: 'Back',
          description: 'Bodyweight exercise for back and arms',
          targetMuscles: ['Lats', 'Biceps', 'Rhomboids'],
          difficulty: 'intermediate',
        ),
        const Exercise(
          id: '5',
          name: 'Push-ups',
          category: 'Chest',
          description: 'Bodyweight exercise for chest and arms',
          targetMuscles: ['Chest', 'Triceps', 'Shoulders'],
          difficulty: 'beginner',
        ),
        const Exercise(
          id: '6',
          name: 'Overhead Press',
          category: 'Shoulders',
          description: 'Standing shoulder press with barbell or dumbbells',
          targetMuscles: ['Shoulders', 'Triceps', 'Core'],
          difficulty: 'intermediate',
        ),
        const Exercise(
          id: '7',
          name: 'Barbell Rows',
          category: 'Back',
          description: 'Bent-over rowing exercise for back development',
          targetMuscles: ['Lats', 'Rhomboids', 'Rear Delts', 'Biceps'],
          difficulty: 'intermediate',
        ),
      ];

      emit(state.copyWith(availableExercises: exercises));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load exercises: $e'));
    }
  }

  Future<void> startWorkout(String workoutName) async {
    try {
      if (state.isWorkoutActive) {
        emit(state.copyWith(error: 'Another workout is already active'));
        return;
      }

      final workout = Workout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: workoutName.trim().isEmpty ? 'My Workout' : workoutName.trim(),
        date: DateTime.now(),
        exercises: [],
        startTime: DateTime.now(),
      );

      emit(
        state.copyWith(
          currentWorkout: workout,
          isWorkoutActive: true,
          workoutStartTime: DateTime.now(),
          clearError: true,
        ),
      );

      await _saveCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to start workout: $e'));
    }
  }

  Future<void> addExerciseToWorkout(Exercise exercise) async {
    if (state.currentWorkout == null) {
      emit(state.copyWith(error: 'No active workout to add exercise to'));
      return;
    }

    try {
      // Check if exercise already exists in workout
      final existingExercise = state.currentWorkout!.exercises
          .any((we) => we.exercise.id == exercise.id);
      
      if (existingExercise) {
        emit(state.copyWith(error: 'Exercise already added to workout'));
        return;
      }

      final workoutExercise = WorkoutExercise(
        exercise: exercise,
        sets: [],
        targetSets: 3, // default target sets
      );

      final updatedExercises = [
        ...state.currentWorkout!.exercises,
        workoutExercise,
      ];
      
      final updatedWorkout = state.currentWorkout!.copyWith(exercises: updatedExercises);

      emit(state.copyWith(currentWorkout: updatedWorkout, clearError: true));
      await _saveCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add exercise: $e'));
    }
  }

  Future<void> addSetToExercise(int exerciseIndex, int reps, double weight) async {
    if (state.currentWorkout == null) {
      emit(state.copyWith(error: 'No active workout'));
      return;
    }

    if (exerciseIndex < 0 || exerciseIndex >= state.currentWorkout!.exercises.length) {
      emit(state.copyWith(error: 'Invalid exercise index'));
      return;
    }

    if (reps <= 0 || weight < 0) {
      emit(state.copyWith(error: 'Invalid reps or weight values'));
      return;
    }

    try {
      final workoutSet = WorkoutSet(
        reps: reps,
        weight: weight,
        isCompleted: false,
      );

      final exercises = [...state.currentWorkout!.exercises];
      final exercise = exercises[exerciseIndex];
      final updatedSets = [...exercise.sets, workoutSet];

      exercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);

      final updatedWorkout = state.currentWorkout!.copyWith(exercises: exercises);

      emit(state.copyWith(currentWorkout: updatedWorkout, clearError: true));
      await _saveCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add set: $e'));
    }
  }

  Future<void> completeSet(int exerciseIndex, int setIndex) async {
    if (state.currentWorkout == null) {
      emit(state.copyWith(error: 'No active workout'));
      return;
    }

    if (exerciseIndex < 0 || exerciseIndex >= state.currentWorkout!.exercises.length) {
      emit(state.copyWith(error: 'Invalid exercise index'));
      return;
    }

    final exercise = state.currentWorkout!.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) {
      emit(state.copyWith(error: 'Invalid set index'));
      return;
    }

    try {
      final exercises = [...state.currentWorkout!.exercises];
      final sets = [...exercise.sets];

      sets[setIndex] = sets[setIndex].copyWith(isCompleted: true);
      exercises[exerciseIndex] = exercise.copyWith(sets: sets);

      final updatedWorkout = state.currentWorkout!.copyWith(exercises: exercises);

      emit(state.copyWith(currentWorkout: updatedWorkout, clearError: true));
      await _saveCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to complete set: $e'));
    }
  }

  Future<void> finishWorkout() async {
    if (state.currentWorkout == null) {
      emit(state.copyWith(error: 'No active workout to finish'));
      return;
    }

    try {
      final endTime = DateTime.now();
      final startTime = state.currentWorkout!.startTime ?? endTime;
      final duration = endTime.difference(startTime).inMinutes;
      final estimatedCalories = _calculateCalories(
        duration,
        state.currentWorkout!.totalSets,
      );

      final completedWorkout = state.currentWorkout!.copyWith(
        isCompleted: true,
        endTime: endTime,
        duration: duration > 0 ? duration : 1, // Minimum 1 minute
        estimatedCalories: estimatedCalories,
      );

      final updatedHistory = [completedWorkout, ...state.workoutHistory];

      emit(
        state.copyWith(
          workoutHistory: updatedHistory,
          clearCurrentWorkout: true,
          isWorkoutActive: false,
          workoutStartTime: null,
          showWorkoutCompleteMessage: true,
          clearError: true,
        ),
      );

      await _saveWorkoutHistory();
      await _clearCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to finish workout: $e'));
    }
  }

  Future<void> cancelWorkout() async {
    if (state.currentWorkout == null) {
      emit(state.copyWith(error: 'No active workout to cancel'));
      return;
    }

    try {
      emit(
        state.copyWith(
          clearCurrentWorkout: true,
          isWorkoutActive: false,
          workoutStartTime: null,
          clearError: true,
        ),
      );

      await _clearCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to cancel workout: $e'));
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      final updatedHistory = state.workoutHistory
          .where((workout) => workout.id != workoutId)
          .toList();

      emit(state.copyWith(workoutHistory: updatedHistory, clearError: true));
      await _saveWorkoutHistory();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete workout: $e'));
    }
  }

  int _calculateCalories(int durationMinutes, int totalSets) {
    // Basic calorie calculation: 5-8 calories per minute depending on intensity
    const baseCaloriesPerMinute = 6;
    const caloriesPerSet = 3;
    final duration = durationMinutes > 0 ? durationMinutes : 1;
    return (duration * baseCaloriesPerMinute) + (totalSets * caloriesPerSet);
  }

  Future<void> _saveWorkoutHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = state.workoutHistory
          .map((workout) => jsonEncode(workout.toJson()))
          .toList();
      await prefs.setStringList(_workoutHistoryKey, historyJson);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save workout history: $e'));
    }
  }

  Future<void> _saveCurrentWorkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state.currentWorkout != null) {
        await prefs.setString(
          _currentWorkoutKey,
          jsonEncode(state.currentWorkout!.toJson()),
        );
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save current workout: $e'));
    }
  }

  Future<void> _clearCurrentWorkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentWorkoutKey);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to clear current workout: $e'));
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    // Save current workout before closing
    if (state.currentWorkout != null) {
      _saveCurrentWorkout();
    }
    return super.close();
  }
}
