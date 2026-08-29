import 'package:flutter/material.dart';

import '../services/weight_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WeightEvolutionChart extends StatelessWidget {
  const WeightEvolutionChart({
    this.period = '1M',
    this.weightService,
    super.key,
  });

  final String period;
  final WeightService? weightService;

  @override
  Widget build(BuildContext context) {
    final entries = _getFilteredEntries();
    final unitStr = weightService?.profile.unit ?? 'kg';

    final double minWeight;
    final double maxWeight;

    if (entries.isEmpty) {
      final base = weightService?.currentDisplayWeight ?? 75.0;
      minWeight = base - 2.0;
      maxWeight = base + 2.0;
    } else {
      var min = entries.first.weightVal;
      var max = entries.first.weightVal;
      for (final e in entries) {
        if (e.weightVal < min) min = e.weightVal;
        if (e.weightVal > max) max = e.weightVal;
      }
      if ((max - min).abs() < 0.1) {
        minWeight = min - 2.0;
        maxWeight = max + 2.0;
      } else {
        final padding = (max - min) * 0.15;
        minWeight = min - padding;
        maxWeight = max + padding;
      }
    }

    final topLabel = '${maxWeight.toStringAsFixed(1)} $unitStr';
    final midLabel = '${((minWeight + maxWeight) / 2).toStringAsFixed(1)} $unitStr';
    final botLabel = '${minWeight.toStringAsFixed(1)} $unitStr';

    final xLabels = _getXLabels(entries);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              left: 56,
              bottom: 26,
              child: CustomPaint(
                painter: _WeightChartPainter(
                  entries: entries,
                  minWeight: minWeight,
                  maxWeight: maxWeight,
                ),
              ),
            ),
            Positioned(top: 0, left: 0, child: _AxisLabel(topLabel)),
            Positioned(top: constraints.maxHeight * .43, left: 0, child: _AxisLabel(midLabel)),
            Positioned(bottom: 24, left: 0, child: _AxisLabel(botLabel)),
            Positioned(left: 56, bottom: 0, child: _AxisLabel(xLabels[0])),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_AxisLabel(xLabels[1])],
              ),
            ),
            Positioned(right: 0, bottom: 0, child: _AxisLabel(xLabels[2])),
          ],
        );
      },
    );
  }

  List<_ChartPointData> _getFilteredEntries() {
    if (weightService == null || weightService!.entries.isEmpty) {
      return [];
    }

    final allEntries = weightService!.entries;
    final now = DateTime.now();

    final daysLimit = switch (period) {
      '1S' => 7,
      '3M' => 90,
      '6M' => 180,
      _ => 30,
    };

    final cutoff = now.subtract(Duration(days: daysLimit));

    final filtered = allEntries.where((e) {
      return e.date.isAfter(cutoff) || DateUtils.isSameDay(e.date, cutoff);
    }).toList();

    filtered.sort((a, b) => a.date.compareTo(b.date));

    return filtered.map((e) {
      return _ChartPointData(
        date: e.date,
        weightVal: weightService!.displayWeight(e.weightKg),
      );
    }).toList();
  }

  List<String> _getXLabels(List<_ChartPointData> entries) {
    if (entries.isEmpty) {
      return switch (period) {
        '1S' => const ['Hace 7d', 'Hace 3d', 'Hoy'],
        '3M' => const ['Hace 3M', 'Hace 1.5M', 'Hoy'],
        '6M' => const ['Hace 6M', 'Hace 3M', 'Hoy'],
        _ => const ['Hace 30d', 'Hace 15d', 'Hoy'],
      };
    }

    if (entries.length == 1) {
      final dateStr = _formatDate(entries.first.date);
      return [dateStr, dateStr, dateStr];
    }

    final first = entries.first.date;
    final last = entries.last.date;
    final midMillis = (first.millisecondsSinceEpoch + last.millisecondsSinceEpoch) ~/ 2;
    final mid = DateTime.fromMillisecondsSinceEpoch(midMillis);

    return [
      _formatDate(first),
      _formatDate(mid),
      _formatDate(last),
    ];
  }

  String _formatDate(DateTime date) {
    if (DateUtils.isSameDay(date, DateTime.now())) return 'Hoy';
    const spanishMonths = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${date.day} ${spanishMonths[date.month - 1]}';
  }
}

class _ChartPointData {
  const _ChartPointData({required this.date, required this.weightVal});
  final DateTime date;
  final double weightVal;
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
  _WeightChartPainter({
    required this.entries,
    required this.minWeight,
    required this.maxWeight,
  });

  final List<_ChartPointData> entries;
  final double minWeight;
  final double maxWeight;

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
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (var index = 0; index < 3; index++) {
      final y = size.height * index / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (entries.isEmpty) {
      final y = size.height / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      return;
    }

    final points = <Offset>[];
    final rangeY = maxWeight - minWeight;

    if (entries.length == 1) {
      final yRatio = (entries.first.weightVal - minWeight) / rangeY;
      final y = size.height * (1.0 - yRatio.clamp(0.0, 1.0));
      points.add(Offset(0, y));
      points.add(Offset(size.width, y));
    } else {
      final firstTime = entries.first.date.millisecondsSinceEpoch.toDouble();
      final lastTime = entries.last.date.millisecondsSinceEpoch.toDouble();
      final timeDiff = lastTime - firstTime;

      for (var i = 0; i < entries.length; i++) {
        final e = entries[i];
        final x = timeDiff > 0
            ? size.width * (e.date.millisecondsSinceEpoch - firstTime) / timeDiff
            : size.width * i / (entries.length - 1);
        final yRatio = (e.weightVal - minWeight) / rangeY;
        final y = size.height * (1.0 - yRatio.clamp(0.0, 1.0));
        points.add(Offset(x, y));
      }
    }

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

    for (final pt in points) {
      canvas.drawCircle(pt, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.minWeight != minWeight ||
        oldDelegate.maxWeight != maxWeight;
  }
}
