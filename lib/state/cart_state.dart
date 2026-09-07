import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Centralized state manager for the shopping cart.
///
/// Implemented using [ChangeNotifier] from the Flutter Foundation library,
/// providing reactive state propagation without requiring external third-party packages.
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

  /// Formatted running total string in Philippine Peso with comma separator.
  String get formattedTotal => '₱${AppTheme.formatPrice(totalAmount)}';

  /// Indicates whether the cart is empty.
  bool get isEmpty => _items.isEmpty;

  /// Indicates whether the cart contains at least one item.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Adds a product and chosen variant to the cart, or increases its quantity if already present.
  void addItem(Product product, ProductVariant? variant, int quantity) {
    final compositeId = '${product.id}_${variant?.id ?? 'base'}';
    final existingIndex = _items.indexWhere((item) => item.id == compositeId);

    if (existingIndex >= 0) {
      final item = _items[existingIndex];
      final maxStock = item.availableStock;
      final newQuantity = item.quantity + quantity;
      item.quantity = newQuantity > maxStock ? maxStock : newQuantity;
    } else {
      _items.add(
        CartItem(
          id: compositeId,
          product: product,
          variant: variant,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  /// Increments an existing cart item's quantity by 1 if within stock limits.
  void incrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      final item = _items[index];
      if (item.quantity < item.availableStock) {
        item.quantity++;
        notifyListeners();
      }
    }
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

  /// Clears all items from the cart.
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

/// Scoped inherited widget facilitating contextual access to [CartManager].
///
/// Rebuilds consuming widgets automatically whenever [CartManager] calls [notifyListeners].
class CartScope extends InheritedNotifier<CartManager> {
  const CartScope({
    super.key,
    required CartManager super.notifier,
    required super.child,
  });

  /// Retrieves the [CartManager] instance from the nearest ancestor [CartScope].
  static CartManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'No CartScope found in current widget context.');
    return scope!.notifier!;
  }

  /// Retrieves the [CartManager] instance, or null if none is present.
  static CartManager? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CartScope>()?.notifier;
  }
}
