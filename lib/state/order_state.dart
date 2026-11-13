import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/supabase_service.dart';

/// State controller managing customer order checkout, customer order history,
/// and Admin order status management.
class OrderManager extends ChangeNotifier {
  final SupabaseService _service;

  List<OrderRecord> _orders = [];
  OrderRecord? _lastPlacedOrder;
  bool _isLoading = false;
  String? _errorMessage;

  OrderManager({SupabaseService? service})
      : _service = service ?? SupabaseService();

  List<OrderRecord> get orders => List.unmodifiable(_orders);
  OrderRecord? get lastPlacedOrder => _lastPlacedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Places an order atomically in the database, saving the snapshot for the confirmation screen.
  Future<OrderRecord?> placeOrder({
    required String userId,
    required String userEmail,
    required List<CartItem> cartItems,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _service.placeOrder(
        userId: userId,
        userEmail: userEmail,
        cartItems: cartItems,
      );
      _lastPlacedOrder = order;
      _orders = [order, ..._orders.where((o) => o.id != order.id)];
      return order;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads only the customer's own orders, newest first.
  Future<void> fetchCustomerOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _service.fetchCustomerOrders(userId);
    } catch (e) {
      _errorMessage = 'Failed to load order history: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads all orders across customers for the Admin Order List, newest first.
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _service.fetchAllOrders();
    } catch (e) {
      _errorMessage = 'Failed to load admin order list: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an order's status (Admin only).
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateOrderStatus(orderId: orderId, newStatus: newStatus);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        _orders[idx] = _orders[idx].copyWith(status: newStatus);
      }
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Scoped inherited notifier providing [OrderManager] down the widget tree.
class OrderScope extends InheritedNotifier<OrderManager> {
  const OrderScope({
    super.key,
    required OrderManager manager,
    required super.child,
  }) : super(notifier: manager);

  static OrderManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OrderScope>();
    assert(scope != null, 'No OrderScope found in context.');
    return scope!.notifier!;
  }

  static OrderManager? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OrderScope>()?.notifier;
  }
}

