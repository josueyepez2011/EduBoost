import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/theme.dart';
import 'core/services/local_storage_service.dart';
import 'features/tasks/bloc/task_bloc.dart';
import 'features/grades/bloc/grade_bloc.dart';
import 'features/gamification/bloc/achievement_bloc.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await LocalStorageService.init();
  runApp(EduBoostApp(storageService: storageService));
}

class EduBoostApp extends StatelessWidget {
  final LocalStorageService storageService;

  const EduBoostApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TaskBloc(storageService)..add(LoadTasks()),
        ),
        BlocProvider(
          create: (context) => GradeBloc(storageService)..add(LoadGrades()),
        ),
        BlocProvider(
          create: (context) =>
              AchievementBloc(storageService)..add(LoadAchievements()),
        ),
      ],
      child: MaterialApp(
        title: 'EduBoost',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', ''), Locale('en', '')],
        home: const HomeScreen(),
      ),
    );
  }
}
