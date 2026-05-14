import 'package:flutter/material.dart';
import 'package:muslim_mate/core/theme/app_colors.dart';
import 'package:muslim_mate/core/theme/app_text_styles.dart';

class HomePrayerTimeChip extends StatelessWidget {
  const HomePrayerTimeChip({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    this.active = false,
  });

  final String title;
  final String time;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cardWidth = active ? 102.0 : 92.0;
    final cardHeight = active ? 132.0 : 102.0;
    final textColor = Colors.white;
    
    final card = Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: active
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(26),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: HomeTextStyles.title14Bold.copyWith(
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Icon(
            icon,
            size: 22,
            color: textColor,
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: HomeTextStyles.title16Bold.copyWith(
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );

    return card;
  }
}
