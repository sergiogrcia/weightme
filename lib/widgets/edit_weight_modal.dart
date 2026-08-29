import 'package:flutter/material.dart';

import '../models/weight_entry.dart';
import '../services/weight_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class EditWeightModal extends StatefulWidget {
  const EditWeightModal({
    required this.entry,
    required this.weightService,
    super.key,
  });

  final WeightEntry entry;
  final WeightService weightService;

  static Future<void> show(BuildContext context, WeightEntry entry, WeightService weightService) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditWeightModal(entry: entry, weightService: weightService),
    );
  }

  @override
  State<EditWeightModal> createState() => _EditWeightModalState();
}

class _EditWeightModalState extends State<EditWeightModal> {
  late final TextEditingController _weightController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final initialDisplayWeight = widget.weightService.displayWeight(widget.entry.weightKg);
    _weightController = TextEditingController(text: initialDisplayWeight.toStringAsFixed(1));
    _noteController = TextEditingController(text: widget.entry.note ?? '');
    _selectedDate = widget.entry.date;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.surfaceLowest,
              surface: AppColors.surfaceHigh,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    final text = _weightController.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(text);

    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un peso válido.')),
      );
      return;
    }

    final weightKg = widget.weightService.inputWeightToKg(parsed);
    final note = _noteController.text.trim();

    widget.weightService.updateEntry(
      id: widget.entry.id,
      weightKg: weightKg,
      date: _selectedDate,
      note: note.isEmpty ? null : note,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.weightService.profile.unit;
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final dateLabel = '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text('Editar registro', style: AppTypography.titleMedium),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Date selector
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.all(AppRadius.small),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.all(AppRadius.small),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Fecha: $dateLabel', style: AppTypography.bodyLarge),
                    const Spacer(),
                    const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Weight input field
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
              decoration: InputDecoration(
                labelText: 'Peso ($unit)',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                suffixText: unit,
                suffixStyle: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(AppRadius.small),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Note input field
            TextField(
              controller: _noteController,
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Nota / Comentario (opcional)',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(AppRadius.small),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surfaceLowest,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                ),
                child: Text(
                  'Guardar cambios',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.surfaceLowest, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
