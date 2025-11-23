import 'package:flutter/material.dart';
import 'package:jawara/core/theme/app_theme.dart';
import 'package:jawara/core/constants/app_routes.dart';
import 'package:jawara/app/routes.dart';

class JawaraApp extends StatelessWidget {
  const JawaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jawara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
