import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Data class holding macro distribution percentages.
class OnboardingMacrosData {
  const OnboardingMacrosData({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
  });

  final int proteinPct;
  final int carbsPct;
  final int fatPct;

  bool get isValid => proteinPct + carbsPct + fatPct == 100;

  // Gram & kcal helpers given total daily calories.
  int proteinGrams(int totalKcal) =>
      ((totalKcal * proteinPct / 100) / 4).round();
  int carbsGrams(int totalKcal) => ((totalKcal * carbsPct / 100) / 4).round();
  int fatGrams(int totalKcal) => ((totalKcal * fatPct / 100) / 9).round();

  int proteinKcal(int totalKcal) => (totalKcal * proteinPct / 100).round();
  int carbsKcal(int totalKcal) => (totalKcal * carbsPct / 100).round();
  int fatKcal(int totalKcal) => (totalKcal * fatPct / 100).round();
}

// ─── Colour aliases (matching the summary screen) ───────────────────────────
const _kProteinColor = Color(0xFF6366F1); // Indigo (Proteína)
const _kCarbsColor = Color(0xFF38BDF8); // Sky blue (Carbos)
const _kFatColor = Color(0xFFFBBF24); // Amber (Grasas)

const _kPrimaryColor = Color(0xFFC0C1FF); // primary
const _kSecondaryColor = Color(0xFF44E2CD); // secondary (badge ok)
const _kSurfaceContainer = Color(0xFF171F33); // surface-container
const _kSurfaceContainerHigh = Color(0xFF222A3D);
const _kSurfaceContainerLowest = Color(0xFF060E20);
const _kErrorColor = Color(0xFFFFB4AB);

class OnboardingMacrosScreen extends StatefulWidget {
  const OnboardingMacrosScreen({
    required this.totalKcal,
    required this.onContinue,
    required this.onBack,
    super.key,
  });

  final int totalKcal;
  final ValueChanged<OnboardingMacrosData> onContinue;
  final VoidCallback onBack;

  @override
  State<OnboardingMacrosScreen> createState() => _OnboardingMacrosScreenState();
}

class _OnboardingMacrosScreenState extends State<OnboardingMacrosScreen>
    with SingleTickerProviderStateMixin {
  int _p = 30; // protein %
  int _c = 45; // carbs %
  int _f = 25; // fat %

  // -1 = none, 0 = balanced, 1 = high-protein, 2 = custom
  int _activePreset = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Determine initial preset match
    _syncPreset();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _syncPreset() {
    if (_p == 30 && _c == 45 && _f == 25) {
      _activePreset = 0;
    } else if (_p == 40 && _c == 35 && _f == 25) {
      _activePreset = 1;
    } else {
      _activePreset = 2;
    }
  }

  void _selectPreset(int preset) {
    setState(() {
      _activePreset = preset;
      if (preset == 0) {
        _p = 30;
        _c = 45;
        _f = 25;
      } else if (preset == 1) {
        _p = 40;
        _c = 35;
        _f = 25;
      }
    });
  }

  void _adjustMacro(String type, int delta) {
    setState(() {
      if (type == 'p') {
        final newVal = _p + delta;
        if (newVal >= 0 && newVal <= 100) _p = newVal;
      } else if (type == 'c') {
        final newVal = _c + delta;
        if (newVal >= 0 && newVal <= 100) _c = newVal;
      } else {
        final newVal = _f + delta;
        if (newVal >= 0 && newVal <= 100) _f = newVal;
      }
      _syncPreset();
    });
  }

  void _setMacroFromInput(String type, String raw) {
    final val = int.tryParse(raw);
    if (val == null || val < 0 || val > 100) return;
    setState(() {
      if (type == 'p') _p = val;
      if (type == 'c') _c = val;
      if (type == 'f') _f = val;
      _syncPreset();
    });
  }

  int get _sum => _p + _c + _f;
  bool get _isValid => _sum == 100;

  void _handleContinue() {
    if (!_isValid) return;
    widget.onContinue(
      OnboardingMacrosData(proteinPct: _p, carbsPct: _c, fatPct: _f),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width * 0.5 - 150,
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _kPrimaryColor.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.mobileMargin,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.md),

                  // Scrollable body
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIntro(),
                          const SizedBox(height: AppSpacing.md),
                          _buildPresetList(),
                          const SizedBox(height: AppSpacing.sm),
                          _buildEquivalencesCard(),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),

                  _buildFooter(),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            GestureDetector(
              onTap: widget.onBack,
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

            // Logo
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

        // Step label + progress bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PASO 6 DE 6',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.outline,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'MACRONUTRIENTES',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _kPrimaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Progress bar – 100% (last step before summary)
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
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), _kPrimaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimaryColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Intro ────────────────────────────────────────────────────────────────

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kSurfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _kSecondaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'CALIBRACIÓN NUTRICIONAL',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: _kSecondaryColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Distribución de macronutrientes',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 6),

        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF94A3B8),
            ),
            children: [
              const TextSpan(text: 'Configura el reparto de tus '),
              TextSpan(
                text: '${widget.totalKcal} kcal',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const TextSpan(text: ' diarias según tu estilo de alimentación.'),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Preset list ──────────────────────────────────────────────────────────

  Widget _buildPresetList() {
    return Column(
      children: [
        _buildBalancedCard(),
        const SizedBox(height: AppSpacing.sm),
        _buildHighProteinCard(),
        const SizedBox(height: AppSpacing.sm),
        _buildCustomCard(),
      ],
    );
  }

  Widget _buildBalancedCard() {
    final isActive = _activePreset == 0;
    return GestureDetector(
      onTap: () => _selectPreset(0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? _kSurfaceContainerHigh : _kSurfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? _kPrimaryColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _RadioDot(active: isActive),
                    const SizedBox(width: 10),
                    const Text(
                      'Equilibrada',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  '30 / 45 / 25',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: const Text(
                '30% Prot / 45% Carbos / 25% Grasas. Óptima para adherencia sostenible y energía constante.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: _MacroGramPills(
                prot: '${((widget.totalKcal * 0.30) / 4).round()}g Prot',
                carbs: '${((widget.totalKcal * 0.45) / 4).round()}g Carbos',
                fat: '${((widget.totalKcal * 0.25) / 9).round()}g Grasas',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighProteinCard() {
    final isActive = _activePreset == 1;
    return GestureDetector(
      onTap: () => _selectPreset(1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? _kSurfaceContainerHigh : _kSurfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? _kPrimaryColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _RadioDot(active: isActive),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alta en proteínas',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _kPrimaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Recomendado para Definición',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _kPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '40 / 35 / 25',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: const Text(
                '40% Prot / 35% Carbos / 25% Grasas. Mayor saciedad y preservación de masa muscular.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: _MacroGramPills(
                prot: '${((widget.totalKcal * 0.40) / 4).round()}g Prot',
                carbs: '${((widget.totalKcal * 0.35) / 4).round()}g Carbos',
                fat: '${((widget.totalKcal * 0.25) / 9).round()}g Grasas',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCard() {
    final isActive = _activePreset == 2;
    final sum = _sum;
    final diff = 100 - sum;
    final statusColor = _isValid ? _kSecondaryColor : _kErrorColor;

    return GestureDetector(
      onTap: () => setState(() => _activePreset = 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? _kSurfaceContainerHigh : _kSurfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? _kPrimaryColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RadioDot(active: isActive),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Personalizado',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, _) => Opacity(
                                    opacity: _pulseAnimation.value,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: _kPrimaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Define tus propios porcentajes con ajuste exacto.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isValid
                            ? Icons.verified_rounded
                            : Icons.warning_rounded,
                        size: 12,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isValid
                            ? '100% calibrado'
                            : 'Total: $sum% (${diff > 0 ? '+$diff' : '$diff'}%)',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Distribution bar
            _buildDistributionBar(),

            const SizedBox(height: 14),

            // Three macro columns
            Row(
              children: [
                Expanded(
                  child: _MacroColumn(
                    label: 'Proteína',
                    color: _kProteinColor,
                    value: _p,
                    totalKcal: widget.totalKcal,
                    kcalPerGram: 4,
                    onUp: () => _adjustMacro('p', 1),
                    onDown: () => _adjustMacro('p', -1),
                    onInput: (v) => _setMacroFromInput('p', v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroColumn(
                    label: 'Carbos',
                    color: _kCarbsColor,
                    value: _c,
                    totalKcal: widget.totalKcal,
                    kcalPerGram: 4,
                    onUp: () => _adjustMacro('c', 1),
                    onDown: () => _adjustMacro('c', -1),
                    onInput: (v) => _setMacroFromInput('c', v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroColumn(
                    label: 'Grasas',
                    color: _kFatColor,
                    value: _f,
                    totalKcal: widget.totalKcal,
                    kcalPerGram: 9,
                    onUp: () => _adjustMacro('f', 1),
                    onDown: () => _adjustMacro('f', -1),
                    onInput: (v) => _setMacroFromInput('f', v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tricolor bar
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 12,
            color: _kSurfaceContainerLowest,
            child: Row(
              children: [
                AnimatedFlex(flex: _p, color: _kProteinColor),
                AnimatedFlex(flex: _c, color: _kCarbsColor),
                AnimatedFlex(flex: _f, color: _kFatColor),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Legend row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BarLegendItem(color: _kProteinColor, label: 'Proteína', pct: _p),
            _BarLegendItem(
              color: _kCarbsColor,
              label: 'Carbos',
              pct: _c,
            ),
            _BarLegendItem(
              color: _kFatColor,
              label: 'Grasas',
              pct: _f,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEquivalencesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kSurfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: _kPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EQUIVALENCIAS METABÓLICAS',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      height: 1.6,
                      color: Color(0xFF94A3B8),
                    ),
                    children: [
                      TextSpan(
                        text: '1 g proteína = 4 kcal',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(text: ' • '),
                      TextSpan(
                        text: '1 g carbohidratos = 4 kcal',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(text: ' • '),
                      TextSpan(
                        text: '1 g grasa = 9 kcal',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text:
                            '. Podrás reajustar esta proporción en cualquier momento desde tu Perfil.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        GestureDetector(
          onTap: _isValid ? _handleContinue : null,
          child: AnimatedOpacity(
            opacity: _isValid ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _kPrimaryColor,
                borderRadius: BorderRadius.circular(999),
                boxShadow: _isValid
                    ? [
                        BoxShadow(
                          color: _kPrimaryColor.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isValid
                        ? 'Calcular mi Plan Personalizado'
                        : 'Los porcentajes deben sumar 100%',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF07006C),
                    ),
                  ),
                  if (_isValid) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Color(0xFF07006C),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 12,
              color: AppColors.outline.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Sincronización instantánea con tu plan calórico.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                color: AppColors.outline.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

/// Animated Radio-style dot.
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: active
            ? _kPrimaryColor.withValues(alpha: 0.15)
            : _kSurfaceContainerHigh,
        shape: BoxShape.circle,
        border: Border.all(color: active ? _kPrimaryColor : AppColors.outline),
      ),
      child: active
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _kPrimaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

/// Coloured pill row showing gram values.
class _MacroGramPills extends StatelessWidget {
  const _MacroGramPills({
    required this.prot,
    required this.carbs,
    required this.fat,
  });
  final String prot;
  final String carbs;
  final String fat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          prot,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _kProteinColor,
          ),
        ),
        const _Dot(),
        Text(
          carbs,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _kCarbsColor,
          ),
        ),
        const _Dot(),
        Text(
          fat,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _kFatColor,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Text('•', style: TextStyle(color: AppColors.outlineVariant)),
    );
  }
}

/// Animated flex segment for the tricolor distribution bar.
class AnimatedFlex extends StatelessWidget {
  const AnimatedFlex({required this.flex, required this.color, super.key});
  final int flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (flex <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: Container(color: color, height: double.infinity),
    );
  }
}

class _BarLegendItem extends StatelessWidget {
  const _BarLegendItem({
    required this.color,
    required this.label,
    required this.pct,
  });
  final Color color;
  final String label;
  final int pct;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 4),
        Text(
          '$pct%',
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Interactive macro column with up/down buttons and a text input.
class _MacroColumn extends StatefulWidget {
  const _MacroColumn({
    required this.label,
    required this.color,
    required this.value,
    required this.totalKcal,
    required this.kcalPerGram,
    required this.onUp,
    required this.onDown,
    required this.onInput,
  });

  final String label;
  final Color color;
  final int value;
  final int totalKcal;
  final int kcalPerGram;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final ValueChanged<String> onInput;

  @override
  State<_MacroColumn> createState() => _MacroColumnState();
}

class _MacroColumnState extends State<_MacroColumn> {
  late TextEditingController _controller;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) {
        widget.onInput(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _MacroColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && widget.value != oldWidget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  int get _kcal => (widget.totalKcal * widget.value / 100).round();
  int get _grams => (_kcal / widget.kcalPerGram).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _kSurfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Colour dot + label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Up arrow
          _ArrowButton(
            icon: Icons.keyboard_arrow_up_rounded,
            color: widget.color,
            onPressed: widget.onUp,
          ),

          // Ghost row: value above
          Text(
            '${widget.value + 1}%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),

          // Input field
          SizedBox(
            width: 52,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    filled: true,
                    fillColor: _kSurfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: widget.onInput,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Text(
                    '%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ghost row: value below
          Text(
            widget.value > 0 ? '${widget.value - 1}%' : '0%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),

          // Down arrow
          _ArrowButton(
            icon: Icons.keyboard_arrow_down_rounded,
            color: widget.color,
            onPressed: widget.onDown,
          ),

          const SizedBox(height: 8),

          // Grams result
          Text(
            '$_grams g',
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            '~$_kcal kcal',
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 24,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, size: 22, color: AppColors.outline),
      ),
    );
  }
}
