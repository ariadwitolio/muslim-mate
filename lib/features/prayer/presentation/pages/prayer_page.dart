import 'package:flutter/material.dart';
import 'package:muslim_mate/constants/index.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text(
          'Prayer schedule and next prayer countdown will appear here.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
