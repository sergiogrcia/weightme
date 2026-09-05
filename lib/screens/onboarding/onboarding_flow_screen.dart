import 'package:flutter/material.dart';

import '../../services/weight_service.dart';
import 'onboarding_activity_level_screen.dart';
import 'onboarding_body_data_screen.dart';
import 'onboarding_goal_screen.dart';
import 'onboarding_loading_screen.dart';
import 'onboarding_name_screen.dart';
import 'onboarding_summary_screen.dart';
import 'onboarding_welcome_screen.dart';

enum OnboardingStep {
  name,
  welcome,
  bodyData,
  activityLevel,
  goal,
  loading,
  summary,
}

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({
    required this.weightService,
    required this.onCompleted,
    super.key,
  });

  final WeightService weightService;
  final VoidCallback onCompleted;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  OnboardingStep _currentStep = OnboardingStep.name;

  // Flow State
  String _userName = '';
  OnboardingBodyData _bodyData = const OnboardingBodyData(
    sex: 'hombre',
    age: 28,
    heightCm: 178.0,
    weightKg: 74.5,
  );
  String _activityLevel = 'ligeramente_activo';
  OnboardingGoalData _goalData = const OnboardingGoalData(
    phase: 'definicion',
    stepIndex: 1,
    weeklyRateKg: -0.50,
    estimatedDailyCalories: -550,
  );

  void _goToStep(OnboardingStep step) {
    setState(() => _currentStep = step);
  }

  Future<void> _handleEnterApp() async {
    final targetWeight = (_bodyData.weightKg + (_goalData.weeklyRateKg * 8)).clamp(30.0, 300.0);

    final updatedProfile = widget.weightService.profile.copyWith(
      name: _userName.trim().isEmpty ? 'Usuario' : _userName.trim(),
      startingWeight: _bodyData.weightKg,
      targetWeight: double.parse(targetWeight.toStringAsFixed(1)),
      isOnboardingCompleted: true,
    );

    await widget.weightService.updateProfile(updatedProfile);

    // Save initial weight entry if none exists yet
    if (widget.weightService.entries.isEmpty) {
      await widget.weightService.addEntry(
        weightKg: _bodyData.weightKg,
        date: DateTime.now(),
        note: 'Peso inicial del onboarding',
      );
    }

    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case OnboardingStep.name:
        return OnboardingNameScreen(
          initialName: _userName,
          onContinue: (name) {
            _userName = name;
            _goToStep(OnboardingStep.welcome);
          },
        );

      case OnboardingStep.welcome:
        return OnboardingWelcomeScreen(
          userName: _userName,
          onContinue: () => _goToStep(OnboardingStep.bodyData),
          onBack: () => _goToStep(OnboardingStep.name),
        );

      case OnboardingStep.bodyData:
        return OnboardingBodyDataScreen(
          initialData: _bodyData,
          onContinue: (data) {
            _bodyData = data;
            _goToStep(OnboardingStep.activityLevel);
          },
          onBack: () => _goToStep(OnboardingStep.welcome),
        );

      case OnboardingStep.activityLevel:
        return OnboardingActivityLevelScreen(
          initialActivityLevel: _activityLevel,
          onContinue: (level) {
            _activityLevel = level;
            _goToStep(OnboardingStep.goal);
          },
          onBack: () => _goToStep(OnboardingStep.bodyData),
        );

      case OnboardingStep.goal:
        return OnboardingGoalScreen(
          initialPhase: _goalData.phase,
          initialStepIndex: _goalData.stepIndex,
          onFinish: (data) {
            _goalData = data;
            _goToStep(OnboardingStep.loading);
          },
          onBack: () => _goToStep(OnboardingStep.activityLevel),
        );

      case OnboardingStep.loading:
        return OnboardingLoadingScreen(
          onComplete: () => _goToStep(OnboardingStep.summary),
        );

      case OnboardingStep.summary:
        return OnboardingSummaryScreen(
          userName: _userName,
          bodyData: _bodyData,
          goalData: _goalData,
          activityLevel: _activityLevel,
          onEnterApp: _handleEnterApp,
          onBack: () => _goToStep(OnboardingStep.goal),
        );
    }
  }
}
