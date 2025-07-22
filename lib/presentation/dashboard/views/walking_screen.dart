import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/presentation/dashboard/cubit/step_count_cubit.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lift_life/helper/ColorHelper.dart';
import 'package:lift_life/helper/TextHelper.dart';

class WalkingScreen extends StatefulWidget {
  const WalkingScreen({super.key});

  @override
  State<WalkingScreen> createState() => _WalkingScreenState();
}

class _WalkingScreenState extends State<WalkingScreen>
    with WidgetsBindingObserver {
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPedometer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initPedometer();
    }
  }

  Future<void> _initPedometer() async {
    bool granted = await _checkActivityRecognitionPermission();
    setState(() {
      _isPermissionGranted = granted;
    });

    if (!granted) {
      _showPermissionDialog();
      return;
    }

    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );

      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
      );
    } catch (e) {
      context.read<StepCountCubit>().clearError();
    }
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    var status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      status = await Permission.activityRecognition.request();
    }
    return status.isGranted;
  }

  void _onStepCount(StepCount event) {
    context.read<StepCountCubit>().updateStepCount(event.steps);
  }

  void _onStepCountError(error) {
    debugPrint('Step count error: $error');
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    context.read<StepCountCubit>().updatePedestrianStatus(event.status);
  }

  void _onPedestrianStatusError(error) {
    context.read<StepCountCubit>().updatePedestrianStatus('unavailable');
    debugPrint('Pedestrian status error: $error');
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          TextHelper.error,
          style: const TextStyle(fontFamily: 'Roboto'),
        ),
        content: Text(
          'This app needs activity recognition permission to count your steps. Please grant permission in settings.',
          style: const TextStyle(fontFamily: 'Roboto'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              TextHelper.back,
              style: const TextStyle(fontFamily: 'Roboto'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text(
              TextHelper.next,
              style: const TextStyle(fontFamily: 'Roboto'),
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog() {
    final controller = TextEditingController(
      text: context.read<StepCountCubit>().state.dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          TextHelper.stepsGoal,
          style: const TextStyle(fontFamily: 'Roboto'),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Steps',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              TextHelper.back,
              style: const TextStyle(fontFamily: 'Roboto'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                context.read<StepCountCubit>().setDailyGoal(goal);
                Navigator.pop(context);
              }
            },
            child: Text(
              TextHelper.next,
              style: const TextStyle(fontFamily: 'Roboto'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white, // Optional: sets background white
        foregroundColor: Colors.black, // Sets back arrow and title color
        title: Text(
          TextHelper.walking,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Makes flag & refresh icons black
        actions: [
          IconButton(
            onPressed: _showGoalDialog,
            icon: const Icon(Icons.flag),
            tooltip: TextHelper.stepsGoal,
          ),
          IconButton(
            onPressed: () {
              context.read<StepCountCubit>().resetSteps();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Steps',
          ),
        ],
      ),
      body: BlocBuilder<StepCountCubit, StepCountState>(
        builder: (context, state) {
          if (!_isPermissionGranted) {
            return _buildPermissionScreen();
          }

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _initPedometer();
            },
            child: SingleChildScrollView(
              
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Error handling
                  if (state.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red.shade700),
                            onPressed: () {
                              context.read<StepCountCubit>().clearError();
                            },
                          ),
                        ],
                      ),
                    ),

                  // Steps Counter Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white
                        // gradient: LinearGradient(
                        //   colors: [Colors.green[400]!, Colors.green[600]!],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            state.goalReached
                                ? Icons.emoji_events
                                : Icons.directions_walk,
                            size: 60,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${state.totalSteps}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey ,
                            ),
                          ),
                          Text(
                            state.goalReached
                                ? 'Goal Reached! 🎉'
                                : 'Steps Today',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Statistics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Distance',
                          '${state.distanceKm.toStringAsFixed(2)} km',
                          Icons.straighten,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Calories',
                          '${state.caloriesBurned} cal',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Goal Progress
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Daily Goal Progress',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: _showGoalDialog,
                                child: Text('${state.dailyGoal}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: state.progressPercentage,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              state.goalReached
                                  ? Colors.green[600]!
                                  : Colors.blue[600]!,
                            ),
                            minHeight: 10,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${state.totalSteps}/${state.dailyGoal} steps',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${(state.progressPercentage * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (!state.goalReached)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${state.remainingSteps} steps remaining',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pedestrian Status and Last Updated
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getStatusIcon(state.pedestrianStatus),
                                size: 40,
                                color: _getStatusColor(state.pedestrianStatus),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status: ${_getStatusText(state.pedestrianStatus)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Updated: ${_formatTime(state.lastUpdated)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Permission Required',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'This app needs activity recognition permission to track your steps accurately.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await _initPedometer();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'walking':
        return Icons.directions_walk;
      case 'stopped':
        return Icons.accessibility_new;
      case 'unknown':
        return Icons.help_outline;
      default:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'walking':
        return Colors.green;
      case 'stopped':
        return Colors.orange;
      case 'unknown':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'walking':
        return 'Walking';
      case 'stopped':
        return 'Stopped';
      case 'unknown':
        return 'Unknown';
      default:
        return 'Unavailable';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
