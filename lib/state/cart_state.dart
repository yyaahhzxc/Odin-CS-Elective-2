import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Centralized state manager for the shopping cart.
///
/// Supports adding products, updating quantities within available stock limits,
/// computing running totals and item counts, and clearing on checkout or sign-out.
class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// Read-only snapshot of current cart items.
  List<CartItem> get items => List.unmodifiable(_items);

  /// Cumulative count of all units currently in the cart.
  int get totalItemCount =>
      _items.fold(0, (total, item) => total + item.quantity);

  /// Running total price for all cart items.
  double get totalAmount =>
      _items.fold(0.0, (total, item) => total + item.subtotal);

  /// Formatted running total string in PokéDollars with comma separator.
  String get formattedTotal => '₽${AppTheme.formatPrice(totalAmount)}';

  /// Indicates whether the cart is empty.
  bool get isEmpty => _items.isEmpty;

  /// Indicates whether the cart contains at least one item.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Returns the total quantity of a specific product currently in the cart.
  int quantityOf(Product product) {
    return _items
        .where((item) => item.product.id == product.id)
        .fold(0, (total, item) => total + item.quantity);
  }

  /// Returns the exact cart quantity for a specific product and optional variant.
  int quantityOfVariant(Product product, ProductVariant? variant) {
    final compositeId = '${product.id}_${variant?.id ?? 'base'}';
    for (final item in _items) {
      if (item.id == compositeId) {
        return item.quantity;
      }
    }
    return 0;
  }

  /// Increments the base product's quantity in the cart by 1 (or adds it with quantity 1).
  bool incrementProduct(Product product) {
    return addItem(product, null, 1);
  }

  /// Decrements the base product's quantity in the cart by 1, removing it when reaching 0.
  void decrementProduct(Product product) {
    final compositeId = '${product.id}_base';
    final index = _items.indexWhere(
      (item) => item.id == compositeId || item.product.id == product.id,
    );
    if (index >= 0) {
      decrementQuantity(_items[index].id);
    }
  }

  /// Adds a product and chosen variant to the cart, or increases its quantity if already present.
  /// Strictly prevents adding out-of-stock products (`availableStock <= 0`) and caps at `availableStock`.
  bool addItem(Product product, ProductVariant? variant, int quantity) {
    final availableStock = variant?.stock ?? product.stock;
    if (availableStock <= 0 || quantity <= 0) {
      return false;
    }

    final compositeId = '${product.id}_${variant?.id ?? 'base'}';
    final existingIndex = _items.indexWhere((item) => item.id == compositeId);

    if (existingIndex >= 0) {
      final item = _items[existingIndex];
      final maxStock = item.availableStock;
      if (item.quantity >= maxStock) {
        return false;
      }
      final newQuantity = item.quantity + quantity;
      item.quantity = newQuantity > maxStock ? maxStock : newQuantity;
    } else {
      final clampedQty =
          quantity > availableStock ? availableStock : quantity;
      _items.add(
        CartItem(
          id: compositeId,
          product: product,
          variant: variant,
          quantity: clampedQty,
        ),
      );
    }
    notifyListeners();
    return true;
  }

  /// Increments an existing cart item's quantity by 1 if within stock limits.
  bool incrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      final item = _items[index];
      if (item.quantity < item.availableStock) {
        item.quantity++;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Decrements an item's quantity by 1, automatically removing it if quantity drops below 1.
  void decrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      final item = _items[index];
      if (item.quantity > 1) {
        item.quantity--;
        notifyListeners();
      } else {
        _items.removeAt(index);
        notifyListeners();
      }
    }
  }

  /// Explicitly removes an item from the cart.
  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  /// Removes all cart entries belonging to [productId] (e.g., when deleted by Admin).
  void removeProductById(String productId) {
    final before = _items.length;
    _items.removeWhere((item) => item.product.id == productId);
    if (_items.length != before) {
      notifyListeners();
    }
  }

  /// Clears all items from the cart (on order completion or user logout).
  void clearCart() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
