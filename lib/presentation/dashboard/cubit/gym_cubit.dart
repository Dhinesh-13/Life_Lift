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

  const GymState({
    this.workoutHistory = const [],
    this.currentWorkout,
    this.availableExercises = const [],
    this.isLoading = false,
    this.error,
    this.isWorkoutActive = false,
    this.workoutStartTime,
  });

  GymState copyWith({
    List<Workout>? workoutHistory,
    Workout? currentWorkout,
    List<Exercise>? availableExercises,
    bool? isLoading,
    String? error,
    bool? isWorkoutActive,
    DateTime? workoutStartTime,
  }) {
    return GymState(
      workoutHistory: workoutHistory ?? this.workoutHistory,
      currentWorkout: currentWorkout ?? this.currentWorkout,
      availableExercises: availableExercises ?? this.availableExercises,
      isLoading: isLoading ?? this.isLoading,
      error: error??this.error,
      isWorkoutActive: isWorkoutActive ?? this.isWorkoutActive,
      workoutStartTime: workoutStartTime ?? this.workoutStartTime,
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
  ];
}

class GymCubit extends Cubit<GymState> {
  static const String _workoutHistoryKey = 'workout_history';
  static const String _currentWorkoutKey = 'current_workout';

  GymCubit() : super(const GymState()) {
    loadData();
    _loadAvailableExercises();
  }

  Future<void> loadData() async {
    try {
      emit(state.copyWith(isLoading: true));

      final prefs = await SharedPreferences.getInstance();

      // Load workout history
      final historyJson = prefs.getStringList(_workoutHistoryKey) ?? [];
      final history = historyJson
          .map((json) => Workout.fromJson(jsonDecode(json)))
          .toList();

      // Load current workout
      final currentWorkoutJson = prefs.getString(_currentWorkoutKey);
      Workout? currentWorkout;
      if (currentWorkoutJson != null) {
        currentWorkout = Workout.fromJson(jsonDecode(currentWorkoutJson));
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
    ];

    emit(state.copyWith(availableExercises: exercises));
  }

  Future<void> startWorkout(String workoutName) async {
    try {
      final workout = Workout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: workoutName,
        date: DateTime.now(),
        exercises: [],
        startTime: DateTime.now(),
      );
      // print(workout.name );
      // print(workout.date);
      // print(workout.startTime);
      emit(
        state.copyWith(
          currentWorkout: workout,
          isWorkoutActive: true,
          workoutStartTime: DateTime.now(),
        
        ),
      );
         print('After emit - Current state: ${state.currentWorkout?.name}');

      await _saveCurrentWorkout();
      print(state.currentWorkout);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to start workout: $e'));
    }
  }

  Future<void> addExerciseToWorkout(Exercise exercise) async {
    if (state.currentWorkout == null) return;

    try {
      final workoutExercise = WorkoutExercise(
        exercise: exercise,
        sets: [],
        targetSets: 3, // default target sets
      );

      final updatedExercises = [
        ...state.currentWorkout!.exercises,
        workoutExercise,
      ];
      final updatedWorkout = state.currentWorkout!.copyWith(
        exercises: updatedExercises,
      );

      emit(state.copyWith(currentWorkout: updatedWorkout));
      await _saveCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add exercise: $e'));
    }
  }

  Future<void> addSetToExercise(
    int exerciseIndex,
    int reps,
    double weight,
  ) async {
    if (state.currentWorkout == null) return;

    try {
      final workoutSet = WorkoutSet(reps: reps, weight: weight);

      final exercises = [...state.currentWorkout!.exercises];
      final exercise = exercises[exerciseIndex];
      final updatedSets = [...exercise.sets, workoutSet];

      exercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);

      final updatedWorkout = state.currentWorkout!.copyWith(
        exercises: exercises,
      );

      emit(state.copyWith(currentWorkout: updatedWorkout));
      await _saveCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add set: $e'));
    }
  }

  Future<void> completeSet(int exerciseIndex, int setIndex) async {
    if (state.currentWorkout == null) return;

    try {
      final exercises = [...state.currentWorkout!.exercises];
      final exercise = exercises[exerciseIndex];
      final sets = [...exercise.sets];

      sets[setIndex] = sets[setIndex].copyWith(isCompleted: true);
      exercises[exerciseIndex] = exercise.copyWith(sets: sets);

      final updatedWorkout = state.currentWorkout!.copyWith(
        exercises: exercises,
      );

      emit(state.copyWith(currentWorkout: updatedWorkout));
      await _saveCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to complete set: $e'));
    }
  }

  Future<void> finishWorkout() async {
    if (state.currentWorkout == null) return;

    try {
      final endTime = DateTime.now();
      final duration = endTime
          .difference(state.currentWorkout!.startTime!)
          .inMinutes;
      final estimatedCalories = _calculateCalories(
        duration,
        state.currentWorkout!.totalSets,
      );

      final completedWorkout = state.currentWorkout!.copyWith(
        isCompleted: true,
        endTime: endTime,
        duration: duration,
        estimatedCalories: estimatedCalories,
      );

      final updatedHistory = [completedWorkout, ...state.workoutHistory];

      emit(
        state.copyWith(
          workoutHistory: updatedHistory,
          currentWorkout: null,
          isWorkoutActive: false,
          workoutStartTime: null,
        ),
      );

      await _saveWorkoutHistory();
      await _clearCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to finish workout: $e'));
    }
  }

  Future<void> cancelWorkout() async {
    try {
      emit(
        state.copyWith(
          currentWorkout: null,
          isWorkoutActive: false,
          workoutStartTime: null,
        ),
      );

      await _clearCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to cancel workout: $e'));
    }
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
      emit(state.copyWith(currentWorkout: updatedWorkout));

      // Save the updated workout to storage
      await _saveCurrentWorkout();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to remove exercise: $e'));
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      final updatedHistory = state.workoutHistory
          .where((workout) => workout.id != workoutId)
          .toList();

      emit(state.copyWith(workoutHistory: updatedHistory));
      await _saveWorkoutHistory();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete workout: $e'));
    }
  }

  int _calculateCalories(int durationMinutes, int totalSets) {
    // Basic calorie calculation: 5-8 calories per minute depending on intensity
    const baseCaloriesPerMinute = 6;
    const caloriesPerSet = 3;
    return (durationMinutes * baseCaloriesPerMinute) +
        (totalSets * caloriesPerSet);
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
         print(state.currentWorkout);
      }
      print(
        state.currentWorkout?.name);
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
    emit(state.copyWith(error: null));
  }
}
