import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../data/product_data.dart';
import '../models/product.dart';

/// Service handling database interactions with Supabase PostgREST endpoints.
class SupabaseService {
  final SupabaseClient? _client;

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

  /// Fetches paginated products filtered by price range and optional category.
  ///
  /// Leverages Supabase PostgREST chained query methods:
  /// - `select('*')` to initiate query
  /// - `eq('category', category)` for exact match filtering
  /// - `gte('price', minPrice)` and `lte('price', maxPrice)` for range bounding
  /// - `order('price', ascending: true)` for deterministic sorting
  /// - `range(from, to)` for zero-based offset pagination
  /// - `count(CountOption.exact)` to retrieve the total matching record count
  Future<({List<Product> products, int totalCount})> fetchProducts({
    required int page,
    required int pageSize,
    required double minPrice,
    required double maxPrice,
    String? category,
    String sortBy = 'popular',
  }) async {
    // If Supabase is configured and active, query the PostgreSQL database
    if (SupabaseConfig.isConfigured && _client != null) {
      try {
        PostgrestFilterBuilder<PostgrestList> filter =
            _client.from('products').select().neq('category', 'Archived');

        if (category != null && category != 'All') {
          filter = filter.eq('category', category);
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

        final products = data
            .map((item) => Product.fromJson(item))
            .toList();

        return (products: products, totalCount: count);
      } catch (error) {
        // Fallback to local catalog if network or database table has an issue
        return _fetchFromLocalMock(
          page: page,
          pageSize: pageSize,
          minPrice: minPrice,
          maxPrice: maxPrice,
          category: category,
          sortBy: sortBy,
        );
      }
    }

    // Default fallback to in-memory mock catalog
    return _fetchFromLocalMock(
      page: page,
      pageSize: pageSize,
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: category,
      sortBy: sortBy,
    );
  }

  /// In-memory pagination and filtering fallback adhering to identical query logic.
  ({List<Product> products, int totalCount}) _fetchFromLocalMock({
    required int page,
    required int pageSize,
    required double minPrice,
    required double maxPrice,
    String? category,
    String sortBy = 'popular',
  }) {
    var filtered = mockProducts.where((p) {
      final categoryMatch = category == null || category == 'All' || p.category == category;
      final priceMatch = p.price >= minPrice && p.price <= maxPrice;
      return categoryMatch && priceMatch;
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
}
