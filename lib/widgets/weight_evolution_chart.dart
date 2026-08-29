import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WeightEvolutionChart extends StatelessWidget {
  const WeightEvolutionChart({this.period = '1M', super.key});

  final String period;

  @override
  Widget build(BuildContext context) {
    final labels = switch (period) {
      '1S' => const ['Lun', 'Jue', 'Dom'],
      '3M' => const ['Ago', 'Sep', 'Oct'],
      '6M' => const ['May', 'Jul', 'Oct'],
      _ => const ['1 oct', '15 oct', '31 oct'],
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              left: 38,
              bottom: 26,
              child: CustomPaint(
                painter: _WeightChartPainter(period: period),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              child: _AxisLabel('78 kg'),
            ),
            Positioned(
              top: constraints.maxHeight * .43,
              left: 0,
              child: const _AxisLabel('76 kg'),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              child: const _AxisLabel('74 kg'),
            ),
            Positioned(
              left: 40,
              bottom: 0,
              child: _AxisLabel(labels[0]),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_AxisLabel(labels[1])],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _AxisLabel(labels[2]),
            ),
          ],
        );
      },
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 10));
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({required this.period});

  final String period;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: .35)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var index = 0; index < 3; index++) {
      final y = size.height * index / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = switch (period) {
      '1S' => <Offset>[
          Offset(0, size.height * .45),
          Offset(size.width * .2, size.height * .50),
          Offset(size.width * .4, size.height * .35),
          Offset(size.width * .6, size.height * .40),
          Offset(size.width * .8, size.height * .25),
          Offset(size.width, size.height * .20),
        ],
      '3M' => <Offset>[
          Offset(0, size.height * .90),
          Offset(size.width * .25, size.height * .75),
          Offset(size.width * .50, size.height * .55),
          Offset(size.width * .75, size.height * .30),
          Offset(size.width, size.height * .15),
        ],
      '6M' => <Offset>[
          Offset(0, size.height * .95),
          Offset(size.width * .2, size.height * .85),
          Offset(size.width * .4, size.height * .70),
          Offset(size.width * .6, size.height * .50),
          Offset(size.width * .8, size.height * .30),
          Offset(size.width, size.height * .10),
        ],
      _ => <Offset>[
          Offset(0, size.height * .83),
          Offset(size.width * .2, size.height * .7),
          Offset(size.width * .4, size.height * .6),
          Offset(size.width * .6, size.height * .42),
          Offset(size.width * .8, size.height * .32),
          Offset(size.width, size.height * .08),
        ],
    };

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: .22),
            AppColors.primary.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(line, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) => oldDelegate.period != period;
}
