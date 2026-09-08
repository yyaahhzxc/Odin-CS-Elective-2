import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csshop/main.dart';
import 'package:csshop/data/product_data.dart';

void main() {
  testWidgets('CSShop home screen smoke and widget test',
      (WidgetTester tester) async {
    // Build the CSShop application and trigger a frame
    await tester.pumpWidget(const CSShopApp());
    await tester.pumpAndSettle();

    // Verify that the store title and AppBar render cleanly
    expect(find.text('CSShop'), findsOneWidget);
    expect(find.text('CSShop - The CSSEC Merch Store'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });

  testWidgets(
      'Full user flow: Home -> Detail -> Add to Cart -> Cart -> Checkout Confirmation',
      (WidgetTester tester) async {
    // Set surface size to standard phone dimensions
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CSShopApp());
    await tester.pumpAndSettle();

    // 1. Navigate to first product details page by tapping a product card
    final firstProductCard = find.text('CS T-Shirt');
    expect(firstProductCard, findsOneWidget);
    await tester.tap(firstProductCard);
    await tester.pumpAndSettle();

    // Verify on Product Details Screen
    expect(find.text('Add to Cart'), findsOneWidget);

    // 2. Add product to cart
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();

    // Verify top confirmation banner displays smoothly and quantity resets to 1
    expect(find.textContaining('Added 1 × CS T-Shirt'), findsOneWidget);

    // 3. Navigate to Cart Screen using the AppBar shopping cart icon
    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();

    // Verify on Shopping Cart Screen
    expect(find.text('Shopping Cart'), findsOneWidget);
    expect(find.text('Subtotal: ₱350'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    // Test Stateful quantity control: tap '+' to increment to 2
    final plusButton = find.byIcon(Icons.add);
    expect(plusButton, findsOneWidget);
    await tester.tap(plusButton);
    await tester.pumpAndSettle();

    // Running total updates live to ₱700 (2 * 350)
    expect(find.text('Subtotal: ₱700'), findsOneWidget);

    // Test removal dialog: decrement twice to reach 0
    final minusButton = find.byIcon(Icons.remove);
    expect(minusButton, findsOneWidget);
    await tester.tap(minusButton); // 2 -> 1
    await tester.pumpAndSettle();
    expect(find.text('Subtotal: ₱350'), findsOneWidget);

    await tester.tap(minusButton); // 1 -> 0 triggers confirmation dialog
    await tester.pumpAndSettle();

    // Verify removal confirmation dialog appears
    expect(find.text('Remove Item'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Cancel removal dialog to keep item
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Increment back to 2 for checkout
    await tester.tap(plusButton);
    await tester.pumpAndSettle();
    expect(find.text('Subtotal: ₱700'), findsOneWidget);

    // 4. Tap checkout button
    expect(find.text('Proceed to Checkout'), findsOneWidget);
    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();

    // 5. Verify Checkout Confirmation Screen
    expect(find.text('Checkout Confirmation'), findsOneWidget);
    expect(find.text('Order Placed Successfully!'), findsOneWidget);
    expect(find.text('Total Amount Paid:'), findsOneWidget);
    expect(find.text('₱700'), findsNWidgets(2));

    // 6. Tap Continue Shopping to return to home
    final continueShoppingButton = find.text('Continue Shopping');
    expect(continueShoppingButton, findsOneWidget);
    await tester.tap(continueShoppingButton);
    await tester.pumpAndSettle();

    // Verify returned to Home screen catalog
    expect(find.text('CSShop - The CSSEC Merch Store'), findsOneWidget);
  });

  test('Verifies catalog asset paths exist on disk and meet variant requirements', () {
    // 1. Check shirt product variants (3 variants, each with front & back)
    final shirt = mockProducts.firstWhere((p) => p.id == 'prod-001');
    expect(shirt.variants.length, 3);
    for (final variant in shirt.variants) {
      expect(variant.images.length, 2);
      for (final img in variant.images) {
        expect(File(img).existsSync(), isTrue, reason: 'Asset $img should exist');
      }
    }

    // 2. Check jacket product variants (2 variants)
    final jacket = mockProducts.firstWhere((p) => p.id == 'prod-002');
    expect(jacket.variants.length, 2);
    for (final variant in jacket.variants) {
      expect(variant.allImages.isNotEmpty, isTrue);
      for (final img in variant.allImages) {
        expect(File(img).existsSync(), isTrue, reason: 'Asset $img should exist');
      }
    }

    // 3. Check pin product variants (2 variants)
    final pin = mockProducts.firstWhere((p) => p.id == 'prod-004');
    expect(pin.variants.length, 2);
    for (final variant in pin.variants) {
      for (final img in variant.allImages) {
        expect(File(img).existsSync(), isTrue, reason: 'Asset $img should exist');
      }
    }

    // 4. Check sticker product variants (2 variants)
    final sticker = mockProducts.firstWhere((p) => p.id == 'prod-005');
    expect(sticker.variants.length, 2);
    for (final variant in sticker.variants) {
      for (final img in variant.allImages) {
        expect(File(img).existsSync(), isTrue, reason: 'Asset $img should exist');
      }
    }

    // 5. Check keychain product variants (1 variant)
    final keychain = mockProducts.firstWhere((p) => p.id == 'prod-006');
    expect(keychain.variants.length, 1);
    for (final variant in keychain.variants) {
      for (final img in variant.allImages) {
        expect(File(img).existsSync(), isTrue, reason: 'Asset $img should exist');
      }
    }
  });
}
