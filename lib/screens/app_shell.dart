import 'package:flutter/material.dart';

import '../widgets/app_bottom_navigation.dart';
import 'add_weight_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _selectDestination(int index) {
    if (index >= 0 && index <= 3) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        final Widget body = switch (_currentIndex) {
          1 => const HistoryScreen(),
          2 => AddWeightScreen(onCancel: () => _selectDestination(0)),
          3 => const ProfileScreen(),
          _ => HomeScreen(onAddWeight: () => _selectDestination(2)),
        };
        return Scaffold(
          body: body,
          bottomNavigationBar: isMobile
              ? AppBottomNavigation(
                  currentIndex: _currentIndex,
                  onDestinationSelected: _selectDestination,
                )
              : null,
        );
      },
    );
  }
}