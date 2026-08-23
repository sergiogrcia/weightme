import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) return const SizedBox.shrink();

        return SafeArea(
          top: false,
          child: Container(
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.outlineVariant)),
              borderRadius: BorderRadius.vertical(top: AppRadius.large),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavigationIcon(
                  icon: Icons.dashboard_rounded,
                  selected: currentIndex == 0,
                  onPressed: () => onDestinationSelected(0),
                ),
                _NavigationIcon(
                  icon: Icons.history_rounded,
                  selected: currentIndex == 1,
                  onPressed: () => onDestinationSelected(1),
                ),
                _NavigationIcon(
                  icon: Icons.add_circle_outline_rounded,
                  selected: currentIndex == 2,
                  onPressed: () => onDestinationSelected(2),
                ),
                _NavigationIcon(
                  icon: Icons.person_outline_rounded,
                  selected: currentIndex == 3,
                  onPressed: () => onDestinationSelected(3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: selected ? AppColors.primaryContainer : Colors.transparent,
        fixedSize: const Size(48, 48),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
      ),
      icon: Icon(
        icon,
        color: selected ? const Color(0xFF0D0096) : AppColors.textSecondary,
      ),
    );
  }
}
