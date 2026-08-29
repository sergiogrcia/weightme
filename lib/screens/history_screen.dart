import 'package:flutter/material.dart';

import '../services/weight_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/month_group.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.weightService, super.key});

  final WeightService weightService;

  @override
  Widget build(BuildContext context) {
    final history = weightService.historyByMonth;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.mobileMargin,
          vertical: AppSpacing.md,
        ),
        children: [
          const Text('Historial', style: AppTypography.headlineLarge),
          const SizedBox(height: AppSpacing.xxs),
          const Text('Revisa tus registros anteriores.', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          if (history.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.history_outlined, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No hay registros aún',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  const Text(
                    'Registra tu peso para ver tu historial aquí.',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            for (final month in history) ...[
              MonthGroup(data: month),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}