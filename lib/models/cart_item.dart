import '../theme/app_theme.dart';
import 'product.dart';

/// Data model representing a line item within the customer's shopping cart.
///
/// Encapsulates the selected base [Product], an optional [ProductVariant],
/// and the active [quantity]. Computes dynamic pricing and subtotals.
class CartItem {
  /// Unique composite identifier differentiating items by product and variant ID.
  final String id;

  /// The underlying product being purchased.
  final Product product;

  /// The specific variant selected (if applicable).
  final ProductVariant? variant;

  /// The quantity of this item added to the cart.
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.variant,
    this.quantity = 1,
  });

  /// Effective unit price taking variant overrides into account.
  double get unitPrice => variant?.price ?? product.price;

  /// Computed subtotal for this line item (unitPrice * quantity).
  double get subtotal => unitPrice * quantity;

  /// Readable display title including the variant name if chosen.
  String get displayName =>
      variant != null ? '${product.name} - ${variant!.name}' : product.name;

  /// Primary image path for the line item (variant image if available, else product image).
  String get imagePath {
    if (variant != null && variant!.allImages.isNotEmpty) {
      return variant!.allImages.first;
    }
    return product.imagePath;
  }

  /// Maximum available inventory for this item / variant.
  int get availableStock => variant?.stock ?? product.stock;

  /// Formatted unit price string in Philippine Peso with comma separator.
  String get formattedUnitPrice => '₱${AppTheme.formatPrice(unitPrice)}';

  /// Computed formatted subtotal string in Philippine Peso with comma separator.
  String get formattedSubtotal => '₱${AppTheme.formatPrice(subtotal)}';
}
