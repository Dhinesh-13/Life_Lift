import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCountState extends Equatable {
  final int totalSteps;
  final double distanceKm;
  final int caloriesBurned;
  final String pedestrianStatus;
  final int dailyGoal;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  const StepCountState({
    this.totalSteps = 0,
    this.distanceKm = 0.0,
    this.caloriesBurned = 0,
    this.pedestrianStatus = 'unknown',
    this.dailyGoal = 10000,
    this.isLoading = false,
    this.error,
    required this.lastUpdated,
  });

  StepCountState copyWith({
    int? totalSteps,
    double? distanceKm,
    int? caloriesBurned,
    String? pedestrianStatus,
    int? dailyGoal,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return StepCountState(
      totalSteps: totalSteps ?? this.totalSteps,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      pedestrianStatus: pedestrianStatus ?? this.pedestrianStatus,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  double get progressPercentage => (totalSteps / dailyGoal).clamp(0.0, 1.0);
  int get remainingSteps => (dailyGoal - totalSteps).clamp(0, dailyGoal);
  bool get goalReached => totalSteps >= dailyGoal;

  @override
  List<Object?> get props => [
        totalSteps,
        distanceKm,
        caloriesBurned,
        pedestrianStatus,
        dailyGoal,
        isLoading,
        error,
        lastUpdated,
      ];
}

class StepCountCubit extends Cubit<StepCountState> {
  static const String _stepsKey = 'daily_steps';
  static const String _dateKey = 'last_update_date';
  static const String _goalKey = 'daily_goal';

  StepCountCubit() : super(StepCountState(lastUpdated: DateTime.now())) {
    _loadSavedData();
  }

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final prefs = await SharedPreferences.getInstance();
      final savedSteps = prefs.getInt(_stepsKey) ?? 0;
      final savedGoal = prefs.getInt(_goalKey) ?? 10000;
      final savedDateString = prefs.getString(_dateKey);
      
      final today = DateTime.now();
      DateTime savedDate = savedDateString != null 
          ? DateTime.parse(savedDateString) 
          : today;

      // Reset steps if it's a new day
      final isNewDay = !_isSameDay(savedDate, today);
      final stepsToUse = isNewDay ? 0 : savedSteps;
      
      emit(state.copyWith(
        totalSteps: stepsToUse,
        distanceKm: _calculateDistance(stepsToUse),
        caloriesBurned: _calculateCalories(stepsToUse),
        dailyGoal: savedGoal,
        lastUpdated: today,
        isLoading: false,
      ));

      if (isNewDay) {
        await _saveData();
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load saved data: $e',
        isLoading: false,
      ));
    }
  }

  // Update step count
  void updateStepCount(int steps) {
    final distance = _calculateDistance(steps);
    final calories = _calculateCalories(steps);
    
    emit(state.copyWith(
      totalSteps: steps,
      distanceKm: distance,
      caloriesBurned: calories,
      lastUpdated: DateTime.now(),
      error: null,
    ));
    
    _saveData();
  }

  // Update pedestrian status
  void updatePedestrianStatus(String status) {
    emit(state.copyWith(
      pedestrianStatus: status,
      lastUpdated: DateTime.now(),
    ));
  }

  // Set daily goal
  Future<void> setDailyGoal(int goal) async {
    try {
      emit(state.copyWith(dailyGoal: goal));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_goalKey, goal);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save goal: $e'));
    }
  }

  // Reset daily steps (for testing or manual reset)
  Future<void> resetSteps() async {
    try {
      emit(state.copyWith(
        totalSteps: 0,
        distanceKm: 0.0,
        caloriesBurned: 0,
        lastUpdated: DateTime.now(),
      ));
      await _saveData();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to reset steps: $e'));
    }
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_stepsKey, state.totalSteps);
      await prefs.setString(_dateKey, DateTime.now().toIso8601String());
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save data: $e'));
    }
  }

  // Calculate distance from steps (average step length ~0.8 meters)
  double _calculateDistance(int steps) {
    return steps * 0.0008; // km
  }

  // Calculate calories from steps (approximate: 0.04 calories per step)
  int _calculateCalories(int steps) {
    return (steps * 0.04).round();
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  // Get weekly step data (you can expand this for charts)
  Future<List<int>> getWeeklyStepData() async {
    // This is a placeholder - you can implement actual weekly data storage
    // For now, return current day's data
    return List.filled(7, state.totalSteps);
  }
}
