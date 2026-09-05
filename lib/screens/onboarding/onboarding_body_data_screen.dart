import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class OnboardingBodyData {
  const OnboardingBodyData({
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    this.bodyFatPercentage,
  });

  final String sex; // 'hombre' or 'mujer'
  final int age;
  final double heightCm;
  final double weightKg;
  final double? bodyFatPercentage;
}

class OnboardingBodyDataScreen extends StatefulWidget {
  const OnboardingBodyDataScreen({
    this.initialData,
    this.onContinue,
    this.onBack,
    super.key,
  });

  final OnboardingBodyData? initialData;
  final ValueChanged<OnboardingBodyData>? onContinue;
  final VoidCallback? onBack;

  @override
  State<OnboardingBodyDataScreen> createState() =>
      _OnboardingBodyDataScreenState();
}

class _OnboardingBodyDataScreenState extends State<OnboardingBodyDataScreen> {
  late String _sex;
  late int _age;
  late double _heightCm;
  late double _weightKg;
  late bool _enableBodyFat;
  late double _bodyFat;

  // Controllers y focus nodes para los campos editables
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  late final FocusNode _ageFocusNode;
  late final FocusNode _heightFocusNode;
  late final FocusNode _weightFocusNode;

  @override
  void initState() {
    super.initState();
    _sex = widget.initialData?.sex ?? 'hombre';
    _age = widget.initialData?.age ?? 28;
    _heightCm = widget.initialData?.heightCm ?? 178.0;
    _weightKg = widget.initialData?.weightKg ?? 74.5;
    _enableBodyFat = widget.initialData?.bodyFatPercentage != null;
    _bodyFat = widget.initialData?.bodyFatPercentage ?? 18.0;

    _ageController = TextEditingController(text: '$_age');
    _heightController = TextEditingController(text: '${_heightCm.toInt()}');
    _weightController = TextEditingController(
      text: _weightKg.toStringAsFixed(1),
    );

    _ageFocusNode = FocusNode();
    _heightFocusNode = FocusNode();
    _weightFocusNode = FocusNode();

    // Al perder el foco (el usuario toca fuera del campo), validamos y
    // formateamos el valor introducido.
    _ageFocusNode.addListener(() {
      if (!_ageFocusNode.hasFocus) _commitAge();
    });
    _heightFocusNode.addListener(() {
      if (!_heightFocusNode.hasFocus) _commitHeight();
    });
    _weightFocusNode.addListener(() {
      if (!_weightFocusNode.hasFocus) _commitWeight();
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  void _handleContinue() {
    // Aseguramos que cualquier valor que se estuviera editando se valide
    // antes de continuar.
    _commitAge();
    _commitHeight();
    _commitWeight();

    if (widget.onContinue != null) {
      widget.onContinue!(
        OnboardingBodyData(
          sex: _sex,
          age: _age,
          heightCm: _heightCm,
          weightKg: _weightKg,
          bodyFatPercentage: _enableBodyFat ? _bodyFat : null,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------
  // Commits: parsean el texto introducido, lo limitan al rango válido y
  // sincronizan de nuevo el controller con el valor formateado final.
  // ---------------------------------------------------------------------

  void _commitAge() {
    final parsed = int.tryParse(_ageController.text);
    setState(() {
      _age = (parsed ?? _age).clamp(12, 100);
      _ageController.text = '$_age';
    });
  }

  void _commitHeight() {
    final parsed = double.tryParse(_heightController.text);
    setState(() {
      _heightCm = (parsed ?? _heightCm).toDouble().clamp(100.0, 250.0);
      _heightController.text = '${_heightCm.toInt()}';
    });
  }

  void _commitWeight() {
    final normalized = _weightController.text.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    setState(() {
      _weightKg = (parsed ?? _weightKg).clamp(30.0, 300.0);
      _weightController.text = _weightKg.toStringAsFixed(1);
    });
  }

  // ---------------------------------------------------------------------
  // Ajustes con los botones +/- : actualizan el valor Y el controller
  // correspondiente para que ambos se mantengan sincronizados.
  // ---------------------------------------------------------------------

  void _adjustWeight(double delta) {
    setState(() {
      _weightKg = (_weightKg + delta).clamp(30.0, 300.0);
      _weightController.text = _weightKg.toStringAsFixed(1);
    });
  }

  void _adjustHeight(double delta) {
    setState(() {
      _heightCm = (_heightCm + delta).clamp(100.0, 250.0);
      _heightController.text = '${_heightCm.toInt()}';
    });
  }

  void _adjustAge(int delta) {
    setState(() {
      _age = (_age + delta).clamp(12, 100);
      _ageController.text = '$_age';
    });
  }

  void _adjustBodyFat(double delta) {
    setState(() {
      _bodyFat = (_bodyFat + delta).clamp(4.0, 60.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Glow Top
          Positioned(
            top: -40,
            left: MediaQuery.of(context).size.width * 0.5 - 160,
            child: Container(
              width: 320,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.mobileMargin,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xs),

                  // Header Bar (Back button + Logo + Stepper 75%)
                  _buildHeader(context),

                  const SizedBox(height: AppSpacing.md),

                  // Main Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Intro Section
                          _buildIntroSection(),

                          const SizedBox(height: AppSpacing.md),

                          // FIELD A: Biological Sex
                          _buildSexField(),

                          const SizedBox(height: AppSpacing.sm),

                          // FIELD B: Age
                          _buildAgeField(),

                          const SizedBox(height: AppSpacing.sm),

                          // FIELD C: Height
                          _buildHeightField(),

                          const SizedBox(height: AppSpacing.sm),

                          // FIELD D: Current Weight
                          _buildWeightField(),

                          const SizedBox(height: AppSpacing.sm),

                          // FIELD E: Body Fat Percentage (Optional)
                          _buildBodyFatField(),

                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Button & Privacy Disclaimer
                  _buildFooter(context),

                  const SizedBox(height: AppSpacing.xs),
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
              onTap: widget.onBack,
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
            const SizedBox(width: 36),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Step Progress Bar (75% filled - Paso 3 de 4)
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
              widthFactor: 0.60,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PASO 3 DE 4',
              style: AppTypography.labelCaps.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8E9BB5),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'DATOS CORPORALES',
              style: AppTypography.labelCaps.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: const Icon(
            Icons.bar_chart_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tus datos corporales',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Necesitamos estos datos para calcular con precisión tu metabolismo basal (BMR) e IMC inicial.',
          style: AppTypography.bodySmall.copyWith(
            fontSize: 13.5,
            color: const Color(0xFF8E9BB5),
          ),
        ),
      ],
    );
  }

  Widget _buildSexField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SEXO BIOLÓGICO',
                style: AppTypography.labelCaps.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8E9BB5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'REQUERIDO',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2DD4BF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Para ajustar fórmulas de BMR y masa libre de grasa.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF626F8B)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSexOptionCard(
                  label: 'Hombre',
                  icon: Icons.male_rounded,
                  isSelected: _sex == 'hombre',
                  onTap: () => setState(() => _sex = 'hombre'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSexOptionCard(
                  label: 'Mujer',
                  icon: Icons.female_rounded,
                  isSelected: _sex == 'mujer',
                  onTap: () => setState(() => _sex = 'mujer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSexOptionCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceHigh : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned(
                top: 0,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: AppColors.background,
                  ),
                ),
              ),
            Column(
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF8E9BB5),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF8E9BB5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Helper genérico para un número editable (edad / altura / peso).
  // Se muestra como TextField sin bordes, con el mismo estilo que antes,
  // pero permite tocar y escribir directamente.
  // ---------------------------------------------------------------------
  Widget _buildEditableNumber({
    required TextEditingController controller,
    required FocusNode focusNode,
    required double fontSize,
    required VoidCallback onSubmit,
    TextInputType keyboardType = TextInputType.number,
    List<TextInputFormatter>? inputFormatters,
    int maxLength = 3,
  }) {
    return IntrinsicWidth(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        inputFormatters:
            inputFormatters ??
            [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(maxLength),
            ],
        cursorColor: AppColors.primary,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onTap: () {
          // Selecciona todo el texto para que escribir reemplace el valor.
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
        onSubmitted: (_) {
          onSubmit();
          focusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildAgeField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EDAD',
                style: AppTypography.labelCaps.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8E9BB5),
                ),
              ),
              const Text(
                'Años',
                style: TextStyle(fontSize: 11, color: Color(0xFF8E9BB5)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Afecta directamente a la tasa metabólica estimada.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF626F8B)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepperButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _adjustAge(-1),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _buildEditableNumber(
                          controller: _ageController,
                          focusNode: _ageFocusNode,
                          fontSize: 28,
                          maxLength: 3,
                          onSubmit: _commitAge,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'años',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8E9BB5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAgeStripNumber(_age - 2),
                        _buildAgeStripNumber(_age - 1),
                        Text(
                          ' $_age ',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        _buildAgeStripNumber(_age + 1),
                        _buildAgeStripNumber(_age + 2),
                      ],
                    ),
                  ],
                ),
                _buildStepperButton(
                  icon: Icons.add_rounded,
                  onTap: () => _adjustAge(1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeStripNumber(int value) {
    if (value < 10) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        '$value',
        style: const TextStyle(fontSize: 10, color: Color(0xFF626F8B)),
      ),
    );
  }

  Widget _buildHeightField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ALTURA',
                style: AppTypography.labelCaps.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8E9BB5),
                ),
              ),
              const Text(
                'cm',
                style: TextStyle(fontSize: 11, color: Color(0xFF8E9BB5)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Cálculo de superficie corporal e índice de masa corporal.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF626F8B)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSmallAdjustmentButton(
                      label: '-1',
                      onTap: () => _adjustHeight(-1),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _buildEditableNumber(
                          controller: _heightController,
                          focusNode: _heightFocusNode,
                          fontSize: 28,
                          maxLength: 3,
                          onSubmit: _commitHeight,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'cm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    _buildSmallAdjustmentButton(
                      label: '+1',
                      onTap: () => _adjustHeight(1),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Ruler simulator
                Container(
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(11, (index) {
                      final isCenter = index == 5;
                      final isMajor = index % 4 == 0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: isCenter ? 2.5 : (isMajor ? 2.0 : 1.5),
                        height: isCenter ? 18 : (isMajor ? 12 : 8),
                        decoration: BoxDecoration(
                          color: isCenter
                              ? AppColors.primary
                              : (isMajor
                                    ? const Color(0xFF8E9BB5)
                                    : const Color(0xFF313D59)),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PESO ACTUAL',
                style: AppTypography.labelCaps.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8E9BB5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'BASE DEL PLAN',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'El punto de partida de tu evolución física.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF626F8B)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    _buildEditableNumber(
                      controller: _weightController,
                      focusNode: _weightFocusNode,
                      fontSize: 36,
                      maxLength: 5,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}([.,]\d{0,1})?$'),
                        ),
                        LengthLimitingTextInputFormatter(5),
                      ],
                      onSubmit: _commitWeight,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'kg',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAdjustButton(
                        '-0.5',
                        () => _adjustWeight(-0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAdjustButton(
                        '-0.1',
                        () => _adjustWeight(-0.1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAdjustButton(
                        '+0.1',
                        () => _adjustWeight(0.1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAdjustButton(
                        '+0.5',
                        () => _adjustWeight(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyFatField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '% GRASA CORPORAL',
                    style: AppTypography.labelCaps.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8E9BB5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OPCIONAL',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Switch(
                value: _enableBodyFat,
                onChanged: (val) => setState(() => _enableBodyFat = val),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                inactiveTrackColor: AppColors.surface,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Permite utilizar la fórmula Katch-McArdle con mayor precisión. Si no lo sabes, se calculará automáticamente.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF626F8B),
              height: 1.4,
            ),
          ),
          if (_enableBodyFat) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimación actual',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Atleta / Saludable',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8E9BB5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildSmallAdjustmentButton(
                        label: '-1',
                        onTap: () => _adjustBodyFat(-1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_bodyFat.toInt()}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildSmallAdjustmentButton(
                        label: '+1',
                        onTap: () => _adjustBodyFat(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildSmallAdjustmentButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8E9BB5),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAdjustButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8E9BB5),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _handleContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              elevation: 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.25),
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
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
