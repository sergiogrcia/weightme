import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class ActivityOption {
  const ActivityOption({
    required this.id,
    required this.title,
    required this.multiplier,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String multiplier;
  final String description;
  final IconData icon;
}

class OnboardingActivityLevelScreen extends StatefulWidget {
  const OnboardingActivityLevelScreen({
    this.initialActivityLevel = 'ligeramente_activo',
    this.onContinue,
    this.onBack,
    super.key,
  });

  final String initialActivityLevel;
  final ValueChanged<String>? onContinue;
  final VoidCallback? onBack;

  @override
  State<OnboardingActivityLevelScreen> createState() =>
      _OnboardingActivityLevelScreenState();
}

class _OnboardingActivityLevelScreenState
    extends State<OnboardingActivityLevelScreen> {
  late String _selectedLevel;

  static const List<ActivityOption> _options = [
    ActivityOption(
      id: 'sedentario',
      title: 'Sedentario',
      multiplier: 'Base ×1.2',
      description:
          'Trabajo de oficina, sentado casi todo el día, desplazamientos en vehículo.',
      icon: Icons.computer_rounded,
    ),
    ActivityOption(
      id: 'ligeramente_activo',
      title: 'Ligeramente activo',
      multiplier: 'Base ×1.375',
      description:
          'De pie a ratos, caminatas cortas, tareas domésticas ligeras (5.000 - 7.000 pasos/día).',
      icon: Icons.directions_walk_rounded,
    ),
    ActivityOption(
      id: 'activo',
      title: 'Activo',
      multiplier: 'Base ×1.55',
      description:
          'De pie la mayor parte del día, trabajo físico ligero (camarero, dependiente, >10.000 pasos).',
      icon: Icons.directions_run_rounded,
    ),
    ActivityOption(
      id: 'muy_activo',
      title: 'Muy activo',
      multiplier: 'Base ×1.725',
      description:
          'Trabajo de alta exigencia física (construcción, agricultura, entrenamiento intenso diario).',
      icon: Icons.local_fire_department_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialActivityLevel;
  }

  void _handleContinue() {
    if (widget.onContinue != null) {
      widget.onContinue!(_selectedLevel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(
            top: -50,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
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

                  // Header Bar (Back button + Logo)
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

                          // Activity Level Cards List
                          ..._options.map(
                            (option) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildActivityCard(option),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Button ("Continuar") & Microcopy
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

        // Progress Bar (100% filled - Paso 4 de 4)
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
              widthFactor: 0.80,
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
              'PASO 4 DE 4',
              style: AppTypography.labelCaps.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'NIVEL DE ACTIVIDAD',
              style: AppTypography.labelCaps.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCBD5E1),
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tu nivel de actividad',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'El gasto energético diario no relacionado con el ejercicio (NEAT) es clave para calcular tu gasto calórico real (TDEE).',
          style: AppTypography.bodySmall.copyWith(
            fontSize: 13,
            height: 19 / 13,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(ActivityOption option) {
    final isSelected = _selectedLevel == option.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceHigh : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                    : AppColors.surfaceHigh.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF8083FF).withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Icon(
                option.icon,
                size: 20,
                color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1).withValues(alpha: 0.25)
                              : AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF8083FF).withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          option.multiplier,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      height: 16 / 11.5,
                      color: isSelected
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Radio / Check Indicator
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF64748B),
                  width: isSelected ? 0 : 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.background,
                    )
                  : null,
            ),
          ],
        ),
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
            onPressed: _handleContinue,
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
                  'Continuar',
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
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 14,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Podrás modificar tu nivel de actividad en cualquier momento desde tu perfil.',
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
