import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({
    this.userName = '',
    this.onContinue,
    this.onBack,
    super.key,
  });

  final String userName;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  String _getInitial() {
    final trimmed = userName.trim();
    if (trimmed.isEmpty || trimmed == 'Anónimo') {
      return 'A';
    }
    return trimmed[0].toUpperCase();
  }

  String _getDisplayName() {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) return 'amigo';
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _getDisplayName();
    final initial = _getInitial();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(
            top: 40,
            left: MediaQuery.of(context).size.width * 0.5 - 160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            left: -80,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Screen Layout
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
                          const SizedBox(height: AppSpacing.sm),

                          // Avatar Greeting Badge with checkmark
                          _buildAvatarBadge(initial),

                          const SizedBox(height: AppSpacing.md),

                          // Headline with User Name
                          RichText(
                            text: TextSpan(
                              style: AppTypography.headlineLarge.copyWith(
                                fontSize: 28,
                                height: 36 / 28,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                              children: [
                                const TextSpan(
                                  text: '¡Encantado de conocerte, ',
                                ),
                                TextSpan(
                                  text: displayName,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const TextSpan(text: '!'),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Voy a necesitar algunos datos para personalizarte el plan y adaptar cada métrica a tus objetivos personales.',
                            style: AppTypography.bodyLarge.copyWith(
                              fontSize: 15,
                              height: 22 / 15,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Upcoming Steps Cards
                          _buildPreviewCard(
                            icon: Icons.scale_rounded,
                            iconColor: AppColors.primary,
                            title: 'Peso actual y objetivo',
                            subtitle: 'Para definir tu meta saludable',
                            tagText: '',
                            tagColor: AppColors.primary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 12),
                          _buildPreviewCard(
                            icon: Icons.straighten_rounded,
                            iconColor: AppColors.secondary,
                            title: 'Estatura y edad',
                            subtitle: 'Para calcular tu IMC con precisión',
                            tagText: '',
                            tagColor: const Color(0xFF94A3B8),
                          ),

                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Button
                  _buildFooterAction(),

                  const SizedBox(height: AppSpacing.sm),
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
            const SizedBox(width: 36), // Balance spacer for symmetry
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Step Labels (moved above the progress bar to match OnboardingNameScreen)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PASO 2 DE 4',
              style: AppTypography.labelCaps.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'PERSONALIZACIÓN',
              style: AppTypography.labelCaps.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Step Progress Bar (50% filled - Paso 2 de 4)
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
              widthFactor: 0.40,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), AppColors.primary],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarBadge(String initial) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surface, AppColors.surfaceHigh],
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTypography.displayLarge.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.background,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String tagText,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHigh),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            tagText,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tagColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterAction() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 0,
          shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.25),
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
    );
  }
}
