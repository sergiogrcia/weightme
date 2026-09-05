import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class OnboardingLoadingScreen extends StatefulWidget {
  const OnboardingLoadingScreen({
    this.onComplete,
    super.key,
  });

  final VoidCallback? onComplete;

  @override
  State<OnboardingLoadingScreen> createState() =>
      _OnboardingLoadingScreenState();
}

class _OnboardingLoadingScreenState extends State<OnboardingLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _navigationTimer;

  int _progress = 0;
  int _currentMilestone = 1; // 1, 2, 3, 4

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _controller.addListener(() {
      final value = (_controller.value * 100).floor();
      if (value != _progress) {
        setState(() {
          _progress = value;
          if (_progress >= 95) {
            _currentMilestone = 4;
          } else if (_progress >= 65) {
            _currentMilestone = 3;
          } else if (_progress >= 30) {
            _currentMilestone = 2;
          } else {
            _currentMilestone = 1;
          }
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigationTimer = Timer(const Duration(milliseconds: 400), () {
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
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
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // Top Bar Navigation Header
                  _buildHeader(),

                  const Spacer(),

                  // Central Radial Loader & Progress Percent
                  _buildRadialLoader(),

                  const SizedBox(height: 28),

                  // Active Step Title & Subtitle
                  _buildStepTitle(),

                  const SizedBox(height: 24),

                  // Pipeline Cards
                  _buildPipelineCard(),

                  const Spacer(),

                  // Footer & Progress Dots
                  _buildFooter(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(text: 'WEIGHT'),
                  TextSpan(
                    text: 'ME',
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Procesando',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadialLoader() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Pulse Glow
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1.0 + math.sin(_controller.value * math.pi * 4) * 0.08;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6366F1).withValues(alpha: 0.35),
                        AppColors.secondary.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Custom Circular Progress Ring
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(180, 180),
                painter: _RadialProgressPainter(
                  progress: _controller.value,
                ),
              );
            },
          ),

          // Central Percentage Display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_progress',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _getSubStatus(),
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSubStatus() {
    if (_currentMilestone == 1) return 'Iniciando modelo';
    if (_currentMilestone == 2) return 'Balance Energético';
    if (_currentMilestone == 3) return 'Modelando tendencia';
    return 'Completado 100%';
  }

  Widget _buildStepTitle() {
    String title;
    String subtitle;
    bool isComplete = _currentMilestone == 4;

    if (_currentMilestone == 1) {
      title = 'Calculando Tasa Metabólica Basal (BMR)...';
      subtitle =
          'Cruzando edad, altura, sexo biológico y peso inicial con fórmula Mifflin-St Jeor.';
    } else if (_currentMilestone == 2) {
      title = 'Ajustando Déficit Calórico Óptimo...';
      subtitle =
          'Déficit moderado para preservar masa muscular y optimizar energía.';
    } else if (_currentMilestone == 3) {
      title = 'Generando Gráfica de Tendencia...';
      subtitle =
          'Calculando media móvil ponderada para filtrar fluctuaciones de agua.';
    } else {
      title = '¡Plan Personalizado Listo!';
      subtitle = 'Redirigiendo a tu Dashboard de progreso...';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isComplete)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const Icon(
                Icons.verified_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isComplete ? Colors.white : const Color(0xFFF1F5F9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            height: 16 / 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildPipelineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _buildPipelineRow(
            stepIndex: 1,
            title: 'Metabolismo Basal (BMR)',
            calculatingText: 'Calculando BMR...',
            doneText: 'BMR fijado con precisión',
          ),
          const SizedBox(height: 10),
          _buildPipelineRow(
            stepIndex: 2,
            title: 'Ajuste de Déficit y NEAT',
            calculatingText: 'Aplicando NEAT y ritmo...',
            doneText: 'Balance energético optimizado',
          ),
          const SizedBox(height: 10),
          _buildPipelineRow(
            stepIndex: 3,
            title: 'Curva de Tendencia y Recomp',
            calculatingText: 'Proyectando 8 semanas...',
            doneText: 'Tendencia y umbrales listos',
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineRow({
    required int stepIndex,
    required String title,
    required String calculatingText,
    required String doneText,
  }) {
    final isDone = _currentMilestone > stepIndex;
    final isActive = _currentMilestone == stepIndex;

    Color badgeBg;
    Color badgeText;
    String badgeLabel;
    IconData iconData;
    Color iconColor;

    if (isDone) {
      badgeBg = AppColors.secondary.withValues(alpha: 0.15);
      badgeText = AppColors.secondary;
      badgeLabel = 'Completado';
      iconData = Icons.check_circle_rounded;
      iconColor = AppColors.secondary;
    } else if (isActive) {
      badgeBg = AppColors.primary.withValues(alpha: 0.15);
      badgeText = AppColors.primary;
      badgeLabel = 'En curso';
      iconData = Icons.sync_rounded;
      iconColor = AppColors.primary;
    } else {
      badgeBg = AppColors.surfaceHigh;
      badgeText = const Color(0xFF64748B);
      badgeLabel = 'Pendiente';
      iconData = Icons.hourglass_empty_rounded;
      iconColor = const Color(0xFF64748B);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive || isDone
            ? AppColors.surfaceHigh.withValues(alpha: 0.6)
            : AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isDone
                  ? AppColors.secondary.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive || isDone
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isDone ? doneText : (isActive ? calculatingText : 'Esperando turno...'),
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: isDone
                        ? AppColors.secondary
                        : (isActive
                            ? AppColors.primary
                            : const Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeLabel,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security_rounded,
                size: 14,
                color: AppColors.secondary,
              ),
              SizedBox(width: 6),
              Text(
                'Cálculo local y adaptativo para máxima precisión',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final active = (index + 1) == _currentMilestone;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: active ? AppColors.secondary : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _RadialProgressPainter extends CustomPainter {
  _RadialProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track Paint
    final trackPaint = Paint()
      ..strokeWidth = 7
      ..color = const Color(0xFF18233C)
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, trackPaint);

    // Active Arc Paint with Gradient
    if (progress > 0) {
      final activePaint = Paint()
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [
            Color(0xFF44E2CD),
            Color(0xFF6366F1),
            Color(0xFFC0C1FF),
          ],
        ).createShader(rect);

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
