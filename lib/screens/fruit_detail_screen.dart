import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../models/fruit.dart';
import '../widgets/fruit_illustrations.dart';
import '../widgets/responsive_layout.dart';
import 'not_found_screen.dart';

/// Screen 2: Fruit Detail Screen at nested URL '/fruit/:name'.
/// Shows an illustration of the corresponding fruit, a simple description, and a Back button.
class FruitDetailScreen extends StatelessWidget {
  final String fruitName;

  const FruitDetailScreen({
    super.key,
    required this.fruitName,
  });

  @override
  Widget build(BuildContext context) {
    final fruit = FruitRepository.findByNameOrSlug(fruitName);

    if (fruit == null) {
      return NotFoundScreen(queriedFruitName: fruitName);
    }

    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          fruit.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/'),
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
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 680),
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Large Fruit Illustration Showcase
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: fruit.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: fruit.borderColor),
                    ),
                    child: Center(
                      child: FruitIllustration.fromFruit(fruit, size: 130),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Fruit Name & URL Badge
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Text(
                        fruit.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          'URL: /fruit/${fruit.slug}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      fruit.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Divider(color: AppColors.cardBorder),

                  const SizedBox(height: 18),

                  // 3. Simple Fruit Description
                  Text(
                    fruit.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 4. Back to Fruits List Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back to Fruits List (/)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Quick Switcher to Other Fruits
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 16),
                  const Text(
                    'Other Fruits:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: FruitRepository.fruits.map((f) {
                      final isCurrent = f.slug == fruit.slug;
                      return ActionChip(
                        label: Text(f.name),
                        backgroundColor: isCurrent ? AppColors.primary : AppColors.surfaceSubtle,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.textWhite : AppColors.textPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color: isCurrent ? AppColors.primary : AppColors.cardBorder,
                          ),
                        ),
                        onPressed: isCurrent ? null : () => context.go('/fruit/${f.slug}'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
