import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:muslim_mate/core/theme/app_colors.dart';
import 'package:muslim_mate/core/theme/app_text_styles.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: HomeColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavigationItem(
                icon: Iconsax.home_2,
                label: 'Home',
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavigationItem(
                icon: Iconsax.book_saved,
                label: 'Al-Ma\'tsurat',
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavigationItem(
                icon: Iconsax.book_1,
                label: 'Quran',
                active: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavigationItem(
                icon: Iconsax.clock,
                label: 'Prayer',
                active: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavigationItem(
                icon: Iconsax.profile_circle,
                label: 'Profile',
                active: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
        Container(
          height: 34,
          color: HomeColors.surface,
          child: Center(
            child: Container(
              width: 144,
              height: 5,
              decoration: BoxDecoration(
                color: HomeColors.onSurface.withOpacity(0.08),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: active ? HomeColors.primary : HomeColors.onSurfaceSecondary,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: HomeTextStyles.body12Regular.copyWith(
              color: active ? HomeColors.primary : HomeColors.onSurfaceSecondary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
