// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_models.dart';

// ***************************************************************************
// JsonSerializableGenerator
// ***************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      targetMuscles:
          (json['targetMuscles'] as List<dynamic>).map((e) => e as String).toList(),
      difficulty: json['difficulty'] as String,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'targetMuscles': instance.targetMuscles,
      'difficulty': instance.difficulty,
    };

WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => WorkoutSet(
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
      restTime: json['restTime'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkoutSetToJson(WorkoutSet instance) => <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'restTime': instance.restTime,
      'isCompleted': instance.isCompleted,
    };

WorkoutExercise _$WorkoutExerciseFromJson(Map<String, dynamic> json) => WorkoutExercise(
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      targetSets: json['targetSets'] as int?,
      notes: json['notes'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkoutExerciseToJson(WorkoutExercise instance) => <String, dynamic>{
      'exercise': instance.exercise.toJson(),
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'targetSets': instance.targetSets,
      'notes': instance.notes,
      'isCompleted': instance.isCompleted,
    };

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: json['duration'] as int?,
      estimatedCalories: json['estimatedCalories'] as int?,
      notes: json['notes'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'duration': instance.duration,
      'estimatedCalories': instance.estimatedCalories,
      'notes': instance.notes,
      'isCompleted': instance.isCompleted,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
    };
