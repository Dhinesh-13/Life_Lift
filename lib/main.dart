import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/domain/repo/food_repo.dart';
import 'package:lift_life/helper/nav_helper/nav_helper.dart';
import 'package:lift_life/presentation/dashboard/cubit/food_log_cubit.dart';
import 'package:lift_life/service/food_services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

Future<void> _loadEnvironmentFile() async {
  try {
    await dotenv.load(fileName: '.env');
    print('Environment file loaded successfully');
  } catch (e) {
    print('Error loading .env file: $e');
    // Provide a fallback or handle error as needed
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await _loadEnvironmentFile();


  final apiKey = dotenv.env['GOOGLE_AI_API_KEY'];
  if (apiKey != null && apiKey.isNotEmpty) {
    Gemini.init(apiKey: apiKey);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FoodLogCubit(
          FoodRepositoryImpl(FoodService()),
        ),
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
