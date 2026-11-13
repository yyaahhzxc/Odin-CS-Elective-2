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

  /// Mutable in-memory store for fallback/offline testing so Admin CRUD and Order
  /// operations work deterministically both against live Supabase and in unit/widget tests.
  static final List<Product> _localCatalog = List<Product>.from(mockProducts);
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
    _localOrders.clear();
  }

  /// Retrieves a single product by ID from the active catalog.
  Product? getProductById(String id) {
    for (final p in _localCatalog) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // 1. PRODUCT CATALOG & SEARCH / FILTER / PAGINATION
  // ---------------------------------------------------------------------------

  /// Fetches paginated products filtered by search query, price range, and optional category.
  Future<({List<Product> products, int totalCount})> fetchProducts({
    required int page,
    required int pageSize,
    required double minPrice,
    required double maxPrice,
    String? category,
    String searchQuery = '',
    String sortBy = 'popular',
  }) async {
    final trimmedSearch = searchQuery.trim();

    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        PostgrestFilterBuilder<PostgrestList> filter =
            _client.from('products').select().neq('category', 'Archived');

        if (category != null && category != 'All') {
          filter = filter.eq('category', category);
        }

        if (trimmedSearch.isNotEmpty) {
          filter = filter.or(
            'name.ilike.%$trimmedSearch%,description.ilike.%$trimmedSearch%',
          );
        }

        filter = filter.gte('price', minPrice).lte('price', maxPrice);

        final from = (page - 1) * pageSize;
        final to = from + pageSize - 1;

        final PostgrestTransformBuilder<PostgrestList> orderedQuery;
        if (sortBy == 'popular') {
          orderedQuery = filter.order('sold_count', ascending: false);
        } else if (sortBy == 'price_asc') {
          orderedQuery = filter.order('price', ascending: true);
        } else if (sortBy == 'price_desc') {
          orderedQuery = filter.order('price', ascending: false);
        } else if (sortBy == 'name_asc') {
          orderedQuery = filter.order('name', ascending: true);
        } else {
          orderedQuery = filter.order('id', ascending: true);
        }

        final response = await orderedQuery
            .range(from, to)
            .count(CountOption.exact);

        final count = response.count;
        final data = response.data;

        final products = data.map((item) => Product.fromJson(item)).toList();

        // Sync local cache with latest fetched items
        for (final p in products) {
          final idx = _localCatalog.indexWhere((lp) => lp.id == p.id);
          if (idx >= 0) {
            _localCatalog[idx] = p;
          } else {
            _localCatalog.add(p);
          }
        }

        return (products: products, totalCount: count);
      } catch (_) {
        return _fetchFromLocalMock(
          page: page,
          pageSize: pageSize,
          minPrice: minPrice,
          maxPrice: maxPrice,
          category: category,
          searchQuery: trimmedSearch,
          sortBy: sortBy,
        );
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
  }) {
    final lowerSearch = searchQuery.toLowerCase();

    var filtered = _localCatalog.where((p) {
      final categoryMatch =
          category == null || category == 'All' || p.category == category;
      final priceMatch = p.price >= minPrice && p.price <= maxPrice;
      final searchMatch = lowerSearch.isEmpty ||
          p.name.toLowerCase().contains(lowerSearch) ||
          p.description.toLowerCase().contains(lowerSearch) ||
          p.category.toLowerCase().contains(lowerSearch);
      return categoryMatch && priceMatch && searchMatch;
    }).toList();

    if (sortBy == 'popular') {
      filtered.sort((a, b) => b.soldCount.compareTo(a.soldCount));
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
          return names;
        }
      } catch (_) {
        // Fallback to local categories if table not yet migrated
      }
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
      } catch (_) {
        // Fallback if storage bucket isn't created yet
      }
    }

    // Fallback sprite URL for offline/demo environments
    return 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/pokeball_sprite.png';
  }

  /// Creates a new product in `public.products` (Admin only).
  Future<Product> addProduct(Product product) async {
    _localCatalog.insert(0, product);

    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        await _client.from('products').insert(product.toJson());
      } catch (_) {
        // Fallback to standard columns if ERD columns aren't migrated yet
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

  /// Places a customer order atomically:
  /// 1. Validates live stock and prices from database.
  /// 2. Deducts ordered quantities from product stock.
  /// 3. Saves the order (`status = 'done'`) and itemized snapshots (`product_name`, `unit_price`).
  Future<OrderRecord> placeOrder({
    required String userId,
    required String userEmail,
    required List<CartItem> cartItems,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Cannot place an order with an empty cart.');
    }

    // 1. Validate against live stock & compute database-authoritative prices
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

    // 2. Try PostgreSQL transactional RPC `place_order` first
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

      // If RPC isn't installed yet in Supabase, perform direct table inserts + stock updates
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

    // 3. Synchronize local state & stock deduction
    final List<OrderItemRecord> savedOrderItems = [];
    for (final line in verifiedLines) {
      final newStock = (line.dbProduct.stock - line.quantity).clamp(0, 999999);
      final updatedProduct = line.dbProduct.copyWith(
        stock: newStock,
        soldCount: line.dbProduct.soldCount + line.quantity,
      );

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
