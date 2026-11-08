import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csshop/main.dart';
import 'package:csshop/state/catalog_state.dart';

void main() {
  group('CatalogManager State Management & Pagination Tests', () {
    test('Initializes with default page 1, 6 products per page, and full price range', () {
      final manager = CatalogManager();

      expect(manager.currentPage, 1);
      expect(manager.pageSize, 6);
      expect(manager.priceRange, const RangeValues(0, 1500));
      expect(manager.selectedCategory, 'All');
      expect(manager.isLoading, false);
      expect(manager.errorMessage, isNull);
    });

    test('Fetches catalog with pagination and verifies page limits', () async {
      final manager = CatalogManager();
      await manager.fetchCatalog();

      expect(manager.products.length, 6);
      expect(manager.totalCount, 18);
      expect(manager.totalPages, 3);
      expect(manager.hasPreviousPage, false);
      expect(manager.hasNextPage, true);

      // Advance to page 2
      manager.nextPage();
      await Future<void>.delayed(Duration.zero);

      expect(manager.currentPage, 2);
      expect(manager.hasPreviousPage, true);
      expect(manager.hasNextPage, true);

      // Advance to page 3 (last page)
      manager.nextPage();
      await Future<void>.delayed(Duration.zero);

      expect(manager.currentPage, 3);
      expect(manager.hasPreviousPage, true);
      expect(manager.hasNextPage, false);

      // Verify cannot exceed upper bound
      manager.nextPage();
      expect(manager.currentPage, 3);

      // Regress back to page 2
      manager.previousPage();
      await Future<void>.delayed(Duration.zero);
      expect(manager.currentPage, 2);
    });

    test('Filters products by price range', () async {
      final manager = CatalogManager();

      // Filter for items between ₱300 and ₱400 (matches CS T-Shirt, CS Jersey, and Cable Organizer)
      manager.setPriceRange(const RangeValues(300, 400));
      await Future<void>.delayed(Duration.zero);

      expect(manager.currentPage, 1);
      expect(manager.products.length, 3);
      expect(manager.totalCount, 3);
      expect(manager.totalPages, 1);
      expect(manager.products.every((p) => p.price >= 300 && p.price <= 400), true);
    });

    test('Filters products by category and resets to page 1', () async {
      final manager = CatalogManager();
      await manager.fetchCatalog();

      // Go to page 2
      manager.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(manager.currentPage, 2);

      // Switch category to 'Apparel'
      manager.setCategory('Apparel');
      await Future<void>.delayed(Duration.zero);

      expect(manager.currentPage, 1);
      expect(manager.selectedCategory, 'Apparel');
      expect(manager.products.every((p) => p.category == 'Apparel'), true);
    });
  });

  group('HomeScreen Price Filter and Pagination Widget Tests', () {
    testWidgets('Renders RangeSlider and pagination footer buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const CSShopApp());
      await tester.pumpAndSettle();

      // Verify Price Range Filter card and RangeSlider
      expect(find.text('Price Range Filter'), findsOneWidget);
      expect(find.byType(RangeSlider), findsOneWidget);

      // Verify pagination bar
      expect(find.text('Previous'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Page 1 of 3'), findsOneWidget);

      // Tap Next page button
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Verify page updated
      expect(find.text('Page 2 of 3'), findsOneWidget);
    });
  });
}
