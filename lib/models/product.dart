import '../theme/app_theme.dart';

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

/// Data model representing a merchandise item in the PokéMart catalog.
///
/// Kept immutable to ensure predictable state and prevent unintended mutations.
class Product {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  final List<String> images;
  final String category;
  final int? categoryId;
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
    this.categoryId,
    required this.description,
    required this.soldCount,
    required this.stock,
    this.variants = const [],
  });

  /// Formatted PokéDollar price string with comma separator.
  String get formattedPrice => '₽${AppTheme.formatPrice(price)}';

  /// Deserializes database record from Supabase table payload.
  /// Supports both `image_path` and `image_url`, and resolves joined `categories(name)`.
  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImage = (json['image_path'] as String?)?.isNotEmpty == true
        ? json['image_path'] as String
        : (json['image_url'] as String? ?? '');

    String resolvedCategory = json['category'] as String? ?? '';
    final joinedCat = json['categories'];
    if (resolvedCategory.isEmpty &&
        joinedCat is Map<String, dynamic> &&
        joinedCat['name'] != null) {
      resolvedCategory = joinedCat['name'].toString();
    }
    if (resolvedCategory.isEmpty) {
      resolvedCategory = 'Poké Balls';
    }

    return Product(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imagePath: rawImage,
      category: resolvedCategory,
      categoryId: (json['category_id'] as num?)?.toInt(),
      description: json['description'] as String? ?? '',
      soldCount: (json['sold_count'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      variants: const [],
    );
  }

  /// Serializes instance into a key-value mapping for Supabase inserts or updates.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_path': imagePath,
      'image_url': imagePath,
      'category': category,
      if (categoryId != null) 'category_id': categoryId,
      'description': description,
      'sold_count': soldCount,
      'stock': stock,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imagePath,
    List<String>? images,
    String? category,
    int? categoryId,
    String? description,
    int? soldCount,
    int? stock,
    List<ProductVariant>? variants,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      images: images ?? this.images,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      soldCount: soldCount ?? this.soldCount,
      stock: stock ?? this.stock,
      variants: variants ?? this.variants,
    );
  }

  /// Returns all images available for this product.
  List<String> get allImages {
    if (images.isNotEmpty) return images;
    if (imagePath.isNotEmpty) return [imagePath];
    return const [];
  }
}
