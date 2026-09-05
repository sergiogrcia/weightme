import 'package:flutter/material.dart';

import '../services/weight_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_navigation.dart';
import 'add_weight_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'onboarding/onboarding_flow_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final _weightService = WeightService();

  @override
  void dispose() {
    _weightService.dispose();
    super.dispose();
  }

  void _selectDestination(int index) {
    if (index >= 0 && index <= 3) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _weightService,
      builder: (context, child) {
        if (!_weightService.isInitialized) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (!_weightService.profile.isOnboardingCompleted) {
          return OnboardingFlowScreen(
            weightService: _weightService,
            onCompleted: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                weightService: _weightService,
                onAddWeight: () => _selectDestination(2),
              ),
              HistoryScreen(weightService: _weightService),
              AddWeightScreen(
                weightService: _weightService,
                onCancel: () => _selectDestination(0),
              ),
              ProfileScreen(weightService: _weightService),
            ],
          ),
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: _currentIndex,
            onDestinationSelected: _selectDestination,
          ),
        );
      },
    );
  }
}