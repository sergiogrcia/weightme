import 'package:flutter/material.dart';

import '../services/weight_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.weightService, super.key});

  final WeightService weightService;

  @override
  Widget build(BuildContext context) {
    final profile = weightService.profile;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.mobileMargin,
          AppSpacing.md,
          AppSpacing.mobileMargin,
          AppSpacing.lg,
        ),
        child: Column(
          children: [
            const _ProfileHeader(),
            const SizedBox(height: AppSpacing.lg),
            _WeightGoalsCard(weightService: weightService),
            const SizedBox(height: AppSpacing.md),
            _AppSettingsCard(
              dailyReminders: profile.dailyReminders,
              selectedUnit: profile.unit,
              onRemindersChanged: (val) {
                weightService.updateProfile(profile.copyWith(dailyReminders: val));
              },
              onUnitChanged: (unit) {
                if (unit != null) {
                  weightService.updateProfile(profile.copyWith(unit: unit));
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _BackupCard(weightService: weightService),
          ],
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
                elevation: 4,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Alex Mercer', style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.xxs),
        const Text('Activo desde oct. 2023', style: AppTypography.bodySmall),
      ],
    );
  }
}

class _WeightGoalsCard extends StatelessWidget {
  const _WeightGoalsCard({required this.weightService});

  final WeightService weightService;

  void _editTargetWeight(BuildContext context) {
    final controller = TextEditingController(
      text: weightService.profile.targetWeight.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceHigh,
          title: Text('Editar Peso Meta', style: AppTypography.titleMedium),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              suffixText: weightService.profile.unit,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final val = double.tryParse(controller.text.replaceAll(',', '.'));
                if (val != null && val > 0) {
                  weightService.updateProfile(
                    weightService.profile.copyWith(targetWeight: val),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = weightService.profile;
    final totalLost = weightService.totalLost;
    final remaining = weightService.remainingKg;
    final progress = weightService.progressPercentage;
    final percentInt = (progress * 100).toInt();

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
                value: profile.startingWeight.toStringAsFixed(1),
                unit: profile.unit,
                isHighlighted: false,
              );
              final child2 = _GoalBox(
                label: 'PESO META',
                value: profile.targetWeight.toStringAsFixed(1),
                unit: profile.unit,
                isHighlighted: true,
                onEdit: () => _editTargetWeight(context),
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
                '-${totalLost.toStringAsFixed(1)} ${profile.unit}',
                style: AppTypography.titleMedium.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.surfaceHighest,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$percentInt% completado', style: AppTypography.labelCaps),
              Text('${remaining.toStringAsFixed(1)} ${profile.unit} restantes', style: AppTypography.labelCaps),
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
        borderRadius: BorderRadius.all(AppRadius.large),
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
              Icon(Icons.tune_outlined, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs),
              Text('Ajustes de la App', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recordatorios diarios', style: AppTypography.bodyLarge),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Notificación diaria para registrar peso',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: dailyReminders,
                onChanged: onRemindersChanged,
                activeThumbColor: AppColors.primaryContainer,
                activeTrackColor: AppColors.primary.withValues(alpha: .3),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(color: AppColors.outlineVariant),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Unidad de medida', style: AppTypography.bodyLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.all(AppRadius.small),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedUnit,
                    dropdownColor: AppColors.surfaceHighest,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
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
                    onChanged: onUnitChanged,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(color: AppColors.outlineVariant),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada')),
                );
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(
                'Cerrar sesión',
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.medium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard({required this.weightService});

  final WeightService weightService;

  Future<void> _importBackup(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Restaurar copia de seguridad', style: AppTypography.titleMedium),
        content: const Text(
          'Esta acción reemplazará los datos actuales por los del archivo JSON seleccionado. ¿Deseas continuar?',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await weightService.importBackupFromFile();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.secondary),
              SizedBox(width: AppSpacing.xs),
              Text('¡Copia de seguridad restaurada con éxito!'),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo importar el archivo JSON o la operación fue cancelada.'),
        ),
      );
    }
  }

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
              Icon(Icons.cloud_sync_outlined, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs),
              Text('Copia de seguridad', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Exporta tus datos a JSON para guardarlos fuera de la app o impórtalos al cambiar de móvil.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final filePath = await weightService.exportBackupFile();
                      if (context.mounted && filePath != null) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.secondary),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text('¡Copia guardada con éxito en:\n$filePath'),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al exportar copia de seguridad: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Exportar JSON'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.medium),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _importBackup(context),
                  icon: const Icon(Icons.download_for_offline_outlined, size: 18),
                  label: const Text('Importar JSON'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.medium),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
