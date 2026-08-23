import 'package:flutter/material.dart';

import '../widgets/app_bottom_navigation.dart';
import 'home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _selectDestination(int index) {
    if (index == 0) {
      setState(() => _currentIndex = index);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Esta pantalla estará disponible próximamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomeScreen(),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onDestinationSelected: _selectDestination,
      ),
    );
  }
}
