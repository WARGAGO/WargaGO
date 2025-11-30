import 'package:flutter/material.dart';
import 'package:wargago/core/theme/app_theme.dart';
import 'package:wargago/app/router.dart';

class JawaraApp extends StatelessWidget {
  const JawaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jawara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouterConfig.router,
    );
  }
}
