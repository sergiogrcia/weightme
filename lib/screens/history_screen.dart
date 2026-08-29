import 'package:flutter/material.dart';

import '../models/weight_entry.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/month_group.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // TODO: reemplazar por datos reales cuando exista el backend/service.
  static const _mockData = [
    MonthEntries(
      month: 'Octubre 2023',
      entries: [
        WeightEntry(day: 28, weightKg: 79.1, time: '08:30 AM', delta: -0.5),
        WeightEntry(day: 21, weightKg: 79.4, time: '09:15 AM', delta: 1.2),
        WeightEntry(day: 14, weightKg: 78.8, time: '07:45 AM', delta: -0.8),
      ],
    ),
    MonthEntries(
      month: 'Septiembre 2023',
      entries: [
        WeightEntry(day: 30, weightKg: 79.2, time: '08:00 AM', delta: 0),
        WeightEntry(day: 15, weightKg: 79.2, time: '09:30 AM', delta: -1.4),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mobileMargin, vertical: AppSpacing.md),
        children: [
          Text('Historial', style: AppTypography.headlineLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text('Revisá tus registros anteriores.', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          for (final month in _mockData) ...[
            MonthGroup(data: month),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}