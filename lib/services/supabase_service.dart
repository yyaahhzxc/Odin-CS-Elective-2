import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../data/product_data.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';

/// Service handling database interactions with Supabase PostgREST, RPC, and Storage.
///
/// Conforms to the layered architecture rule:
/// screens call providers, providers call services, and services are the only
/// layer communicating directly with Supabase.
class SupabaseService {
  final SupabaseClient? _client;
  final bool _isMockMode;

  /// Instance cache used solely for fast detail lookup of already-fetched rows.
  final Map<String, Product> _cachedProductsById = {};

  /// In-memory mock stores used exclusively when [_isMockMode] is true (unit/widget tests).
  static final List<Product> _localCatalog = List<Product>.from(mockProducts);
  static final List<CategoryRecord> _localCategories = [
    const CategoryRecord(id: 1, name: 'Poké Balls'),
    const CategoryRecord(id: 2, name: 'Medicine'),
    const CategoryRecord(id: 3, name: 'Evolution'),
    const CategoryRecord(id: 4, name: 'Berries & Treats'),
    const CategoryRecord(id: 5, name: 'Battle & Training'),
    const CategoryRecord(id: 6, name: 'Special Gear'),
  ];
  static final List<OrderRecord> _localOrders = [];
  static int _nextOrderId = 1001;
  static int _nextOrderItemId = 5001;
  static int _nextCategoryId = 7;

  static SupabaseClient? _resolveClient(SupabaseClient? client) {
    if (client != null) return client;
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Creates a [SupabaseService] bound to the active [SupabaseClient] (or mock if uninitialized).
  SupabaseService([SupabaseClient? client])
      : this._fromResolvedClient(_resolveClient(client));

  SupabaseService._fromResolvedClient(this._client)
      : _isMockMode = _client == null;

  /// Creates an isolated in-memory mock [SupabaseService] for tests.
  SupabaseService.mock()
      : _client = null,
        _isMockMode = true;

  bool get _useLiveClient => !_isMockMode && _client != null;

  /// Resets in-memory mock data for clean unit and widget test isolation.
  static void resetMockData() {
    _localCatalog
      ..clear()
      ..addAll(mockProducts);
    _localCategories
      ..clear()
      ..addAll([
        const CategoryRecord(id: 1, name: 'Poké Balls'),
        const CategoryRecord(id: 2, name: 'Medicine'),
        const CategoryRecord(id: 3, name: 'Evolution'),
        const CategoryRecord(id: 4, name: 'Berries & Treats'),
        const CategoryRecord(id: 5, name: 'Battle & Training'),
        const CategoryRecord(id: 6, name: 'Special Gear'),
      ]);
    _localOrders.clear();
    _nextOrderId = 1001;
    _nextOrderItemId = 5001;
    _nextCategoryId = 7;
  }

  /// Clears instance-level product cache (e.g., upon sign-out).
  void clearCache() {
    _cachedProductsById.clear();
  }

  /// Returns a cached product by ID (or from local mock catalog in mock mode).
  Product? getCachedProductById(String id) {
    if (_useLiveClient) {
      return _cachedProductsById[id];
    }
    for (final p in _localCatalog) {
      if (p.id == id) return p;
    }
    return null;
  }

  Exception _mapPostgrestError(PostgrestException e, String fallbackContext) {
    final lower = e.message.toLowerCase();
    if (e.code == '42501' ||
        lower.contains('permission denied') ||
        lower.contains('row-level security')) {
      return Exception('Permission denied: ${e.message}');
    }
    if (e.code == '23505') {
      return Exception('A record with that value already exists: ${e.message}');
    }
    return Exception(e.message.isNotEmpty ? e.message : fallbackContext);
  }

  // ---------------------------------------------------------------------------
  // 1. PRODUCT CATALOG, SEARCH, FILTER & SERVER-SIDE PAGINATION
  // ---------------------------------------------------------------------------

  /// Fetches paginated products filtered by search query, price range, category, and favorites.
  Future<({List<Product> products, int totalCount})> fetchProducts({
    required int page,
    required int pageSize,
    required double minPrice,
    required double maxPrice,
    String? category,
    Set<String> categories = const {},
    String searchQuery = '',
    String sortBy = 'popular',
    Set<String> favoriteIds = const {},
    bool onlyFavorites = false,
  }) async {
    final trimmedSearch = searchQuery.trim();

    if (!_useLiveClient) {
      return _fetchFromLocalMock(
        page: page,
        pageSize: pageSize,
        minPrice: minPrice,
        maxPrice: maxPrice,
        category: category,
        categories: categories,
        searchQuery: trimmedSearch,
        sortBy: sortBy,
        favoriteIds: favoriteIds,
        onlyFavorites: onlyFavorites,
      );
    }

    if (onlyFavorites && favoriteIds.isEmpty) {
      return (products: <Product>[], totalCount: 0);
    }

    try {
      var query = _client!
          .from('products')
          .select('*, categories(id, name)')
          .neq('category', 'Archived')
          .gte('price', minPrice)
          .lte('price', maxPrice);

      if (categories.isNotEmpty) {
        query = query.inFilter('category', categories.toList());
      } else if (category != null && category != 'All') {
        query = query.eq('category', category);
      }

      if (trimmedSearch.isNotEmpty) {
        final safeSearch =
            trimmedSearch.replaceAll(RegExp(r'[,()]'), ' ').trim();
        if (safeSearch.isNotEmpty) {
          query = query.or(
            'name.ilike.%$safeSearch%,description.ilike.%$safeSearch%,category.ilike.%$safeSearch%',
          );
        }
      }

      if (onlyFavorites) {
        query = query.inFilter('id', favoriteIds.toList());
      }

      if (sortBy == 'favorites' && favoriteIds.isNotEmpty) {
        final rows = await query
            .order('sold_count', ascending: false)
            .order('created_at', ascending: false);
        final matched = rows.map(Product.fromJson).toList();
        for (final p in matched) {
          _cachedProductsById[p.id] = p;
        }
        matched.sort((a, b) {
          final aFav = favoriteIds.contains(a.id) ? 0 : 1;
          final bFav = favoriteIds.contains(b.id) ? 0 : 1;
          if (aFav != bFav) return aFav.compareTo(bFav);
          return b.soldCount.compareTo(a.soldCount);
        });
        final totalCount = matched.length;
        final start = (page - 1) * pageSize;
        if (start >= totalCount) {
          return (products: <Product>[], totalCount: totalCount);
        }
        final end = (start + pageSize).clamp(0, totalCount);
        return (products: matched.sublist(start, end), totalCount: totalCount);
      }

      final PostgrestTransformBuilder<PostgrestList> ordered;
      switch (sortBy) {
        case 'price_asc':
          ordered = query
              .order('price', ascending: true)
              .order('name', ascending: true);
          break;
        case 'price_desc':
          ordered = query
              .order('price', ascending: false)
              .order('name', ascending: true);
          break;
        case 'name_asc':
          ordered = query.order('name', ascending: true);
          break;
        case 'popular':
        default:
          ordered = query
              .order('sold_count', ascending: false)
              .order('created_at', ascending: false);
          break;
      }

      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;
      final response = await ordered.range(from, to).count(CountOption.exact);
      final products = response.data.map(Product.fromJson).toList();
      for (final p in products) {
        _cachedProductsById[p.id] = p;
      }
      return (products: products, totalCount: response.count);
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to fetch products.');
    }
  }

  /// Fetches the top popular products from the backend (or mock store).
  Future<List<Product>> fetchPopularProducts({int limit = 6}) async {
    if (!_useLiveClient) {
      final available = List<Product>.from(_localCatalog)
        ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
      return available.take(limit).toList();
    }

    try {
      final rows = await _client!
          .from('products')
          .select('*, categories(id, name)')
          .neq('category', 'Archived')
          .order('sold_count', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);
      final products = rows.map(Product.fromJson).toList();
      for (final p in products) {
        _cachedProductsById[p.id] = p;
      }
      return products;
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to fetch popular products.');
    }
  }

  /// Fetches the highest product price from the database, rounded up to the nearest
  /// 500 when above 5,000.
  Future<double> fetchMaxProductPrice() async {
    if (!_useLiveClient) {
      double maxPrice = 5000.0;
      for (final p in _localCatalog) {
        if (p.price > maxPrice) maxPrice = p.price;
      }
      if (maxPrice > 5000.0) {
        return ((maxPrice / 500.0).ceil() * 500).toDouble();
      }
      return 5000.0;
    }

    try {
      final row = await _client!
          .from('products')
          .select('price')
          .neq('category', 'Archived')
          .order('price', ascending: false)
          .limit(1)
          .maybeSingle();

      final rawMax = (row?['price'] as num?)?.toDouble() ?? 5000.0;
      if (rawMax > 5000.0) {
        return ((rawMax / 500.0).ceil() * 500).toDouble();
      }
      return 5000.0;
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to read catalog price bounds.');
    }
  }

  /// Fetches a single product by ID directly from Supabase (or mock store).
  Future<Product?> fetchProductById(String id) async {
    if (!_useLiveClient) {
      for (final p in _localCatalog) {
        if (p.id == id) return p;
      }
      return null;
    }

    try {
      final row = await _client!
          .from('products')
          .select('*, categories(id, name)')
          .eq('id', id)
          .maybeSingle();
      if (row == null) return null;
      final product = Product.fromJson(row);
      _cachedProductsById[product.id] = product;
      return product;
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to load product details.');
    }
  }

  ({List<Product> products, int totalCount}) _fetchFromLocalMock({
    required int page,
    required int pageSize,
    required double minPrice,
    required double maxPrice,
    String? category,
    Set<String> categories = const {},
    String searchQuery = '',
    String sortBy = 'popular',
    Set<String> favoriteIds = const {},
    bool onlyFavorites = false,
  }) {
    final lowerSearch = searchQuery.toLowerCase();

    var filtered = _localCatalog.where((p) {
      final categoryMatch = categories.isNotEmpty
          ? categories.contains(p.category)
          : (category == null || category == 'All' || p.category == category);
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
    return (
      products: filtered.sublist(startIndex, endIndex),
      totalCount: totalCount,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. ADMIN PRODUCT & CATEGORY CRUD + SUPABASE STORAGE UPLOAD
  // ---------------------------------------------------------------------------

  /// Fetches all product categories ordered by ID.
  Future<List<CategoryRecord>> fetchCategories() async {
    if (!_useLiveClient) {
      return List<CategoryRecord>.unmodifiable(_localCategories);
    }

    try {
      final rows = await _client!
          .from('categories')
          .select('id, name')
          .order('id', ascending: true);
      return rows.map(CategoryRecord.fromJson).toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to fetch categories.');
    }
  }

  /// Creates a new category (Admin only).
  Future<CategoryRecord> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category name is required.');
    }

    if (!_useLiveClient) {
      final existing = _localCategories.where(
        (c) => c.name.toLowerCase() == trimmed.toLowerCase(),
      );
      if (existing.isNotEmpty) {
        return existing.first;
      }
      final created = CategoryRecord(id: _nextCategoryId++, name: trimmed);
      _localCategories.add(created);
      return created;
    }

    try {
      final row = await _client!
          .from('categories')
          .insert({'name': trimmed})
          .select('id, name')
          .single();
      return CategoryRecord.fromJson(row);
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to add category.');
    }
  }

  /// Renames an existing category and synchronizes associated products (Admin only).
  Future<CategoryRecord> updateCategory({
    required int id,
    required String oldName,
    required String newName,
  }) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category name is required.');
    }

    if (!_useLiveClient) {
      final idx = _localCategories.indexWhere((c) => c.id == id);
      if (idx < 0) {
        throw Exception('Category not found.');
      }
      final updated = _localCategories[idx].copyWith(name: trimmed);
      _localCategories[idx] = updated;
      for (var i = 0; i < _localCatalog.length; i++) {
        if (_localCatalog[i].categoryId == id ||
            _localCatalog[i].category == oldName) {
          _localCatalog[i] = _localCatalog[i].copyWith(
            category: trimmed,
            categoryId: id,
          );
        }
      }
      return updated;
    }

    try {
      final row = await _client!
          .from('categories')
          .update({'name': trimmed})
          .eq('id', id)
          .select('id, name')
          .maybeSingle();

      if (row == null) {
        throw Exception('Permission denied: unable to update category.');
      }

      await _client
          .from('products')
          .update({'category': trimmed, 'category_id': id})
          .eq('category_id', id);
      await _client
          .from('products')
          .update({'category': trimmed, 'category_id': id})
          .eq('category', oldName);

      return CategoryRecord.fromJson(row);
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to update category.');
    }
  }

  /// Deletes a category by ID (Admin only).
  Future<void> deleteCategory(int id) async {
    if (!_useLiveClient) {
      _localCategories.removeWhere((c) => c.id == id);
      return;
    }

    try {
      final deleted = await _client!
          .from('categories')
          .delete()
          .eq('id', id)
          .select('id');
      if (deleted.isEmpty) {
        throw Exception('Permission denied: unable to delete category.');
      }
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to delete category.');
    }
  }

  String _inferContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.gif')) {
      return 'image/gif';
    }
    return 'image/png';
  }

  /// Uploads a product image to Supabase Storage bucket `product-images`
  /// and returns its public URL.
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final safeName =
        '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';

    if (!_useLiveClient) {
      return 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/pokeball_sprite.png';
    }

    try {
      await _client!.storage.from('product-images').uploadBinary(
            safeName,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _inferContentType(fileName),
            ),
          );
      return _client.storage.from('product-images').getPublicUrl(safeName);
    } on StorageException catch (e) {
      throw Exception('Image upload failed: ${e.message}');
    }
  }

  Future<int?> _resolveCategoryId(String categoryName) async {
    if (!_useLiveClient) {
      for (final c in _localCategories) {
        if (c.name == categoryName) return c.id;
      }
      return null;
    }
    final row = await _client!
        .from('categories')
        .select('id')
        .eq('name', categoryName)
        .maybeSingle();
    return (row?['id'] as num?)?.toInt();
  }

  /// Creates a new product in `public.products` (Admin only).
  Future<Product> addProduct(Product product) async {
    if (!_useLiveClient) {
      _localCatalog.removeWhere((p) => p.id == product.id);
      _localCatalog.insert(0, product);
      if (!_localCategories.any((c) => c.name == product.category)) {
        _localCategories.add(
          CategoryRecord(id: _nextCategoryId++, name: product.category),
        );
      }
      return product;
    }

    try {
      final resolvedCategoryId =
          product.categoryId ?? await _resolveCategoryId(product.category);
      final payload = product.copyWith(categoryId: resolvedCategoryId).toJson();

      final row = await _client!
          .from('products')
          .insert(payload)
          .select('*, categories(id, name)')
          .single();
      final created = Product.fromJson(row);
      _cachedProductsById[created.id] = created;
      return created;
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to add product.');
    }
  }

  /// Updates an existing product in `public.products` (Admin only).
  Future<Product> updateProduct(Product product) async {
    if (!_useLiveClient) {
      final idx = _localCatalog.indexWhere((p) => p.id == product.id);
      if (idx >= 0) {
        _localCatalog[idx] = product;
      } else {
        _localCatalog.insert(0, product);
      }
      return product;
    }

    try {
      final resolvedCategoryId =
          await _resolveCategoryId(product.category) ?? product.categoryId;
      final payload = product.copyWith(categoryId: resolvedCategoryId).toJson();
      payload.remove('id');

      final row = await _client!
          .from('products')
          .update(payload)
          .eq('id', product.id)
          .select('*, categories(id, name)')
          .maybeSingle();

      if (row == null) {
        throw Exception('Permission denied: unable to update product.');
      }

      final updated = Product.fromJson(row);
      _cachedProductsById[updated.id] = updated;
      return updated;
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to update product.');
    }
  }

  /// Deletes a product by ID from `public.products` (Admin only).
  Future<void> deleteProduct(String productId) async {
    if (!_useLiveClient) {
      _localCatalog.removeWhere((p) => p.id == productId);
      return;
    }

    try {
      final deleted = await _client!
          .from('products')
          .delete()
          .eq('id', productId)
          .select('id');
      if (deleted.isEmpty) {
        throw Exception('Permission denied: unable to delete product.');
      }
      _cachedProductsById.remove(productId);
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to delete product.');
    }
  }

  // ---------------------------------------------------------------------------
  // 3. ATOMIC CHECKOUT & ORDER MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Places a customer order atomically via the database `place_order` RPC.
  Future<OrderRecord> placeOrder({
    required String userId,
    required String userEmail,
    required List<CartItem> cartItems,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Cannot place an order with an empty cart.');
    }

    if (!_useLiveClient) {
      return _placeMockOrder(
        userId: userId,
        userEmail: userEmail,
        cartItems: cartItems,
      );
    }

    final qtyByProductId = <String, int>{};
    for (final item in cartItems) {
      qtyByProductId[item.product.id] =
          (qtyByProductId[item.product.id] ?? 0) + item.quantity;
    }
    final payload = qtyByProductId.entries
        .map((e) => {'product_id': e.key, 'quantity': e.value})
        .toList();

    try {
      final rpcResult = await _client!.rpc(
        'place_order',
        params: {'p_items': payload},
      );

      if (rpcResult is Map<String, dynamic>) {
        final orderId = (rpcResult['order_id'] as num?)?.toInt();
        final rawItems = rpcResult['items'];
        if (orderId != null && rawItems is List) {
          final items = rawItems
              .whereType<Map<String, dynamic>>()
              .map(OrderItemRecord.fromJson)
              .toList();
          final createdAtRaw = rpcResult['created_at']?.toString();
          return OrderRecord(
            id: orderId,
            userId: userId,
            userEmail: userEmail,
            status: rpcResult['status']?.toString() ?? 'done',
            total: (rpcResult['total'] as num?)?.toDouble() ?? 0.0,
            createdAt: createdAtRaw != null
                ? (DateTime.tryParse(createdAtRaw) ?? DateTime.now())
                : DateTime.now(),
            items: items,
          );
        }

        if (orderId != null) {
          final orderRow = await _client
              .from('orders')
              .select('*, order_items(*, products(name, image_path))')
              .eq('id', orderId)
              .single();
          return OrderRecord.fromJson(orderRow).copyWith(userEmail: userEmail);
        }
      }

      throw Exception('Unexpected checkout response from server.');
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to place order.');
    }
  }

  OrderRecord _placeMockOrder({
    required String userId,
    required String userEmail,
    required List<CartItem> cartItems,
  }) {
    double verifiedTotal = 0.0;
    final List<({Product dbProduct, int quantity})> verifiedLines = [];

    for (final cartItem in cartItems) {
      Product? dbProduct = getCachedProductById(cartItem.product.id);
      dbProduct ??= cartItem.product;

      if (dbProduct.stock < cartItem.quantity) {
        throw Exception(
          'Insufficient stock for ${dbProduct.name} (Available: ${dbProduct.stock}, Requested: ${cartItem.quantity}).',
        );
      }

      verifiedTotal += dbProduct.price * cartItem.quantity;
      verifiedLines.add((dbProduct: dbProduct, quantity: cartItem.quantity));
    }

    final assignedOrderId = _nextOrderId++;
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
    if (!_useLiveClient) {
      final local = _localOrders
          .where((o) => o.userId == userId || userId.isEmpty)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return local;
    }

    try {
      final rows = await _client!
          .from('orders')
          .select('*, order_items(*, products(name, image_path))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return rows.map(OrderRecord.fromJson).toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to load order history.');
    }
  }

  /// Fetches all customer orders for the Admin Order List screen, newest first.
  Future<List<OrderRecord>> fetchAllOrders() async {
    if (!_useLiveClient) {
      final all = List<OrderRecord>.from(_localOrders)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all;
    }

    try {
      final rows = await _client!
          .from('orders')
          .select('*, order_items(*, products(name, image_path))')
          .order('created_at', ascending: false);

      final remoteOrders = rows.map(OrderRecord.fromJson).toList();
      if (remoteOrders.isEmpty) {
        return remoteOrders;
      }

      final userIds = remoteOrders
          .map((o) => o.userId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (userIds.isEmpty) {
        return remoteOrders;
      }

      try {
        final profiles = await _client
            .from('profiles')
            .select('id, email, username, firstname, lastname')
            .inFilter('id', userIds);

        final labelByUserId = <String, String>{};
        for (final p in profiles) {
          final uid = p['id']?.toString() ?? '';
          if (uid.isEmpty) continue;
          final email = p['email']?.toString().trim() ?? '';
          final username = p['username']?.toString().trim() ?? '';
          final fullName = [
            p['firstname']?.toString().trim() ?? '',
            p['lastname']?.toString().trim() ?? '',
          ].where((s) => s.isNotEmpty).join(' ');

          final label = email.isNotEmpty
              ? email
              : (username.isNotEmpty ? '@$username' : fullName);
          if (label.isNotEmpty) {
            labelByUserId[uid] = label;
          }
        }

        return remoteOrders
            .map(
              (order) => order.userEmail.isEmpty &&
                      labelByUserId.containsKey(order.userId)
                  ? order.copyWith(userEmail: labelByUserId[order.userId])
                  : order,
            )
            .toList();
      } catch (_) {
        return remoteOrders;
      }
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to load admin orders.');
    }
  }

  /// Updates an order's status (Admin only).
  Future<void> updateOrderStatus({
    required int orderId,
    required String newStatus,
  }) async {
    if (!_useLiveClient) {
      final idx = _localOrders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        _localOrders[idx] = _localOrders[idx].copyWith(status: newStatus);
      }
      return;
    }

    try {
      final updated = await _client!
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId)
          .select('id');
      if (updated.isEmpty) {
        throw Exception('Permission denied: unable to update order status.');
      }
    } on PostgrestException catch (e) {
      throw _mapPostgrestError(e, 'Failed to update order status.');
    }
  }
}
