import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final String? imageUrl;
  final List<String> targetMuscles;
  final String difficulty; // beginner, intermediate, advanced

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.imageUrl,
    required this.targetMuscles,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'targetMuscles': targetMuscles,
      'difficulty': difficulty,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      targetMuscles: List<String>.from(json['targetMuscles']),
      difficulty: json['difficulty'],
    );
  }

  @override
  List<Object?> get props => [id, name, category, description, imageUrl, targetMuscles, difficulty];
}

class WorkoutSet extends Equatable {
  final int reps;
  final double weight;
  final int? restTime; // in seconds
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

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'restTime': restTime,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      reps: json['reps'],
      weight: json['weight'].toDouble(),
      restTime: json['restTime'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  @override
  List<Object?> get props => [reps, weight, restTime, isCompleted];
}

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

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets.map((set) => set.toJson()).toList(),
      'targetSets': targetSets,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exercise: Exercise.fromJson(json['exercise']),
      sets: (json['sets'] as List).map((set) => WorkoutSet.fromJson(set)).toList(),
      targetSets: json['targetSets'],
      notes: json['notes'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  @override
  List<Object?> get props => [exercise, sets, targetSets, notes, isCompleted];
}

class Workout extends Equatable {
  final String id;
  final String name;
  final DateTime date;
  final List<WorkoutExercise> exercises;
  final int? duration; // in minutes
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

  int get totalSets => exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);
  int get completedExercises => exercises.where((exercise) => exercise.isCompleted).length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'duration': duration,
      'estimatedCalories': estimatedCalories,
      'notes': notes,
      'isCompleted': isCompleted,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((exercise) => WorkoutExercise.fromJson(exercise))
          .toList(),
      duration: json['duration'],
      estimatedCalories: json['estimatedCalories'],
      notes: json['notes'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

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
