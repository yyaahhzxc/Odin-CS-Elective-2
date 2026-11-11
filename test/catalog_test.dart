import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csshop/state/catalog_state.dart';

void main() {
  group('CatalogManager State Management & Pagination Tests', () {
    test('Initializes with default page 1, 6 products per page, and full price range', () {
      final manager = CatalogManager();

      expect(manager.currentPage, 1);
      expect(manager.pageSize, 6);
      expect(manager.priceRange, const RangeValues(0, 5000));
      expect(manager.selectedCategory, 'All');
      expect(manager.isLoading, false);
      expect(manager.errorMessage, isNull);
    });

    test('Fetches catalog with pagination and verifies page limits', () async {
      final manager = CatalogManager();
      await manager.fetchCatalog();

      expect(manager.products.length, 6);
      expect(manager.totalCount, 48);
      expect(manager.totalPages, 8);
      expect(manager.hasPreviousPage, false);
      expect(manager.hasNextPage, true);

      // Advance to page 2
      manager.nextPage();
      await Future<void>.delayed(Duration.zero);

      expect(manager.currentPage, 2);
      expect(manager.hasPreviousPage, true);
      expect(manager.hasNextPage, true);

      // Advance to page 3
      manager.nextPage();
      await Future<void>.delayed(Duration.zero);

      expect(manager.currentPage, 3);
      expect(manager.hasPreviousPage, true);
      expect(manager.hasNextPage, true);

      // Regress back to page 2
      manager.previousPage();
      await Future<void>.delayed(Duration.zero);
      expect(manager.currentPage, 2);
    });

    test('Filters products by category and verifies reactive update', () async {
      final manager = CatalogManager();
      manager.setCategory('Poké Balls');
      await Future<void>.delayed(Duration.zero);

      expect(manager.selectedCategory, 'Poké Balls');
      expect(manager.currentPage, 1);
      expect(manager.totalCount, 6);
      expect(manager.products.every((p) => p.category == 'Poké Balls'), true);
    });

    test('Filters products by price range constraint and resets page index', () async {
      final manager = CatalogManager();
      manager.setPriceRange(const RangeValues(200, 1000));
      await Future<void>.delayed(Duration.zero);

      expect(manager.priceRange, const RangeValues(200, 1000));
      expect(manager.currentPage, 1);
      expect(manager.products.every((p) => p.price >= 200 && p.price <= 1000), true);
    });
  });
}
