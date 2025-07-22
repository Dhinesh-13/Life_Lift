import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/data/model/workout_models.dart';
import 'package:lift_life/presentation/dashboard/cubit/gym_cubit.dart';


class ExerciseSelectionScreen extends StatefulWidget {
  final bool isSelectingForWorkout;
  
  const ExerciseSelectionScreen({
    super.key,
    this.isSelectingForWorkout = false,
  });

  @override
  State<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelectingForWorkout ? 'Add Exercise' : 'Exercises'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<GymCubit, GymState>(
        builder: (context, state) {
          final exercises = _filterExercises(state.availableExercises);
          final categories = _getCategories(state.availableExercises);

          return Column(
            children: [
              // Search and filter
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search exercises...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Exercises list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _buildExerciseCard(exercise);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    return exercises.where((exercise) {
      final matchesCategory = _selectedCategory == 'All' || exercise.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exercise.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> _getCategories(List<Exercise> exercises) {
    final categories = <String>{'All'};
    for (final exercise in exercises) {
      categories.add(exercise.category);
    }
    return categories.toList();
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(exercise.category),
          child: Text(
            exercise.category[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.description),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: exercise.targetMuscles.map((muscle) {
                return Chip(
                  label: Text(
                    muscle,
                    style: const TextStyle(fontSize: 10),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
        trailing: widget.isSelectingForWorkout
            ? IconButton(
                onPressed: () {
                  context.read<GymCubit>().addExerciseToWorkout(exercise);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${exercise.name} added to workout'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle),
                color: Colors.green[600],
              )
            : Icon(
                Icons.fitness_center,
                color: Colors.grey[600],
              ),
        isThreeLine: true,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return Colors.red[600]!;
      case 'back':
        return Colors.blue[600]!;
      case 'legs':
        return Colors.green[600]!;
      case 'shoulders':
        return Colors.orange[600]!;
      case 'arms':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
