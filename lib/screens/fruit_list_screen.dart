import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/fruit.dart';
import '../widgets/fruit_card.dart';
import '../widgets/responsive_layout.dart';

/// Screen 1: Fruit List Screen at root URL '/'.
/// Displays the list of fruits with responsive layout and go_router nested navigation.
class FruitListScreen extends StatelessWidget {
  const FruitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Fruits App',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.cardBorder, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: WebContentContainer(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16.0 : 24.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fruits List',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select any fruit to view its illustration and description at /fruit/:name.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildFruitsGrid(isMobile, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFruitsGrid(bool isMobile, bool isTablet) {
    final fruits = FruitRepository.fruits;

    int crossAxisCount = 3;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 16.0;
        final totalSpacing = spacing * (crossAxisCount - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: fruits.map((f) {
            return SizedBox(
              width: itemWidth,
              child: FruitCard(fruit: f),
            );
          }).toList(),
        );
      },
    );
  }
}
