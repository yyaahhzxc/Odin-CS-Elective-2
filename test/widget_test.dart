import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_activity_3/main.dart';
import 'package:flutter_activity_3/router/app_router.dart';

void main() {
  setUp(() {
    AppRouter.router.go('/');
  });

  testWidgets('Root route "/" renders list of fruits', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FruitActivityApp());
    await tester.pumpAndSettle();

    expect(find.text('Fruits List'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Strawberry'), findsOneWidget);
    expect(find.text('Orange'), findsOneWidget);
    expect(find.text('Mango'), findsOneWidget);
    expect(find.text('Watermelon'), findsOneWidget);
  });

  testWidgets('Tapping on a fruit redirects to "/fruit/:name" showing illustration and description', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FruitActivityApp());
    await tester.pumpAndSettle();

    // Tap on Apple card
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    // Verify detail screen is loaded with illustration, URL, description, and back button
    expect(find.text('Apple'), findsWidgets);
    expect(find.text('URL: /fruit/apple'), findsOneWidget);
    expect(find.textContaining('A sweet and crisp red fruit with a thin skin'), findsOneWidget);
    expect(find.text('Back to Fruits List (/)'), findsOneWidget);
  });

  testWidgets('Clicking Back button redirects back to "/"', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FruitActivityApp());
    await tester.pumpAndSettle();

    // Navigate to Banana
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    // Click Back button
    final backBtn = find.text('Back to Fruits List (/)');
    await tester.ensureVisible(backBtn);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify back on home
    expect(find.text('Fruits List'), findsOneWidget);
  });

  testWidgets('Direct URL navigation to "/fruit/orange" loads Orange details', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    AppRouter.router.go('/fruit/orange');

    await tester.pumpWidget(const FruitActivityApp());
    await tester.pumpAndSettle();

    expect(find.text('Orange'), findsWidgets);
    expect(find.text('URL: /fruit/orange'), findsOneWidget);
    expect(find.textContaining('A round, bright orange citrus fruit'), findsOneWidget);
  });

  testWidgets('Invalid fruit route "/fruit/unknown" shows NotFoundScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    AppRouter.router.go('/fruit/unknownfruit');

    await tester.pumpWidget(const FruitActivityApp());
    await tester.pumpAndSettle();

    expect(find.text('Fruit Not Found'), findsOneWidget);
    expect(find.text('Back to Fruits List'), findsOneWidget);
  });
}
