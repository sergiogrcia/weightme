import 'package:flutter/material.dart';

import '../models/weight_entry.dart';
import '../services/weight_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'weight_entry_tile.dart';

class MonthGroup extends StatelessWidget {
  const MonthGroup({
    required this.data,
    this.weightService,
    super.key,
  });

  final MonthEntries data;
  final WeightService? weightService;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.xs),
          child: Text(
            data.month.toUpperCase(),
            style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: .3)),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.card,
            child: Column(
              children: [
                for (var i = 0; i < data.entries.length; i++) ...[
                  _SlidableWeightTile(
                    key: Key(data.entries[i].id),
                    entry: data.entries[i],
                    weightService: weightService,
                    onDelete: () {
                      final service = weightService;
                      if (service != null) {
                        final entry = data.entries[i];
                        service.deleteEntry(entry.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Registro eliminado'),
                            action: SnackBarAction(
                              label: 'DESHACER',
                              textColor: AppColors.primary,
                              onPressed: () {
                                service.restoreEntry(entry);
                              },
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                  ),
                  if (i != data.entries.length - 1)
                    const Divider(height: 1, color: AppColors.outlineVariant),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SlidableWeightTile extends StatefulWidget {
  const _SlidableWeightTile({
    required this.entry,
    required this.onDelete,
    this.weightService,
    super.key,
  });

  final WeightEntry entry;
  final WeightService? weightService;
  final VoidCallback onDelete;

  static final ValueNotifier<String?> _openedTileId = ValueNotifier<String?>(null);

  @override
  State<_SlidableWeightTile> createState() => _SlidableWeightTileState();
}

class _SlidableWeightTileState extends State<_SlidableWeightTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.24, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _SlidableWeightTile._openedTileId.addListener(_onOpenedTileChanged);
  }

  void _onOpenedTileChanged() {
    if (_SlidableWeightTile._openedTileId.value != widget.entry.id) {
      _close();
    }
  }

  @override
  void dispose() {
    _SlidableWeightTile._openedTileId.removeListener(_onOpenedTileChanged);
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    _SlidableWeightTile._openedTileId.value = widget.entry.id;
    _controller.forward();
  }

  void _close() {
    if (_SlidableWeightTile._openedTileId.value == widget.entry.id) {
      _SlidableWeightTile._openedTileId.value = null;
    }
    if (_controller.isCompleted || _controller.isAnimating) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            alignment: Alignment.centerRight,
            color: AppColors.deleteAction,
            child: SizedBox(
              width: 88,
              height: double.infinity,
              child: InkWell(
                onTap: () {
                  _close();
                  widget.onDelete();
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white, size: 22),
                    SizedBox(height: 2),
                    Text(
                      'Borrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SlideTransition(
          position: _offsetAnimation,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx < -3) {
                _open();
              } else if (details.delta.dx > 3) {
                _close();
              }
            },
            onTap: () {
              if (_controller.isCompleted) {
                _close();
              }
            },
            child: Container(
              color: AppColors.surface,
              child: WeightEntryTile(
                entry: widget.entry,
                weightService: widget.weightService,
              ),
            ),
          ),
        ),
      ],
    );
  }
}