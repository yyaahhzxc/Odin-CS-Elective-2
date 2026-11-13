import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Centralized state manager for the shopping cart.
///
/// Conforms to Exam Cart & Stock Requirements:
/// - Add a product, change its quantity, and remove it.
/// - Show a running total and the item count.
/// - Prevent quantities above available stock, and prevent adding out-of-stock products.
/// - Held in app state, survives screen changes, and is emptied after a successful order and on logout.
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

  /// Clears all items from the cart (on order completion or user logout).
  void clearCart() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}

/// Scoped inherited widget facilitating contextual access to [CartManager].
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
