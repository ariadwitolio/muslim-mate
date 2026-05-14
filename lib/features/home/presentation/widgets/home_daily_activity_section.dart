import 'package:flutter/material.dart';
import 'package:muslim_mate/core/theme/app_colors.dart';
import 'package:muslim_mate/core/theme/app_text_styles.dart';

class HomeDailyActivitySection extends StatelessWidget {
  const HomeDailyActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Activity',
                    style: HomeTextStyles.title16Bold.copyWith(
                      color: HomeColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete the daily activity checklist',
                    style: HomeTextStyles.body14Regular.copyWith(
                      color: HomeColors.onSurfaceSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: HomeColors.warning,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: Text(
                '50%',
                style: HomeTextStyles.label10Bold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(
                  10,
                  (index) => Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(left: index == 0 ? 0 : 2),
                      decoration: BoxDecoration(
                        color: index < 3 ? HomeColors.primary : HomeColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '3/6',
              style: HomeTextStyles.body14Bold.copyWith(
                color: HomeColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ActivityCard(
          label: 'Alms',
          progressText: '4/10',
        ),
        const SizedBox(height: 12),
        _ActivityCard(
          label: 'Recite the Al Quran',
          progressText: '8/10',
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1000),
              ),
            ),
            child: Text(
              'Go to Checklist',
              style: HomeTextStyles.body14Bold.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.label,
    required this.progressText,
  });

  final String label;
  final String progressText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: HomeColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: HomeTextStyles.body14Regular.copyWith(
                color: HomeColors.onSurface,
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: progressText.split('/').first,
                  style: HomeTextStyles.body14Bold.copyWith(
                    color: HomeColors.primary,
                  ),
                ),
                TextSpan(
                  text: '/${progressText.split('/').last}',
                  style: HomeTextStyles.body14Regular.copyWith(
                    color: HomeColors.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.circle_outlined,
            size: 28,
            color: HomeColors.onSurfaceSecondary,
          ),
        ],
      ),
    );
  }
}
