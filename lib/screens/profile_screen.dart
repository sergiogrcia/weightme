import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _dailyReminders = true;
  String _selectedUnit = 'kg';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 760;
          return Column(
            children: [
              _ProfileTopBar(isDesktop: isDesktop),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? AppSpacing.desktopMargin : AppSpacing.mobileMargin,
                    AppSpacing.md,
                    isDesktop ? AppSpacing.desktopMargin : AppSpacing.mobileMargin,
                    AppSpacing.lg,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        children: [
                          const _ProfileHeader(),
                          const SizedBox(height: AppSpacing.lg),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _WeightGoalsCard(),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  flex: 5,
                                  child: _AppSettingsCard(
                                    dailyReminders: _dailyReminders,
                                    selectedUnit: _selectedUnit,
                                    onRemindersChanged: (val) {
                                      setState(() => _dailyReminders = val);
                                    },
                                    onUnitChanged: (unit) {
                                      if (unit != null) {
                                        setState(() => _selectedUnit = unit);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                const _WeightGoalsCard(),
                                const SizedBox(height: AppSpacing.md),
                                _AppSettingsCard(
                                  dailyReminders: _dailyReminders,
                                  selectedUnit: _selectedUnit,
                                  onRemindersChanged: (val) {
                                    setState(() => _dailyReminders = val);
                                  },
                                  onUnitChanged: (unit) {
                                    if (unit != null) {
                                      setState(() => _selectedUnit = unit);
                                    }
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.desktopMargin : AppSpacing.mobileMargin,
      ),
      color: AppColors.background.withValues(alpha: .9),
      child: Row(
        children: [
          const Icon(Icons.insights_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.show_chart_rounded, color: AppColors.primary),
          if (isDesktop) ...[
            const SizedBox(width: AppSpacing.xs),
            const Text('WeightMe', style: AppTypography.titleMedium),
            const Spacer(),
            const _NavItem('RESUMEN', active: false),
            const _NavItem('HISTORIAL', active: false),
            const _NavItem('PERFIL', active: true),
          ] else
            const Spacer(),
          if (!isDesktop) const Icon(Icons.menu, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.label, {required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Text(
        label,
        style: AppTypography.labelCaps.copyWith(
          color: active ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceHighest, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: .25),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Material(
                color: AppColors.surfaceHighest,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cambiar foto de perfil')),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.edit, size: 16, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text('Alex Mercer', style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.xxs),
        const Text('Activo desde oct. 2023', style: AppTypography.bodySmall),
      ],
    );
  }
}

class _WeightGoalsCard extends StatelessWidget {
  const _WeightGoalsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_outlined, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs),
              Text('Objetivos de peso', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 400;
              final child1 = _GoalBox(
                label: 'PESO INICIAL',
                value: '85.2',
                unit: 'kg',
                isHighlighted: false,
              );
              final child2 = _GoalBox(
                label: 'PESO META',
                value: '75.0',
                unit: 'kg',
                isHighlighted: true,
                onEdit: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editar objetivo de peso')),
                  );
                },
              );

              if (isSmall) {
                return Column(
                  children: [
                    child1,
                    const SizedBox(height: AppSpacing.sm),
                    child2,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: child1),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: child2),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso total', style: AppTypography.bodySmall),
              Text(
                '-4.5 kg',
                style: AppTypography.titleMedium.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: const LinearProgressIndicator(
              value: 0.44,
              minHeight: 12,
              backgroundColor: AppColors.surfaceHighest,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('44% completado', style: AppTypography.labelCaps),
              Text('5.7 kg restantes', style: AppTypography.labelCaps),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalBox extends StatelessWidget {
  const _GoalBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.isHighlighted,
    this.onEdit,
  });

  final String label;
  final String value;
  final String unit;
  final bool isHighlighted;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary.withValues(alpha: .4)
              : AppColors.outlineVariant.withValues(alpha: .3),
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .15),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelCaps.copyWith(
                  color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: AppTypography.headlineLarge),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    unit,
                    style: AppTypography.bodySmall.copyWith(
                      color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (onEdit != null)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onEdit,
                child: const Icon(Icons.edit, size: 16, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppSettingsCard extends StatelessWidget {
  const _AppSettingsCard({
    required this.dailyReminders,
    required this.selectedUnit,
    required this.onRemindersChanged,
    required this.onUnitChanged,
  });

  final bool dailyReminders;
  final String selectedUnit;
  final ValueChanged<bool> onRemindersChanged;
  final ValueChanged<String?> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings_outlined, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs),
              Text('Ajustes de la App', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(AppRadius.medium),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                const Expanded(
                  child: Text('Recordatorios diarios', style: AppTypography.bodyLarge),
                ),
                Switch(
                  value: dailyReminders,
                  onChanged: onRemindersChanged,
                  activeThumbColor: AppColors.primaryContainer,
                  activeTrackColor: AppColors.primary.withValues(alpha: .3),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
            child: Row(
              children: [
                const Icon(Icons.straighten_outlined, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                const Expanded(
                  child: Text('Unidades', style: AppTypography.bodyLarge),
                ),
                DropdownButton<String>(
                  value: selectedUnit,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.surfaceHigh,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  onChanged: onUnitChanged,
                  items: const [
                    DropdownMenuItem(
                      value: 'kg',
                      child: Text('Kilogramos (kg)'),
                    ),
                    DropdownMenuItem(
                      value: 'lbs',
                      child: Text('Libras (lbs)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.outlineVariant),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            borderRadius: const BorderRadius.all(AppRadius.medium),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión cerrada')),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.error),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
