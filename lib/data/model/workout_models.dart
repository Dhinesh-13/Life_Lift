import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_models.g.dart';

@JsonSerializable()
class Exercise extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final String? imageUrl;
  final List<String> targetMuscles;
  final String difficulty;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.imageUrl,
    required this.targetMuscles,
    required this.difficulty,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  @override
  List<Object?> get props => [id, name, category, description, imageUrl, targetMuscles, difficulty];
}

@JsonSerializable()
class WorkoutSet extends Equatable {
  final int reps;
  final double weight;
  final int? restTime;
  final bool isCompleted;

  const WorkoutSet({
    required this.reps,
    required this.weight,
    this.restTime,
    this.isCompleted = false,
  });

  WorkoutSet copyWith({
    int? reps,
    double? weight,
    int? restTime,
    bool? isCompleted,
  }) {
    return WorkoutSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => _$WorkoutSetFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSetToJson(this);

  @override
  List<Object?> get props => [reps, weight, restTime, isCompleted];
}

@JsonSerializable()
class WorkoutExercise extends Equatable {
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final int? targetSets;
  final String notes;
  final bool isCompleted;

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
    this.targetSets,
    this.notes = '',
    this.isCompleted = false,
  });

  WorkoutExercise copyWith({
    Exercise? exercise,
    List<WorkoutSet>? sets,
    int? targetSets,
    String? notes,
    bool? isCompleted,
  }) {
    return WorkoutExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      targetSets: targetSets ?? this.targetSets,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => _$WorkoutExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutExerciseToJson(this);

  @override
  List<Object?> get props => [exercise, sets, targetSets, notes, isCompleted];
}

@JsonSerializable()
class Workout extends Equatable {
  final String id;
  final String name;
  final DateTime date;
  final List<WorkoutExercise> exercises;
  final int? duration;
  final int? estimatedCalories;
  final String notes;
  final bool isCompleted;
  final DateTime? startTime;
  final DateTime? endTime;

  const Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.exercises,
    this.duration,
    this.estimatedCalories,
    this.notes = '',
    this.isCompleted = false,
    this.startTime,
    this.endTime,
  });

  Workout copyWith({
    String? id,
    String? name,
    DateTime? date,
    List<WorkoutExercise>? exercises,
    int? duration,
    int? estimatedCalories,
    String? notes,
    bool? isCompleted,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      duration: duration ?? this.duration,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);
  int get completedExercises => exercises.where((e) => e.isCompleted).length;

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        date,
        exercises,
        duration,
        estimatedCalories,
        notes,
        isCompleted,
        startTime,
        endTime,
      ];
}
