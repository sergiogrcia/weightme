import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

class WeightMeApp extends StatelessWidget {
  const WeightMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeightMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}
