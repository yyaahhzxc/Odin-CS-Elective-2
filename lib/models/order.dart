import '../theme/app_theme.dart';

/// Represents a single line item snapshot saved within a historical order.
///
/// Conforms to exam specification:
/// "Each saved item keeps a snapshot of the product name and the unit price paid,
/// so past orders stay accurate if prices change or products are removed."
class OrderItemRecord {
  final int id;
  final int orderId;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String imageUrl;

  const OrderItemRecord({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl = '',
  });

  double get subtotal => unitPrice * quantity;
  String get formattedUnitPrice => '₽${AppTheme.formatPrice(unitPrice)}';
  String get formattedSubtotal => '₽${AppTheme.formatPrice(subtotal)}';

  factory OrderItemRecord.fromJson(Map<String, dynamic> json) {
    final productMap = json['products'] as Map<String, dynamic>?;
    final fallbackName = productMap?['name']?.toString() ?? 'PokéMart Item';
    final fallbackImage = productMap?['image_path']?.toString() ??
        productMap?['image_url']?.toString() ??
        '';

    final snapName = json['product_name']?.toString() ?? '';

    return OrderItemRecord(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      productId: json['product_id']?.toString() ?? '',
      productName: snapName.isNotEmpty ? snapName : fallbackName,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['image_url']?.toString() ?? fallbackImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }
}

/// Represents a customer order stored in `public.orders`.
class OrderRecord {
  final int id;
  final String userId;
  final String userEmail;
  final String status; // e.g. 'done', 'pending', 'processing', 'cancelled'
  final double total;
  final DateTime createdAt;
  final List<OrderItemRecord> items;

  const OrderRecord({
    required this.id,
    required this.userId,
    this.userEmail = '',
    required this.status,
    required this.total,
    required this.createdAt,
    this.items = const [],
  });

  String get orderNumber => 'PKM-${id.toString().padLeft(5, '0')}';
  String get formattedTotal => '₽${AppTheme.formatPrice(total)}';

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] as List<dynamic>? ?? const [];
    final parsedItems = rawItems
        .whereType<Map<String, dynamic>>()
        .map(OrderItemRecord.fromJson)
        .toList();

    final profileMap = json['profiles'] as Map<String, dynamic>?;
    final email = profileMap?['email']?.toString() ??
        json['user_email']?.toString() ??
        '';

    return OrderRecord(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: json['user_id']?.toString() ?? '',
      userEmail: email,
      status: json['status']?.toString() ?? 'done',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      items: parsedItems,
    );
  }

  OrderRecord copyWith({
    int? id,
    String? userId,
    String? userEmail,
    String? status,
    double? total,
    DateTime? createdAt,
    List<OrderItemRecord>? items,
  }) {
    return OrderRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      status: status ?? this.status,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

