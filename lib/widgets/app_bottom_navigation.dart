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
              icon: Icons.home_rounded,
              label: 'Inicio',
              selected: currentIndex == 0,
              onPressed: () => onDestinationSelected(0),
            ),
            _NavigationIcon(
              icon: Icons.history_rounded,
              label: 'Historial',
              selected: currentIndex == 1,
              onPressed: () => onDestinationSelected(1),
            ),
            _AddNavigationIcon(
              selected: currentIndex == 2,
              onPressed: () => onDestinationSelected(2),
            ),
            _NavigationIcon(
              icon: Icons.calculate_outlined,
              label: 'Calculadora',
              selected: currentIndex == 3,
              onPressed: () => onDestinationSelected(3),
            ),
            _NavigationIcon(
              icon: Icons.person_outline_rounded,
              label: 'Perfil',
              selected: currentIndex == 4,
              onPressed: () => onDestinationSelected(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddNavigationIcon extends StatelessWidget {
  const _AddNavigationIcon({required this.selected, required this.onPressed});

  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const double iconCenterY = 21.0;
    const double circleSize = 50.0;

    return InkWell(
      onTap: onPressed,
      borderRadius: const BorderRadius.all(AppRadius.medium),
      child: SizedBox(
        width: 60,
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: iconCenterY - (circleSize / 2),
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: selected
                          ? AppColors.primary.withValues(alpha: .5)
                          : AppColors.primary.withValues(alpha: .25),
                      blurRadius: selected ? 12 : 6,
                      spreadRadius: selected ? 1 : 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF060060),
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: selected ? AppColors.primary : AppColors.textSecondary,
        fixedSize: const Size(60, 56),
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.medium),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: .15)
                  : Colors.transparent,
              borderRadius: AppRadius.pill,
            ),
            child: Icon(icon, size: 21),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
