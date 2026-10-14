import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/report_service.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create services once and load saved data before showing the UI.
  final storage = await StorageService.create();
  final reportService = ReportService(storage);
  await reportService.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ReportService>.value(value: reportService),
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService(storage)),
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService(storage)),
      ],
      child: const DamageAssessmentApp(),
    ),
  );
}

class DamageAssessmentApp extends StatelessWidget {
  const DamageAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeService>().mode;
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
