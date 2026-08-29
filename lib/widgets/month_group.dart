import 'package:flutter/material.dart';

import '../models/weight_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'weight_entry_tile.dart';

class MonthGroup extends StatelessWidget {
  const MonthGroup({required this.data, super.key});

  final MonthEntries data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.xs),
          child: Text(
            data.month.toUpperCase(),
            style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: .3)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < data.entries.length; i++) ...[
                WeightEntryTile(entry: data.entries[i]),
                if (i != data.entries.length - 1)
                  const Divider(height: 1, color: AppColors.outlineVariant),
              ],
            ],
          ),
        ),
      ],
    );
  }
}