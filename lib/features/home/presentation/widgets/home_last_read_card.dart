import 'package:flutter/material.dart';
import 'package:muslim_mate/core/theme/app_colors.dart';
import 'package:muslim_mate/core/theme/app_text_styles.dart';

class HomeLastReadCard extends StatelessWidget {
  const HomeLastReadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HomeColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: HomeColors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Read',
                      style: HomeTextStyles.title14Regular.copyWith(
                        color: HomeColors.onSurfaceSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          color: HomeColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Al Baqarah : 120',
                          style: HomeTextStyles.body14Bold.copyWith(
                            color: HomeColors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: HomeColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: Text(
                            'Juz 1',
                            style: HomeTextStyles.body12Regular.copyWith(
                              color: HomeColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Center(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: HomeColors.primary,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Continue',
                    style: HomeTextStyles.body12Regular.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 8,
          child: Opacity(
            opacity: 0.1,
            child: Icon(
              Icons.book_outlined,
              size: 146,
              color: HomeColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
