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
              icon: Icons.dashboard_rounded,
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
            _NavigationIcon(
              icon: Icons.add_circle_outline_rounded,
              label: 'Añadir',
              selected: currentIndex == 2,
              onPressed: () => onDestinationSelected(2),
            ),
            _NavigationIcon(
              icon: Icons.person_outline_rounded,
              label: 'Perfil',
              selected: currentIndex == 3,
              onPressed: () => onDestinationSelected(3),
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
        fixedSize: const Size(72, 56),
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.medium),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: .15) : Colors.transparent,
              borderRadius: AppRadius.pill,
            ),
            child: Icon(icon, size: 21),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
