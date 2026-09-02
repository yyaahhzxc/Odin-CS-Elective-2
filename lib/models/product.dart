/// Model representing an individual variant of a product (e.g. specific color or edition).
///
/// Contains a sub-id (`id`) so the cart and checkout systems can uniquely
/// identify the exact chosen variant in the second half of the project.
class ProductVariant {
  final String id; // sub-id (e.g. 'prod-001-v1')
  final String name; // variant name (e.g. 'Violet', 'Black')
  final double? price; // optional custom price for this variant
  final String? imagePath; // optional specific image for this variant
  final String? description; // optional variant-specific details
  final int? stock; // optional variant stock

  const ProductVariant({
    required this.id,
    required this.name,
    this.price,
    this.imagePath,
    this.description,
    this.stock,
  });
}

/// Data model representing a merchandise item in the CSShop catalog.
///
/// Kept immutable to ensure predictable state and prevent unintended mutations.
class Product {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  final String category;
  final String description;
  final int soldCount;
  final int stock;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.description,
    required this.soldCount,
    required this.stock,
    this.variants = const [],
  });

  /// Formatted Philippine Peso price string.
  String get formattedPrice => '₱${price.toStringAsFixed(0)}';
}
