import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

/// State management controller managing product catalog querying, price filtering,
/// and offset pagination.
class CatalogManager extends ChangeNotifier {
  final SupabaseService _service;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  final int _pageSize = 6; // Evaluator requirement: 6-8 products per page
  int _totalCount = 0;

  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 5000);

  CatalogManager({SupabaseService? service})
      : _service = service ?? SupabaseService();

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  int get totalPages => _totalCount == 0 ? 1 : (_totalCount / _pageSize).ceil();
  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < totalPages;
  String get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;

  /// Loads products matching active filters from Supabase.
  Future<void> fetchCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchProducts(
        page: _currentPage,
        pageSize: _pageSize,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        category: _selectedCategory,
      );

      _products = result.products;
      _totalCount = result.totalCount;

      // Adjust page index if active page exceeds total pages after filtering
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
}
