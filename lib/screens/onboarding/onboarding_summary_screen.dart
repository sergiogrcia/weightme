import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'onboarding_body_data_screen.dart';
import 'onboarding_goal_screen.dart';

class OnboardingSummaryScreen extends StatelessWidget {
  const OnboardingSummaryScreen({
    required this.userName,
    required this.bodyData,
    required this.goalData,
    required this.activityLevel,
    this.onEnterApp,
    this.onBack,
    super.key,
  });

  final String userName;
  final OnboardingBodyData bodyData;
  final OnboardingGoalData goalData;
  final String activityLevel;
  final VoidCallback? onEnterApp;
  final VoidCallback? onBack;

  double _calculateBmr() {
    final w = bodyData.weightKg;
    final h = bodyData.heightCm;
    final a = bodyData.age;
    if (bodyData.sex == 'mujer') {
      return 10 * w + 6.25 * h - 5 * a - 161;
    }
    return 10 * w + 6.25 * h - 5 * a + 5;
  }

  double _getActivityMultiplier() {
    switch (activityLevel) {
      case 'sedentario':
        return 1.2;
      case 'ligeramente_activo':
        return 1.375;
      case 'activo':
        return 1.55;
      case 'muy_activo':
        return 1.725;
      default:
        return 1.375;
    }
  }

  String _getActivityTitle() {
    switch (activityLevel) {
      case 'sedentario':
        return 'Sedentario';
      case 'ligeramente_activo':
        return 'Ligeramente activo';
      case 'activo':
        return 'Activo';
      case 'muy_activo':
        return 'Muy activo';
      default:
        return 'Ligeramente activo';
    }
  }

  String _getActivityDesc() {
    switch (activityLevel) {
      case 'sedentario':
        return 'Trabajo de oficina, sentado casi todo el día';
      case 'ligeramente_activo':
        return '5.000 - 7.000 pasos diarios estimados';
      case 'activo':
        return '>10.000 pasos diarios o trabajo de pie';
      case 'muy_activo':
        return 'Trabajo físico exigente o entreno intenso';
      default:
        return '5.000 - 7.000 pasos diarios estimados';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bmr = _calculateBmr();
    final mult = _getActivityMultiplier();
    final tdee = bmr * mult;
    final targetCalories = (tdee + goalData.estimatedDailyCalories).clamp(
      1200.0,
      5000.0,
    );

    final proteinGrams = ((targetCalories * 0.32) / 4).round();
    final carbsGrams = ((targetCalories * 0.40) / 4).round();
    final fatGrams = ((targetCalories * 0.28) / 9).round();

    final projected8WeeksWeight =
        (bodyData.weightKg + (goalData.weeklyRateKg * 8)).clamp(30.0, 300.0);
    final netDelta8Weeks = goalData.weeklyRateKg * 8;

    final displayName = userName.trim().isEmpty ? 'amigo' : userName.trim();

    return Scaffold(
      backgroundColor: const Color(0xFF080E1E),
      body: Stack(
        children: [
          // Header Ambient Radial Glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 1.0,
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(context),

                // Main Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.mobileMargin,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xs),

                        // Greeting Pill & Title
                        _buildGreetingHeader(displayName),

                        const SizedBox(height: AppSpacing.md),

                        // Hero Caloric Card
                        _buildHeroCaloricCard(
                          targetCalories: targetCalories.round(),
                          bmr: bmr.round(),
                          tdee: tdee.round(),
                          proteinGrams: proteinGrams,
                          carbsGrams: carbsGrams,
                          fatGrams: fatGrams,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Metrics Grid
                        _buildCalibratedMetricsGrid(
                          projectedWeight: projected8WeeksWeight,
                          netDelta8Weeks: netDelta8Weeks,
                          multStr:
                              'Base ×${mult.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '')}',
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Informative Disclaimer Box
                        _buildDisclaimerBox(),

                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),

                // Floating Action Button ("Entrar a la app")
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mobileMargin,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceHigh),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'WEIGHTME',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Plan Listo',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF34D399),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '¡VAMOS A POR ELLO, ${name.toUpperCase()}!',
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Color(0xFFA5B4FC),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu plan personalizado está listo',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Diseñado con base en tu metabolismo basal, nivel de actividad seleccionado y el ritmo óptimo para preservar tu masa muscular.',
          style: AppTypography.bodySmall.copyWith(
            fontSize: 12.5,
            height: 17 / 12.5,
            color: const Color(0xFF8291B0),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCaloricCard({
    required int targetCalories,
    required int bmr,
    required int tdee,
    required int proteinGrams,
    required int carbsGrams,
    required int fatGrams,
  }) {
    String tagLabel;
    if (goalData.phase == 'definicion') {
      tagLabel = 'Déficit (${goalData.estimatedDailyCalories} kcal)';
    } else if (goalData.phase == 'volumen') {
      tagLabel = 'Superávit (+${goalData.estimatedDailyCalories} kcal)';
    } else {
      tagLabel = 'Mantenimiento Neutro';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E172C).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OBJETIVO DIARIO',
                style: AppTypography.labelCaps.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  tagLabel,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA5B4FC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Big Metric Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatCalories(targetCalories),
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'kcal / día',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8291B0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comparison Info Grid (TDEE & BMR)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080E1E).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gasto Total (TDEE)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(text: _formatCalories(tdee)),
                            const TextSpan(
                              text: ' kcal',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF080E1E).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metabolismo Basal (BMR)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(text: _formatCalories(bmr)),
                            const TextSpan(
                              text: ' kcal',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Macronutrient Breakdown
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distribución de Macronutrientes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFCBD5E1),
                ),
              ),
              Text(
                '100% calibrado',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA5B4FC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Multi-segmented Progress Bar
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF080E1E),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 32,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(999),
                        bottomLeft: Radius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 40,
                  child: Container(color: const Color(0xFF38BDF8)),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 28,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBBF24),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(999),
                        bottomRight: Radius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Macros Legend
          Row(
            children: [
              Expanded(
                child: _buildMacroLegendItem(
                  color: const Color(0xFF6366F1),
                  label: 'Proteína',
                  grams: '${proteinGrams}g',
                  percent: '(32%)',
                ),
              ),
              Expanded(
                child: _buildMacroLegendItem(
                  color: const Color(0xFF38BDF8),
                  label: 'Carbos',
                  grams: '${carbsGrams}g',
                  percent: '(40%)',
                ),
              ),
              Expanded(
                child: _buildMacroLegendItem(
                  color: const Color(0xFFFBBF24),
                  label: 'Grasas',
                  grams: '${fatGrams}g',
                  percent: '(28%)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCalories(int val) {
    if (val >= 1000) {
      final whole = val ~/ 1000;
      final remainder = (val % 1000).toString().padLeft(3, '0');
      return '$whole.$remainder';
    }
    return '$val';
  }

  Widget _buildMacroLegendItem({
    required Color color,
    required String label,
    required String grams,
    required String percent,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: grams),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: percent,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalibratedMetricsGrid({
    required double projectedWeight,
    required double netDelta8Weeks,
    required String multStr,
  }) {
    final netSign = netDelta8Weeks > 0 ? '+' : '';
    final rateStr = goalData.weeklyRateKg == 0.0
        ? '0.00 kg'
        : '${goalData.weeklyRateKg > 0 ? '+' : ''}${goalData.weeklyRateKg.toStringAsFixed(2)} kg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MÉTRICAS DE CALIBRACIÓN',
          style: AppTypography.labelCaps.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8291B0),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Metric: Weekly Pace
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E172C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ritmo proyectado',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.show_chart_rounded,
                            size: 14,
                            color: Color(0xFF818CF8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rateStr,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'por semana',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Metric: 8 Weeks Forecast
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E172C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Meta a 8 semanas',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: Color(0xFF34D399),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${projectedWeight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$netSign${netDelta8Weeks.toStringAsFixed(1)} kg estimados',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Activity Level Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0E172C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFFA5B4FC),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getActivityTitle(),
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            multStr,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getActivityDesc(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Adaptive Algorithm Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0E172C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF34D399),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Ajuste adaptativo activado',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF34D399),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'El algoritmo analizará tu progreso real cada domingo para afinar calorías sin que sufras estancamientos.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 15 / 11,
                        color: Color(0xFF8291B0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF080E1E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFF818CF8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  height: 15 / 11,
                  color: Color(0xFF94A3B8),
                ),
                children: [
                  TextSpan(
                    text:
                        'WeightMe recalibrará este déficit semanalmente analizando tu ',
                  ),
                  TextSpan(
                    text: 'peso medio ponderado',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text:
                        ', filtrando la retención de agua natural y fluctuaciones diarias de sodio.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.mobileMargin),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onEnterApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                elevation: 0,
                shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Entrar a la app',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: AppColors.background,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Podrás reajustar tus objetivos en cualquier momento desde tu Perfil.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
