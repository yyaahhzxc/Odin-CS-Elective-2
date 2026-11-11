import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csshop/main.dart';
import 'package:csshop/services/supabase_service.dart';
import 'package:csshop/state/cart_state.dart';
import 'package:csshop/state/catalog_state.dart';

void main() {
  testWidgets('PokéMart home screen smoke and widget test',
      (WidgetTester tester) async {
    final catalogManager = CatalogManager(service: SupabaseService(null));
    await catalogManager.fetchCatalog();

    await tester.pumpWidget(PokeMartApp(catalogManager: catalogManager));
    await tester.pumpAndSettle();

    // Verify that the store title and PokéMart branding render cleanly
    expect(find.text('POKÉMART', findRichText: true), findsOneWidget);
    expect(find.text('PokéMart - Galar Region Branch'), findsOneWidget);
    expect(find.text('Inventory Items'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });

  testWidgets(
      'Full user flow: Home -> Detail -> Add to Cart -> Cart -> Checkout Confirmation',
      (WidgetTester tester) async {
    // Set surface size to standard phone dimensions
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final catalogManager = CatalogManager(service: SupabaseService(null));
    await catalogManager.fetchCatalog();
    final cartManager = CartManager();

    await tester.pumpWidget(
      PokeMartApp(
        catalogManager: catalogManager,
        cartManager: cartManager,
      ),
    );
    await tester.pumpAndSettle();

    // 1. Navigate to first product details page by tapping a product card (Poké Ball)
    final firstProductCard = find.text('Poké Ball');
    expect(firstProductCard, findsOneWidget);
    await tester.tap(firstProductCard);
    await tester.pumpAndSettle();

    // Verify on Product Details Screen
    expect(find.text('Add to Cart'), findsOneWidget);

    // 2. Add product to cart
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();

    // Verify confirmation banner displays
    expect(find.textContaining('Added 1 × Poké Ball'), findsOneWidget);

    // 3. Navigate to Cart Screen using the AppBar cart icon
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();

    // Verify inside Trainer Cart
    expect(find.text('Shopping Cart'), findsOneWidget);
    expect(find.text('Proceed to Checkout'), findsWidgets);

    // 4. Proceed to Checkout
    await tester.tap(find.text('Proceed to Checkout').first);
    await tester.pumpAndSettle();

    // Verify on Checkout Confirmation Screen with Galar receipt
    expect(find.text('Checkout Confirmation'), findsOneWidget);
    expect(find.text('Order Placed Successfully!'), findsOneWidget);
    expect(find.text('Galar Pokémon Center Mart'), findsOneWidget);
    expect(find.text('Return to PokéMart'), findsOneWidget);
  });
}
