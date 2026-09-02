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

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.description,
    required this.soldCount,
    required this.stock,
  });

  /// Formatted Philippine Peso price string.
  String get formattedPrice => '₱${price.toStringAsFixed(0)}';
}
