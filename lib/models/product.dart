/// Model representing an individual variant of a product (e.g. color, style, or edition).
///
/// Fields like `price`, `description`, and `stock` are optional (nullable).
/// If omitted, the app automatically inherits the base product's details so you
/// do not need to repeat them for every variant.
class ProductVariant {
  final String id; // sub-id for cart & checkout (e.g. 'prod-001-v1')
  final String name; // variant name (e.g. 'Violet', 'Black')
  final double? price; // optional: only set if different from base product price
  final String? imagePath; // optional: single image path
  final List<String> images; // optional: multiple images (e.g. ['front.png', 'back.png'])
  final String? description; // optional: only set if different from base description
  final int? stock; // optional: only set if different from base stock

  const ProductVariant({
    required this.id,
    required this.name,
    this.price,
    this.imagePath,
    this.images = const [],
    this.description,
    this.stock,
  });

  /// Returns all images available for this variant.
  /// Falls back to [imagePath] if [images] list is empty.
  List<String> get allImages {
    if (images.isNotEmpty) return images;
    if (imagePath != null && imagePath!.isNotEmpty) return [imagePath!];
    return const [];
  }
}

/// Data model representing a merchandise item in the CSShop catalog.
///
/// Kept immutable to ensure predictable state and prevent unintended mutations.
class Product {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  final List<String> images; // optional list of multiple images (e.g. front and back)
  final String category;
  final String description;
  final int soldCount;
  final int stock;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imagePath = '',
    this.images = const [],
    required this.category,
    required this.description,
    required this.soldCount,
    required this.stock,
    this.variants = const [],
  });

  /// Formatted Philippine Peso price string.
  String get formattedPrice => '₱${price.toStringAsFixed(0)}';

  /// Returns all images available for this product.
  List<String> get allImages {
    if (images.isNotEmpty) return images;
    if (imagePath.isNotEmpty) return [imagePath];
    return const [];
  }
}
