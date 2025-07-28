class Routes {
  static const String initialLocation = '/';
  static const String weightScreen = '/weightScreen';
  static const String heightScreen = '/heightScreen';
  static const String ageScreen = '/ageScreen';
  static const String genderScreen = '/genderScreen';
  static const String fitnessGoalScreen = '/fitnessGoalScreen';
  static const String dashboardScreen = '/dashboardScreen';
  static const String walkingScreen = '/walkingScreen';
  static const String cyclingScreen = '/cyclingScreen';
  static const String gymScreen = '/gymScreen';
  static const String activeWorkoutScreen = '/activeWorkoutScreen'; 
  static const String exerciseSelectionScreen = '/exerciseSelectionScreen';
  static const String workoutDetailScreen = '/workoutDetailScreen';
  static const String workoutHistoryScreen = '/workoutHistoryScreen'; 
    static getRouterPath(String routeName) => '/$routeName';
}