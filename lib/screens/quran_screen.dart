import 'package:flutter/material.dart';
import 'package:muslim_mate/constants/index.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text(
          'Quran reader and Surah list will appear here.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
