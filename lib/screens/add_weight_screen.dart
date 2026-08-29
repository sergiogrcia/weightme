import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({required this.onCancel, super.key});

  final VoidCallback onCancel;

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController(text: '75.4');
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  static const _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isToday => DateUtils.isSameDay(_selectedDate, DateTime.now());

  String get _dateLabel {
    final date = _selectedDate;
    final prefix = _isToday ? 'Hoy, ' : '';
    return '$prefix${date.day} de ${_months[date.month - 1]}';
  }

  void _changeDate(int days) {
    final nextDate = _selectedDate.add(Duration(days: days));
    if (nextDate.isAfter(DateUtils.dateOnly(DateTime.now()))) return;
    setState(() => _selectedDate = nextDate);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateUtils.dateOnly(DateTime.now()),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final weight = _weightController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.secondary),
            const SizedBox(width: AppSpacing.xs),
            Text('¡Registro de $weight kg añadido con éxito!'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _Header(onBack: widget.onCancel),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.mobileMargin,
                AppSpacing.sm,
                AppSpacing.mobileMargin,
                AppSpacing.lg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Registra tu peso para seguir tu evolución.',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _WeightInput(controller: _weightController),
                    const SizedBox(height: AppSpacing.sm),
                    _DateSelector(
                      label: _dateLabel,
                      nextEnabled: !_isToday,
                      onPrevious: () => _changeDate(-1),
                      onNext: () => _changeDate(1),
                      onPickDate: _pickDate,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _NotesInput(controller: _noteController),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.add_task),
                        label: const Text('Guardar registro'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: AppTypography.titleMedium,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onCancel,
                      child: Text('Cancelar', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              color: AppColors.textSecondary,
            ),
          ),
          const Text('Añadir registro', style: AppTypography.titleMedium),
        ],
      ),
    );
  }
}

class _WeightInput extends StatelessWidget {
  const _WeightInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _FormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PESO', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 205,
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLarge.copyWith(fontSize: 64, height: 1),
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    final weight = double.tryParse(value?.replaceAll(',', '.') ?? '');
                    if (weight == null || weight <= 0) return 'Introduce un peso válido';
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(' kg', style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.label,
    required this.nextEnabled,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  final String label;
  final bool nextEnabled;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return _FormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text('FECHA', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundIconButton(icon: Icons.chevron_left, onPressed: onPrevious),
              TextButton.icon(
                onPressed: onPickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 20),
                label: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
              ),
              _RoundIconButton(icon: Icons.chevron_right, onPressed: nextEnabled ? onNext : null),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Puedes añadir varios registros para el mismo día.',
            style: AppTypography.bodySmall.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotesInput extends StatelessWidget {
  const _NotesInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _FormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text('NOTA OPCIONAL', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 60,
            child: TextField(
              controller: controller,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                hintText: 'Ej. En vacaciones, después de entrenar...',
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary.withValues(alpha: .55)),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(backgroundColor: AppColors.surfaceHigh),
      icon: Icon(icon),
    );
  }
}

class _FormSurface extends StatelessWidget {
  const _FormSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: .35)),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: .05), blurRadius: 40),
        ],
      ),
      child: child,
    );
  }
}
