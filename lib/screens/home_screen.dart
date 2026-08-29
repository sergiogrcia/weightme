import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/weight_evolution_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.onAddWeight, super.key});

  final VoidCallback onAddWeight;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedPeriod = '1M';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const _TopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.mobileMargin,
                AppSpacing.md,
                AppSpacing.mobileMargin,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen',
                    style: AppTypography.headlineLarge.copyWith(fontSize: 28, height: 36 / 28),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Tu progreso de un vistazo.',
                    style: AppTypography.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ChartCard(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (period) {
                      setState(() => _selectedPeriod = period);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _CurrentWeightCard(),
                  const SizedBox(height: AppSpacing.md),
                  const _TotalLostCard(),
                  const SizedBox(height: AppSpacing.md),
                  const _GoalCard(),
                  const SizedBox(height: AppSpacing.md),
                  _LogWeightButton(onPressed: widget.onAddWeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mobileMargin),
      color: AppColors.background.withValues(alpha: .9),
      child: const Row(
        children: [
          Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 26),
          SizedBox(width: AppSpacing.xs),
          Text('WeightMe', style: AppTypography.titleMedium),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.selectedPeriod, required this.onPeriodChanged});

  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      height: 350,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Evolución del peso',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: WeightEvolutionChart(period: selectedPeriod)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final period in ['1S', '1M', '3M', '6M']) ...[
                Expanded(
                  child: _PeriodButton(
                    label: period,
                    selected: period == selectedPeriod,
                    onPressed: () => onPeriodChanged(period),
                  ),
                ),
                if (period != '6M') const SizedBox(width: AppSpacing.xxs),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({required this.label, required this.selected, required this.onPressed});

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceHighest,
      borderRadius: AppRadius.pill,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.pill,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelCaps.copyWith(
              color: selected ? const Color(0xFF1000A9) : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}



class _CurrentWeightCard extends StatelessWidget {
  const _CurrentWeightCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Peso actual', style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              const Icon(Icons.trending_down, color: AppColors.secondary),
            ],
          ),
          const Spacer(),
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(style: AppTypography.displayLarge.copyWith(fontSize: 72, height: 1), text: '75.4'),
                  TextSpan(style: AppTypography.headlineLarge.copyWith(color: AppColors.textSecondary), text: ' kg'),
                ],
              ),
            ),
          ),
          const Spacer(),
          const Divider(color: AppColors.outlineVariant),
          const SizedBox(height: AppSpacing.xs),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metric(label: 'ESTA SEMANA', value: '-0.8 kg', highlight: true),
              _Metric(label: 'ÚLTIMO REGISTRO', value: 'Hoy'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelCaps),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: highlight ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _TotalLostCard extends StatelessWidget {
  const _TotalLostCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total perdido', style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(style: AppTypography.displayLarge.copyWith(color: AppColors.secondary), text: '12.6'),
                TextSpan(style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary), text: ' kg'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.celebration_outlined, color: AppColors.secondary, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text('Desde el 1 de enero', style: AppTypography.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Siguiente objetivo', style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              _GoalPill(),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: const LinearProgressIndicator(
              value: .65,
              minHeight: 12,
              backgroundColor: AppColors.surfaceHighest,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('3.4 kg restantes', style: AppTypography.labelCaps),
              Text('65%', style: AppTypography.labelCaps),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12), borderRadius: AppRadius.pill),
      child: Text('72.0 kg', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
    );
  }
}

class _LogWeightButton extends StatelessWidget {
  const _LogWeightButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: const Text('Registrar peso'),
        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        border: Border.all(color: AppColors.surfaceHighest),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: .08), blurRadius: 40),
        ],
      ),
      child: child,
    );
  }
}
