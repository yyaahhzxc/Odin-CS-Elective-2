import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Simple fruit data model.
class Fruit {
  final String name;
  final String slug;
  final String description;
  final String category;
  final Color primaryColor;
  final Color backgroundColor;
  final Color borderColor;

  const Fruit({
    required this.name,
    required this.slug,
    required this.description,
    required this.category,
    required this.primaryColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

/// Simple fruit repository containing a curated list of fruits.
class FruitRepository {
  static const List<Fruit> fruits = [
    Fruit(
      name: 'Apple',
      slug: 'apple',
      description:
          'A sweet and crisp red fruit with a thin skin and juicy white flesh. Apples are rich in fiber and vitamin C, making them one of the most popular fruits worldwide.',
      category: 'Pomes',
      primaryColor: AppColors.appleRed,
      backgroundColor: AppColors.appleBg,
      borderColor: AppColors.appleBorder,
    ),
    Fruit(
      name: 'Banana',
      slug: 'banana',
      description:
          'A long, curved tropical fruit with a yellow peel when ripe. Bananas are soft, sweet, and packed with potassium and natural energy.',
      category: 'Tropical',
      primaryColor: AppColors.bananaGold,
      backgroundColor: AppColors.bananaBg,
      borderColor: AppColors.bananaBorder,
    ),
    Fruit(
      name: 'Strawberry',
      slug: 'strawberry',
      description:
          'A bright red, heart-shaped berry known for its sweet-tart flavor, fragrant aroma, and tiny seeds on its outer surface. It is loaded with vitamin C.',
      category: 'Berries',
      primaryColor: AppColors.strawberryRed,
      backgroundColor: AppColors.strawberryBg,
      borderColor: AppColors.strawberryBorder,
    ),
    Fruit(
      name: 'Orange',
      slug: 'orange',
      description:
          'A round, bright orange citrus fruit with a textured peel. Known for its refreshing, tangy juice and high concentration of vitamin C.',
      category: 'Citrus',
      primaryColor: AppColors.orangeCitrus,
      backgroundColor: AppColors.orangeBg,
      borderColor: AppColors.orangeBorder,
    ),
    Fruit(
      name: 'Mango',
      slug: 'mango',
      description:
          'A tropical fruit with smooth skin, juicy golden-orange flesh, and a rich, honey-sweet flavor. Often celebrated as the "King of Fruits".',
      category: 'Tropical',
      primaryColor: AppColors.mangoGold,
      backgroundColor: AppColors.mangoBg,
      borderColor: AppColors.mangoBorder,
    ),
    Fruit(
      name: 'Watermelon',
      slug: 'watermelon',
      description:
          'A large green-striped melon with crisp, refreshing ruby-red flesh containing over 90% water. Perfect for hydration on hot summer days.',
      category: 'Melons',
      primaryColor: AppColors.watermelonRose,
      backgroundColor: AppColors.watermelonBg,
      borderColor: AppColors.watermelonBorder,
    ),
  ];

  /// Find a fruit by name or slug (case-insensitive & URL-safe).
  static Fruit? findByNameOrSlug(String query) {
    final cleaned = Uri.decodeComponent(query).trim().toLowerCase().replaceAll('/', '');
    try {
      return fruits.firstWhere((f) {
        return f.slug.toLowerCase() == cleaned ||
            f.name.toLowerCase() == cleaned ||
            f.name.toLowerCase().replaceAll(' ', '') == cleaned.replaceAll(' ', '');
      });
    } catch (_) {
      return null;
    }
  }
}
