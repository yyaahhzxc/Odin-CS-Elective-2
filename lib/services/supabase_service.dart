import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../data/product_data.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

/// Service handling database interactions with Supabase PostgREST, RPC, and Storage endpoints.
///
/// Conforms to the Exam Architecture Rule:
/// "Use layers: screens call providers, providers call services (or repositories),
/// and services are the only code that talks to Supabase."
class SupabaseService {
  final SupabaseClient? _client;

  /// Mutable in-memory store and overlay tracking Admin CRUD and Order mutations
  /// so new/edited/deleted products reflect immediately in the UI and across pagination.
  static final List<Product> _localCatalog = List<Product>.from(mockProducts);
  static final List<Product> _adminAddedProducts = [];
  static final Map<String, Product> _adminUpdatedProducts = {};
  static final Set<String> _adminDeletedIds = {};

  static final List<String> _localCategories = [
    'Poké Balls',
    'Medicine',
    'Evolution',
    'Berries & Treats',
    'Battle & Training',
    'Special Gear',
  ];
  static final List<OrderRecord> _localOrders = [];
  static int _nextOrderId = 1001;
  static int _nextOrderItemId = 5001;

  static SupabaseClient? _resolveClient(SupabaseClient? client) {
    if (client != null) return client;
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseService([SupabaseClient? client])
      : _client = _resolveClient(client);

  /// Resets in-memory mock data for clean unit test isolation.
  static void resetMockData() {
    _localCatalog
      ..clear()
      ..addAll(mockProducts);
    _adminAddedProducts.clear();
    _adminUpdatedProducts.clear();
    _adminDeletedIds.clear();
    _localOrders.clear();
  }

  /// Retrieves a single product by ID from the active catalog.
  Product? getProductById(String id) {
    if (_adminDeletedIds.contains(id)) return null;
    if (_adminUpdatedProducts.containsKey(id)) {
      return _adminUpdatedProducts[id];
    }
    for (final p in _adminAddedProducts) {
      if (p.id == id) return p;
    }
    for (final p in _localCatalog) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Returns the top most popular products (plus any newly added Admin products)
  /// independent of active catalog search/filter/pagination state.
  List<Product> getTopPopularProducts({int limit = 6}) {
    final adminAddedIds = _adminAddedProducts.map((p) => p.id).toSet();
    final available = _localCatalog
        .where((p) => !_adminDeletedIds.contains(p.id))
        .toList();

    available.sort((a, b) {
      final aNew = adminAddedIds.contains(a.id) ? 0 : 1;
      final bNew = adminAddedIds.contains(b.id) ? 0 : 1;
      if (aNew != bNew) return aNew.compareTo(bNew);
      return b.soldCount.compareTo(a.soldCount);
    });

    return available.take(limit).toList();
  }

  // ---------------------------------------------------------------------------
  // 1. PRODUCT CATALOG & SEARCH / FILTER / PAGINATION
  // ---------------------------------------------------------------------------

  /// Fetches paginated products filtered by search query, price range, category, and favorites.
  Future<({List<Product> products, int totalCount})> fetchProducts({
    required int page,
    required int pageSize,
    required double minPrice,
    required double maxPrice,
    String? category,
    String searchQuery = '',
    String sortBy = 'popular',
    Set<String> favoriteIds = const {},
    bool onlyFavorites = false,
  }) async {
    final trimmedSearch = searchQuery.trim();

    // When filtering by local favorites or sorting by favorites, or after local Admin mutations,
    // synchronize with Supabase first (if configured) so _localCatalog has all remote rows,
    // then apply unified filtering & sorting so Admin additions always reflect immediately.
    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        final rows = await _client
            .from('products')
            .select()
            .neq('category', 'Archived');

        final remoteProducts =
            rows.map((item) => Product.fromJson(item)).toList();

        if (remoteProducts.isNotEmpty) {
          final merged = <Product>[];
          final seenIds = <String>{};

          // Keep newly added admin products at the front
          for (final added in _adminAddedProducts) {
            if (!_adminDeletedIds.contains(added.id)) {
              final effective = _adminUpdatedProducts[added.id] ?? added;
              merged.add(effective);
              seenIds.add(effective.id);
            }
          }

          for (final rp in remoteProducts) {
            if (_adminDeletedIds.contains(rp.id) || seenIds.contains(rp.id)) {
              continue;
            }
            final effective = _adminUpdatedProducts[rp.id] ?? rp;
            merged.add(effective);
            seenIds.add(effective.id);
          }

          _localCatalog
            ..clear()
            ..addAll(merged);
        }
      } catch (_) {
        // Fallback to existing _localCatalog if offline
      }
    }

    return _fetchFromLocalMock(
      page: page,
      pageSize: pageSize,
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: category,
      searchQuery: trimmedSearch,
      sortBy: sortBy,
      favoriteIds: favoriteIds,
      onlyFavorites: onlyFavorites,
    );
  }

  ({List<Product> products, int totalCount}) _fetchFromLocalMock({
    required int page,
    required int pageSize,
    required double minPrice,
    required double maxPrice,
    String? category,
    String searchQuery = '',
    String sortBy = 'popular',
    Set<String> favoriteIds = const {},
    bool onlyFavorites = false,
  }) {
    final lowerSearch = searchQuery.toLowerCase();
    final adminAddedIds = _adminAddedProducts.map((p) => p.id).toSet();

    var filtered = _localCatalog.where((p) {
      if (_adminDeletedIds.contains(p.id)) return false;
      final categoryMatch =
          category == null || category == 'All' || p.category == category;
      final priceMatch = p.price >= minPrice && p.price <= maxPrice;
      final searchMatch = lowerSearch.isEmpty ||
          p.name.toLowerCase().contains(lowerSearch) ||
          p.description.toLowerCase().contains(lowerSearch) ||
          p.category.toLowerCase().contains(lowerSearch);
      final favMatch = !onlyFavorites || favoriteIds.contains(p.id);
      return categoryMatch && priceMatch && searchMatch && favMatch;
    }).toList();

    if (sortBy == 'favorites') {
      filtered.sort((a, b) {
        final aFav = favoriteIds.contains(a.id) ? 0 : 1;
        final bFav = favoriteIds.contains(b.id) ? 0 : 1;
        if (aFav != bFav) return aFav.compareTo(bFav);
        return b.soldCount.compareTo(a.soldCount);
      });
    } else if (sortBy == 'popular') {
      filtered.sort((a, b) {
        // Keep newly added Admin items pinned at the top of Popular so they are immediately visible
        final aNew = adminAddedIds.contains(a.id) ? 0 : 1;
        final bNew = adminAddedIds.contains(b.id) ? 0 : 1;
        if (aNew != bNew) return aNew.compareTo(bNew);
        return b.soldCount.compareTo(a.soldCount);
      });
    } else if (sortBy == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'price_desc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'name_asc') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    final totalCount = filtered.length;
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= totalCount) {
      return (products: <Product>[], totalCount: totalCount);
    }

    final endIndex = (startIndex + pageSize).clamp(0, totalCount);
    final pageProducts = filtered.sublist(startIndex, endIndex);

    return (products: pageProducts, totalCount: totalCount);
  }

  // ---------------------------------------------------------------------------
  // 2. ADMIN PRODUCT & CATEGORY CRUD + SUPABASE STORAGE UPLOAD
  // ---------------------------------------------------------------------------

  /// Fetches all available product categories.
  Future<List<String>> fetchCategories() async {
    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        final rows = await _client
            .from('categories')
            .select('name')
            .order('id', ascending: true);
        final names = rows
            .map((r) => r['name']?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .toList();
        if (names.isNotEmpty) {
          for (final n in names) {
            if (!_localCategories.contains(n)) {
              _localCategories.add(n);
            }
          }
          return List<String>.unmodifiable(_localCategories);
        }
      } catch (_) {}
    }
    return List<String>.unmodifiable(_localCategories);
  }

  /// Adds a new category (Admin only).
  Future<void> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    if (!_localCategories.contains(trimmed)) {
      _localCategories.add(trimmed);
    }

    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        await _client.from('categories').upsert(
          {'name': trimmed},
          onConflict: 'name',
        );
      } catch (_) {}
    }
  }

  /// Uploads a product image to Supabase Storage bucket `product-images`
  /// and returns its public URL.
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final safeName =
        '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';

    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        await _client.storage.from('product-images').uploadBinary(
              safeName,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
        return _client.storage.from('product-images').getPublicUrl(safeName);
      } catch (_) {}
    }

    return 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/pokeball_sprite.png';
  }

  /// Creates a new product in `public.products` (Admin only).
  Future<Product> addProduct(Product product) async {
    _adminDeletedIds.remove(product.id);
    _adminAddedProducts.removeWhere((p) => p.id == product.id);
    _adminAddedProducts.insert(0, product);
    _localCatalog.removeWhere((p) => p.id == product.id);
    _localCatalog.insert(0, product);

    if (! _localCategories.contains(product.category)) {
      _localCategories.add(product.category);
    }

    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        await _client.from('products').insert(product.toJson());
      } catch (_) {
        try {
          await _client.from('products').insert({
            'id': product.id,
            'name': product.name,
            'price': product.price,
            'image_path': product.imagePath,
            'category': product.category,
            'description': product.description,
            'sold_count': product.soldCount,
            'stock': product.stock,
          });
        } catch (_) {}
      }
    }
    return product;
  }

  /// Updates an existing product in `public.products` (Admin only).
  Future<Product> updateProduct(Product product) async {
    _adminUpdatedProducts[product.id] = product;
    final addedIdx =
        _adminAddedProducts.indexWhere((p) => p.id == product.id);
    if (addedIdx >= 0) {
      _adminAddedProducts[addedIdx] = product;
    }

    final idx = _localCatalog.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _localCatalog[idx] = product;
    } else {
      _localCatalog.insert(0, product);
    }

    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        await _client
            .from('products')
            .update(product.toJson())
            .eq('id', product.id);
      } catch (_) {
        try {
          await _client.from('products').update({
            'name': product.name,
            'price': product.price,
            'image_path': product.imagePath,
            'category': product.category,
            'description': product.description,
            'stock': product.stock,
          }).eq('id', product.id);
        } catch (_) {}
      }
    }
    return product;
  }

  /// Deletes a product by ID from `public.products` (Admin only).
  Future<void> deleteProduct(String productId) async {
    _adminDeletedIds.add(productId);
    _adminAddedProducts.removeWhere((p) => p.id == productId);
    _adminUpdatedProducts.remove(productId);
    _localCatalog.removeWhere((p) => p.id == productId);

    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        await _client.from('products').delete().eq('id', productId);
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // 3. ATOMIC CHECKOUT & ORDER MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Places a customer order atomically.
  Future<OrderRecord> placeOrder({
    required String userId,
    required String userEmail,
    required List<CartItem> cartItems,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Cannot place an order with an empty cart.');
    }

    double verifiedTotal = 0.0;
    final List<({Product dbProduct, int quantity})> verifiedLines = [];

    for (final cartItem in cartItems) {
      Product? dbProduct = getProductById(cartItem.product.id);

      if (SupabaseConfig.isConfigured && _client != null) {
        try {
          final row = await _client
              .from('products')
              .select()
              .eq('id', cartItem.product.id)
              .maybeSingle();
          if (row != null) {
            dbProduct = Product.fromJson(row);
          }
        } catch (_) {}
      }

      dbProduct ??= cartItem.product;

      if (dbProduct.stock < cartItem.quantity) {
        throw Exception(
          'Insufficient stock for ${dbProduct.name} (Available: ${dbProduct.stock}, Requested: ${cartItem.quantity}).',
        );
      }

      verifiedTotal += dbProduct.price * cartItem.quantity;
      verifiedLines.add((dbProduct: dbProduct, quantity: cartItem.quantity));
    }

    int assignedOrderId = _nextOrderId++;

    if (SupabaseConfig.isConfigured && _client != null) {
      bool rpcSucceeded = false;
      try {
        final payload = verifiedLines
            .map((line) => {
                  'product_id': line.dbProduct.id,
                  'quantity': line.quantity,
                })
            .toList();

        final rpcResult = await _client.rpc(
          'place_order',
          params: {'p_items': payload},
        );

        if (rpcResult is Map<String, dynamic>) {
          assignedOrderId =
              (rpcResult['order_id'] as num?)?.toInt() ?? assignedOrderId;
          verifiedTotal =
              (rpcResult['total'] as num?)?.toDouble() ?? verifiedTotal;
          rpcSucceeded = true;
        }
      } catch (e) {
        if (e.toString().contains('Insufficient stock')) {
          rethrow;
        }
      }

      if (!rpcSucceeded) {
        try {
          final orderInsert = await _client
              .from('orders')
              .insert({
                'user_id': userId,
                'status': 'done',
                'total': verifiedTotal,
              })
              .select('id')
              .maybeSingle();

          if (orderInsert != null && orderInsert['id'] != null) {
            assignedOrderId = (orderInsert['id'] as num).toInt();
          }

          for (final line in verifiedLines) {
            final newStock =
                (line.dbProduct.stock - line.quantity).clamp(0, 999999);
            final newSold = line.dbProduct.soldCount + line.quantity;

            await _client.from('products').update({
              'stock': newStock,
              'sold_count': newSold,
            }).eq('id', line.dbProduct.id);

            await _client.from('order_items').insert({
              'order_id': assignedOrderId,
              'product_id': line.dbProduct.id,
              'product_name': line.dbProduct.name,
              'unit_price': line.dbProduct.price,
              'quantity': line.quantity,
            });
          }
        } catch (_) {}
      }
    }

    final List<OrderItemRecord> savedOrderItems = [];
    for (final line in verifiedLines) {
      final newStock = (line.dbProduct.stock - line.quantity).clamp(0, 999999);
      final updatedProduct = line.dbProduct.copyWith(
        stock: newStock,
        soldCount: line.dbProduct.soldCount + line.quantity,
      );

      _adminUpdatedProducts[updatedProduct.id] = updatedProduct;
      final localIdx =
          _localCatalog.indexWhere((p) => p.id == line.dbProduct.id);
      if (localIdx >= 0) {
        _localCatalog[localIdx] = updatedProduct;
      }

      savedOrderItems.add(
        OrderItemRecord(
          id: _nextOrderItemId++,
          orderId: assignedOrderId,
          productId: line.dbProduct.id,
          productName: line.dbProduct.name,
          unitPrice: line.dbProduct.price,
          quantity: line.quantity,
          imageUrl: line.dbProduct.imagePath,
        ),
      );
    }

    final createdOrder = OrderRecord(
      id: assignedOrderId,
      userId: userId,
      userEmail: userEmail,
      status: 'done',
      total: verifiedTotal,
      createdAt: DateTime.now(),
      items: savedOrderItems,
    );

    _localOrders.insert(0, createdOrder);
    return createdOrder;
  }

  /// Fetches orders belonging to a specific customer, newest first.
  Future<List<OrderRecord>> fetchCustomerOrders(String userId) async {
    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        final rows = await _client
            .from('orders')
            .select('*, order_items(*, products(name, image_path))')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        final remoteOrders = rows.map(OrderRecord.fromJson).toList();
        if (remoteOrders.isNotEmpty) {
          return remoteOrders;
        }
      } catch (_) {}
    }

    final local = _localOrders
        .where((o) => o.userId == userId || userId.isEmpty)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return local;
  }

  /// Fetches all customer orders for the Admin Order List screen, newest first.
  Future<List<OrderRecord>> fetchAllOrders() async {
    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        final rows = await _client
            .from('orders')
            .select('*, order_items(*, products(name, image_path))')
            .order('created_at', ascending: false);

        final remoteOrders = rows.map(OrderRecord.fromJson).toList();
        if (remoteOrders.isNotEmpty) {
          return remoteOrders;
        }
      } catch (_) {}
    }

    final all = List<OrderRecord>.from(_localOrders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  /// Updates an order's status (Admin only).
  Future<void> updateOrderStatus({
    required int orderId,
    required String newStatus,
  }) async {
    final idx = _localOrders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _localOrders[idx] = _localOrders[idx].copyWith(status: newStatus);
    }

    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        await _client
            .from('orders')
            .update({'status': newStatus})
            .eq('id', orderId);
      } catch (_) {}
    }
  }
}
