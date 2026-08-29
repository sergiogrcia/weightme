import 'package:flutter/material.dart';

import '../models/weight_entry.dart';
import '../services/weight_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class WeightEntryTile extends StatelessWidget {
  const WeightEntryTile({
    required this.entry,
    this.weightService,
    super.key,
  });

  final WeightEntry entry;
  final WeightService? weightService;

  @override
  Widget build(BuildContext context) {
    final weightVal = weightService?.displayWeight(entry.weightKg) ?? entry.weightKg;
    final deltaVal = weightService?.displayWeight(entry.delta) ?? entry.delta;
    final unitStr = weightService?.profile.unit ?? 'kg';

    final isUp = entry.delta > 0;
    final isDown = entry.delta < 0;

    final deltaColor = isUp
        ? AppColors.tertiary
        : isDown
            ? AppColors.secondary
            : AppColors.textSecondary;

    final deltaIcon = isUp
        ? Icons.arrow_upward_rounded
        : isDown
            ? Icons.arrow_downward_rounded
            : Icons.remove_rounded;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHighest,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${entry.day}',
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weightVal.toStringAsFixed(1)} $unitStr',
                    style: AppTypography.titleMedium,
                  ),
                  Text(entry.time, style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Icon(deltaIcon, size: 20, color: deltaColor),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                deltaVal.abs().toStringAsFixed(1),
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 14,
                  color: deltaColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}