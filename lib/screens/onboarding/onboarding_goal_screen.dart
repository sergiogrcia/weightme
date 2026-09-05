import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class OnboardingGoalData {
  const OnboardingGoalData({
    required this.phase,
    required this.stepIndex,
    required this.weeklyRateKg,
    required this.estimatedDailyCalories,
  });

  final String phase; // 'definicion', 'volumen', 'mantenimiento'
  final int stepIndex; // 0, 1, 2
  final double weeklyRateKg;
  final int estimatedDailyCalories;
}

class OnboardingGoalScreen extends StatefulWidget {
  const OnboardingGoalScreen({
    this.initialPhase = 'definicion',
    this.initialStepIndex = 1,
    this.onFinish,
    this.onBack,
    super.key,
  });

  final String initialPhase;
  final int initialStepIndex;
  final ValueChanged<OnboardingGoalData>? onFinish;
  final VoidCallback? onBack;

  @override
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen> {
  late String _currentPhase;
  late int _currentStep; // 0, 1, 2

  @override
  void initState() {
    super.initState();
    _currentPhase = widget.initialPhase;
    _currentStep = widget.initialStepIndex;
  }

  // Configuration for definicion & volumen
  static const Map<String, List<Map<String, dynamic>>> _configs = {
    'definicion': [
      {
        'name': 'Conservador',
        'valueStr': '-0.25',
        'valueNum': -0.25,
        'unit': 'kg/sem',
        'calStr': '~ -275 kcal/día',
        'calNum': -275,
        'desc':
            'Déficit leve. Ideal si buscas máxima energía, fuerza y cero ansiedad por hambre.',
        'badge': 'Sostenible',
        'projection': '-2.0 kg en 8 semanas',
        'isAggressive': false,
      },
      {
        'name': 'Moderado',
        'valueStr': '-0.50',
        'valueNum': -0.50,
        'unit': 'kg/sem',
        'calStr': '~ -550 kcal/día',
        'calNum': -550,
        'desc':
            'Ritmo estándar recomendado. Equilibrio óptimo entre velocidad y conservación de masa magra.',
        'badge': 'Recomendado',
        'projection': '-4.0 kg en 8 semanas',
        'isAggressive': false,
      },
      {
        'name': 'Agresivo',
        'valueStr': '-0.85',
        'valueNum': -0.85,
        'unit': 'kg/sem',
        'calStr': '~ -900 kcal/día',
        'calNum': -900,
        'desc':
            'Pérdida rápida. Mayor probabilidad de pérdida de masa muscular y fatiga.',
        'badge': 'Avanzado',
        'projection': '-6.8 kg en 8 semanas',
        'isAggressive': true,
        'warningTitle': 'Advertencia para principiantes',
        'warningText':
            'Un déficit tan agresivo puede provocar pérdida de masa muscular, mayor fatiga metabólica y riesgo elevado de efecto rebote.',
        'warningTag': 'Alto Impacto',
      },
    ],
    'volumen': [
      {
        'name': 'Limpio / Controlado',
        'valueStr': '+0.20',
        'valueNum': 0.20,
        'unit': 'kg/sem',
        'calStr': '~ +220 kcal/día',
        'calNum': 220,
        'desc':
            'Superávit mínimo para construir músculo minimizando la acumulación de tejido graso.',
        'badge': 'Recomendado',
        'projection': '+1.6 kg en 8 semanas',
        'isAggressive': false,
      },
      {
        'name': 'Estándar',
        'valueStr': '+0.35',
        'valueNum': 0.35,
        'unit': 'kg/sem',
        'calStr': '~ +385 kcal/día',
        'calNum': 385,
        'desc':
            'Ganancia de peso constante para entrenamientos de hipertrofia exigentes.',
        'badge': 'Fuerza',
        'projection': '+2.8 kg en 8 semanas',
        'isAggressive': false,
      },
      {
        'name': 'Agresivo',
        'valueStr': '+0.50',
        'valueNum': 0.50,
        'unit': 'kg/sem',
        'calStr': '~ +550 kcal/día',
        'calNum': 550,
        'desc':
            'Superávit alto. Rápido incremento de fuerza pero con mayor retención grasa.',
        'badge': 'Atletas',
        'projection': '+4.0 kg en 8 semanas',
        'isAggressive': true,
        'warningTitle': 'Precaución de ganancia grasa',
        'warningText':
            'Para principiantes, un superávit tan elevado resultará en un porcentaje significativo de ganancia de grasa corporal innecesaria.',
        'warningTag': 'Riesgo Graso',
      },
    ],
  };

  void _handleFinish() {
    if (widget.onFinish == null) return;

    if (_currentPhase == 'mantenimiento') {
      widget.onFinish!(
        const OnboardingGoalData(
          phase: 'mantenimiento',
          stepIndex: 0,
          weeklyRateKg: 0.0,
          estimatedDailyCalories: 0,
        ),
      );
    } else {
      final stepData = _configs[_currentPhase]![_currentStep];
      widget.onFinish!(
        OnboardingGoalData(
          phase: _currentPhase,
          stepIndex: _currentStep,
          weeklyRateKg: stepData['valueNum'] as double,
          estimatedDailyCalories: stepData['calNum'] as int,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Glow Top
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width * 0.5 - 140,
            child: Container(
              width: 280,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.mobileMargin,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xs),

                  // Header Bar (Back button + Logo + Stepper 100%)
                  _buildHeader(context),

                  const SizedBox(height: AppSpacing.md),

                  // Main Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Intro Section
                          _buildIntroSection(),

                          const SizedBox(height: AppSpacing.md),

                          // Phase Segmented Control (Definición, Volumen, Mantenimiento)
                          _buildPhaseSegmentedControl(),

                          const SizedBox(height: AppSpacing.md),

                          // Main Dynamic Slider / State Card
                          _buildMainCard(),

                          const SizedBox(height: AppSpacing.sm),

                          // UX Alert Warning Box
                          _buildWarningBox(),

                          const SizedBox(height: AppSpacing.sm),

                          // Adaptive weekly summary pill
                          _buildAdaptiveFormulaPill(),

                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Button & Microcopy
                  _buildFooter(),

                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: widget.onBack,
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
            const SizedBox(width: 36),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Step Progress Bar (100% filled - Paso 5 de 5)
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), AppColors.primary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.55),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PASO 5 DE 5',
              style: AppTypography.labelCaps.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'RITMO Y OBJETIVO',
              style: AppTypography.labelCaps.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            ),
          ),
          child: const Icon(
            Icons.speed_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tu ritmo de progreso',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Personaliza la velocidad del cambio según tu objetivo. Adaptaremos el déficit o superávit calórico exacto para ti.',
          style: AppTypography.bodySmall.copyWith(
            fontSize: 13,
            height: 18 / 13,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPhaseButton(
              id: 'definicion',
              label: 'Definición',
              icon: Icons.trending_down_rounded,
            ),
          ),
          Expanded(
            child: _buildPhaseButton(
              id: 'volumen',
              label: 'Volumen',
              icon: Icons.trending_up_rounded,
            ),
          ),
          Expanded(
            child: _buildPhaseButton(
              id: 'mantenimiento',
              label: 'Mantenimiento',
              icon: Icons.restart_alt_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseButton({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _currentPhase == id;

    return GestureDetector(
      onTap: () => setState(() => _currentPhase = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    if (_currentPhase == 'mantenimiento') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'EQUILIBRIO',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Recomposición',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Mantén tu peso y optimiza tu composición corporal.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Maintenance State Graphic
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.balance_rounded,
                size: 28,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Fluctuación Neutra: 0.0 kg/semana',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enfoque 100% en recomposición corporal: perder grasa mientras ganas fuerza y tono muscular consumiendo tus calorías de mantenimiento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 17 / 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    // Definición or Volumen
    final stepData = _configs[_currentPhase]![_currentStep];
    final name = stepData['name'] as String;
    final valueStr = stepData['valueStr'] as String;
    final unit = stepData['unit'] as String;
    final calStr = stepData['calStr'] as String;
    final desc = stepData['desc'] as String;
    final badge = stepData['badge'] as String;
    final projection = stepData['projection'] as String;
    final isAggressive = stepData['isAggressive'] as bool;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isAggressive
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isAggressive
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        badge.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isAggressive
                              ? const Color(0xFFF59E0B)
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        valueStr,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    calStr,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Custom Slider Widget
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceHigh,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _currentStep.toDouble(),
              min: 0,
              max: 2,
              divisions: 2,
              onChanged: (val) => setState(() => _currentStep = val.round()),
            ),
          ),

          // Slider Step Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentPhase == 'definicion' ? 'Conservador' : 'Limpio',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: _currentStep == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _currentStep == 0
                      ? AppColors.primary
                      : const Color(0xFF64748B),
                ),
              ),
              Text(
                _currentPhase == 'definicion' ? 'Moderado' : 'Estándar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: _currentStep == 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _currentStep == 1
                      ? AppColors.primary
                      : const Color(0xFF64748B),
                ),
              ),
              Text(
                'Agresivo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: _currentStep == 2
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _currentStep == 2
                      ? AppColors.primary
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2A344D)),
          const SizedBox(height: 8),

          // Projection Box
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Proyección a 8 semanas:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              Text(
                projection,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    bool isWarning = false;
    String title = 'Ritmo óptimo para adherencia';
    String text =
        'Permite crear hábitos consistentes sin generar fatiga excesiva ni efecto rebote.';
    String tag = 'Recomendado';

    if (_currentPhase == 'mantenimiento') {
      title = 'Ideal para construir fuerza y perder grasa';
      text =
          'Especialmente efectivo para personas que retoman o inician el gimnasio sin someterse a dietas restrictivas.';
      tag = 'Sostenible';
    } else {
      final stepData = _configs[_currentPhase]![_currentStep];
      if (stepData['isAggressive'] == true) {
        isWarning = true;
        title = stepData['warningTitle'] as String;
        text = stepData['warningText'] as String;
        tag = stepData['warningTag'] as String;
      } else if (_currentPhase == 'volumen') {
        title = 'Crecimiento magro eficiente';
        text =
            'Fomenta la síntesis proteica minimizando el almacenamiento en tejido adiposo.';
        tag = 'Recomendado';
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isWarning
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isWarning ? Icons.warning_rounded : Icons.verified_rounded,
              size: 18,
              color: isWarning ? const Color(0xFFF59E0B) : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isWarning
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                            : AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isWarning
                              ? const Color(0xFFF59E0B)
                              : AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 15 / 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveFormulaPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Ajuste adaptativo semanal según pesajes',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          Text(
            'Activo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _handleFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              elevation: 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Calcular mi Plan Personalizado',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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
        Text(
          'Podrás recalibrar este ritmo o cambiar de fase en cualquier momento desde tu perfil.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 10,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
