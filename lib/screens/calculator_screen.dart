import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../services/weight_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({required this.weightService, super.key});

  final WeightService weightService;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late String _gender; // 'male' | 'female'
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  late TextEditingController _bodyFatController;

  late double _activityFactor; // 1.2, 1.375, 1.55, 1.725
  late String _goal; // 'cut', 'maintain', 'bulk'
  late String _paceOption; // 'conservative', 'optimal', 'aggressive'

  late int _calculatedBmr;
  late int _calculatedTdee;
  late int _calculatedTargetCalories;
  late String _calculatedDeficitBadgeLabel;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _gender = 'male';

    final initialWeight = widget.weightService.currentDisplayWeight > 0
        ? widget.weightService.currentDisplayWeight
        : 75.4;

    _weightController = TextEditingController(
      text: initialWeight.toStringAsFixed(1),
    );
    _heightController = TextEditingController(text: '178');
    _ageController = TextEditingController(text: '29');
    _bodyFatController = TextEditingController(text: '');

    _activityFactor = 1.375;
    _goal = 'cut';
    _paceOption = 'optimal';

    _calculateResults();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  void _calculateResults() {
    final weight = double.tryParse(_weightController.text) ?? 75.4;
    final height = double.tryParse(_heightController.text) ?? 178;
    final age = double.tryParse(_ageController.text) ?? 29;
    final fat = double.tryParse(_bodyFatController.text);

    int bmr;
    if (fat != null && fat > 4) {
      final leanMass = weight * (1 - (fat / 100));
      bmr = (370 + (21.6 * leanMass)).round();
    } else {
      if (_gender == 'male') {
        bmr = ((10 * weight) + (6.25 * height) - (5 * age) + 5).round();
      } else {
        bmr = ((10 * weight) + (6.25 * height) - (5 * age) - 161).round();
      }
    }

    final tdee = (bmr * _activityFactor).round();

    double deltaKcal = 0;
    if (_goal == 'cut') {
      switch (_paceOption) {
        case 'conservative':
          deltaKcal = 300;
          break;
        case 'aggressive':
          deltaKcal = 750;
          break;
        case 'optimal':
        default:
          deltaKcal = 500;
          break;
      }
    } else if (_goal == 'bulk') {
      switch (_paceOption) {
        case 'conservative':
          deltaKcal = 200;
          break;
        case 'aggressive':
          deltaKcal = 500;
          break;
        case 'optimal':
        default:
          deltaKcal = 350;
          break;
      }
    }

    int targetCalories;
    if (_goal == 'cut') {
      targetCalories = math.max(1200, tdee - deltaKcal.round());
    } else if (_goal == 'bulk') {
      targetCalories = tdee + deltaKcal.round();
    } else {
      targetCalories = tdee;
    }

    String badgeLabel;
    final paceName = _paceOption == 'conservative'
        ? 'Conservador'
        : _paceOption == 'aggressive'
        ? 'Agresivo'
        : 'Óptimo';

    if (_goal == 'cut') {
      badgeLabel = 'Déficit $paceName (-${deltaKcal.round()} kcal)';
    } else if (_goal == 'bulk') {
      badgeLabel = 'Superávit $paceName (+${deltaKcal.round()} kcal)';
    } else {
      badgeLabel = 'Normocalórica (Mantenimiento)';
    }

    _calculatedBmr = bmr;
    _calculatedTdee = tdee;
    _calculatedTargetCalories = targetCalories;
    _calculatedDeficitBadgeLabel = badgeLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Header
            _buildTopHeader(),

            // Main Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.mobileMargin,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sub-Header Title & Description
                    _buildSubHeader(),

                    const SizedBox(height: AppSpacing.md),

                    // Hero Summary Widget
                    _buildHeroSummaryCard(),

                    const SizedBox(height: AppSpacing.md),

                    // Body Parameters Card
                    _buildBodyParametersCard(),

                    const SizedBox(height: AppSpacing.md),

                    // Daily Activity Level Card
                    _buildActivityLevelCard(),

                    const SizedBox(height: AppSpacing.md),

                    // Goal & Rate Card
                    _buildGoalAndRateCard(),

                    const SizedBox(height: AppSpacing.md),

                    // Calculate Action Button
                    _buildCalculateActionButton(),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mobileMargin),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.show_chart_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            'WeightMe',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calculadora Nutricional',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Calcula tus calorías diarias, TDEE y gasto energético ajustando tus datos.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badge Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _calculatedDeficitBadgeLabel,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Main Target Calories Hero Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_calculatedTargetCalories',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -1.0,
                  shadows: [
                    Shadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'kcal',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'recomendadas / día',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Metric Pills Grid (TDEE & BMR)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'TDEE Estimado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$_calculatedTdee',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.nightlight_round,
                            size: 16,
                            color: AppColors.primaryContainer,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'BMR Basal',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$_calculatedBmr',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyParametersCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Parámetros Corporales',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Sex Segmented Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = 'male'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _gender == 'male'
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male_rounded,
                            size: 18,
                            color: _gender == 'male'
                                ? AppColors.background
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hombre',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _gender == 'male'
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = 'female'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _gender == 'female'
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female_rounded,
                            size: 18,
                            color: _gender == 'female'
                                ? AppColors.background
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mujer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _gender == 'female'
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Numeric Inputs Grid (Peso, Altura, Edad)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Peso',
                  controller: _weightController,
                  unit: 'kg',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Altura',
                  controller: _heightController,
                  unit: 'cm',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Edad',
                  controller: _ageController,
                  unit: 'a',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Body Fat Tile (Optional)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.monitor_weight_outlined,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '% Grasa',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'OPCIONAL',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: TextField(
                        controller: _bodyFatController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                        decoration: const InputDecoration(
                          hintText: '--',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required TextEditingController controller,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.directions_run_rounded,
                size: 20,
                color: AppColors.secondary,
              ),
              SizedBox(width: 8),
              Text(
                'Actividad Diaria',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Factor multiplicador de gasto energético total diario.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 2x2 Activity Chips Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildActivityChip(
                      label: 'Sedentario',
                      factorText: 'x1.20',
                      desc: 'Trabajo sentado, escaso ejercicio',
                      factorValue: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActivityChip(
                      label: 'Ligero',
                      factorText: 'x1.375',
                      desc: '1-3 sesiones gimnasio / sem',
                      factorValue: 1.375,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildActivityChip(
                      label: 'Activo',
                      factorText: 'x1.55',
                      desc: '3-5 entrenamientos intensos',
                      factorValue: 1.55,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActivityChip(
                      label: 'Muy Activo',
                      factorText: 'x1.725',
                      desc: 'Trabajo físico o doble turno',
                      factorValue: 1.725,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChip({
    required String label,
    required String factorText,
    required String desc,
    required double factorValue,
  }) {
    final isSelected = _activityFactor == factorValue;
    return GestureDetector(
      onTap: () => setState(() => _activityFactor = factorValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceHigh : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : Colors.white,
                  ),
                ),
                Text(
                  factorText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalAndRateCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_rounded, size: 20, color: AppColors.tertiary),
              SizedBox(width: 8),
              Text(
                'Objetivo y Ritmo',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Phase Selector Segmented Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildGoalButton('cut', 'Definición'),
                _buildGoalButton('maintain', 'Mantenimiento'),
                _buildGoalButton('bulk', 'Volumen'),
              ],
            ),
          ),

          if (_goal != 'maintain') ...[
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Ritmo deseado',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPaceChip(
                  keyName: 'conservative',
                  title: 'Conservador',
                  subtitle: _goal == 'cut' ? '-0.27 kg/s' : '+0.18 kg/s',
                ),
                const SizedBox(width: 8),
                _buildPaceChip(
                  keyName: 'optimal',
                  title: 'Óptimo',
                  subtitle: _goal == 'cut' ? '-0.45 kg/s' : '+0.32 kg/s',
                ),
                const SizedBox(width: 8),
                _buildPaceChip(
                  keyName: 'aggressive',
                  title: 'Agresivo',
                  subtitle: _goal == 'cut' ? '-0.68 kg/s' : '+0.45 kg/s',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaceChip({
    required String keyName,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _paceOption == keyName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paceOption = keyName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.surfaceHighest,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.background : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.background.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalButton(String goalKey, String label) {
    final isSelected = _goal == goalKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _goal = goalKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? AppColors.background
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculateActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _calculateResults();
          });
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 0,
          shadowColor: AppColors.primaryContainer.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calculate_rounded,
              size: 22,
              color: AppColors.background,
            ),
            SizedBox(width: 8),
            Text(
              'Calcular',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
