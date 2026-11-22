import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csshop/main.dart';
import 'package:csshop/providers/app_providers.dart';
import 'package:csshop/services/auth_service.dart';
import 'package:csshop/services/supabase_service.dart';

void main() {
  setUp(() {
    SupabaseService.resetMockData();
  });

  Widget buildTestApp({
    required AuthService authService,
    required SupabaseService supabaseService,
  }) {
    return ProviderScope(
      overrides: [
        supabaseServiceProvider.overrideWithValue(supabaseService),
        authServiceProvider.overrideWithValue(authService),
      ],
      child: const PokeMartApp(),
    );
  }

  testWidgets('Authenticated PokéMart home screen renders branding and popular products',
      (WidgetTester tester) async {
    final authService = AuthService.mock();
    await authService.signInWithEmail(
      email: 'ash@pokemart.com',
      password: 'password123',
    );

    await tester.pumpWidget(
      buildTestApp(
        authService: authService,
        supabaseService: SupabaseService.mock(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Poké'), findsWidgets);
    expect(find.text('MART'), findsWidgets);
    expect(find.text('PokéMart Official Store'), findsOneWidget);
    expect(find.text('Most Popular Products'), findsOneWidget);
    expect(find.text('View All Products'), findsWidgets);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });

  testWidgets(
      'Customer flow: Sign In -> Home -> Detail -> Add to Cart -> Cart -> Checkout -> Order History -> Sign Out',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authService = AuthService.mock();
    await tester.pumpWidget(
      buildTestApp(
        authService: authService,
        supabaseService: SupabaseService.mock(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Starts on LoginScreen auth gate when signed out
    expect(find.text('Welcome Back, Trainer!'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'ash@pokemart.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    // 2. Redirected to Storefront Home
    expect(find.text('Most Popular Products'), findsOneWidget);

    // 3. Navigate to Product Detail Screen
    await tester.tap(find.text('Poké Ball'));
    await tester.pumpAndSettle();
    expect(find.text('Add to Cart'), findsOneWidget);

    // 4. Add product to cart
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Added 1 × Poké Ball'), findsOneWidget);

    // 5. Open Cart from AppBar
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Shopping Cart'), findsOneWidget);

    // 6. Checkout -> DB-backed Checkout Confirmation
    await tester.tap(find.text('Proceed to Checkout').first);
    await tester.pumpAndSettle();
    expect(find.text('Checkout Confirmation'), findsOneWidget);
    expect(find.text('Order Placed Successfully!'), findsOneWidget);
    expect(find.text('PKM-01001'), findsOneWidget);
    expect(find.text('Poké Ball'), findsOneWidget);

    // 7. Navigate to Order History
    await tester.tap(find.text('View Order History'));
    await tester.pumpAndSettle();
    expect(find.text('Order History'), findsOneWidget);
    expect(find.text('PKM-01001'), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);

    // 8. Return home -> Profile -> Sign Out clears session and returns to /login
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign Out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back, Trainer!'), findsOneWidget);
  });

  testWidgets('Smart AppBar back buttons adapt to top-level tabs vs pushed routes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authService = AuthService.mock();
    await authService.signInWithEmail(
      email: 'ash@pokemart.com',
      password: 'password123',
    );

    await tester.pumpWidget(
      buildTestApp(
        authService: authService,
        supabaseService: SupabaseService.mock(),
      ),
    );
    await tester.pumpAndSettle();

    // Top-level Cart tab has no back arrow
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Shopping Cart'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);

    // Top-level Profile tab has no back arrow
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Account'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);

    // Pushed Cart from Product Detail displays back arrow
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Poké Ball'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('Shopping Cart'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Add to Cart'), findsOneWidget);
  });

  testWidgets('Role-based route guards block unauthorized Customer and Admin routes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Customer blocked from /admin/product/add and /admin/orders
    final customerAuth = AuthService.mock();
    await customerAuth.signInWithEmail(
      email: 'ash@pokemart.com',
      password: 'password123',
    );

    final container = ProviderContainer(
      overrides: [
        supabaseServiceProvider.overrideWithValue(SupabaseService.mock()),
        authServiceProvider.overrideWithValue(customerAuth),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PokeMartApp(),
      ),
    );
    await tester.pumpAndSettle();

    container.read(routerProvider).go('/admin/product/add');
    await tester.pumpAndSettle();
    expect(find.text('Permission Denied'), findsOneWidget);
    expect(find.text('Admin Access Required'), findsOneWidget);

    container.read(routerProvider).go('/admin/orders');
    await tester.pumpAndSettle();
    expect(find.text('Permission Denied'), findsOneWidget);
    expect(find.text('Admin Permission Required'), findsOneWidget);

    // 2. Admin blocked from /cart and /orders, and Product Detail hides bag icon
    await container.read(authProvider).signOut();
    await tester.pumpAndSettle();
    await container.read(authProvider).signInWithEmail(
          email: 'admin@pokemart.com',
          password: 'adminpassword',
        );
    await tester.pumpAndSettle();

    container.read(routerProvider).go('/product/poke-ball');
    await tester.pumpAndSettle();
    expect(find.text('Edit Product (Admin)'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsNothing);

    container.read(routerProvider).go('/cart');
    await tester.pumpAndSettle();
    expect(find.text('Permission Denied'), findsOneWidget);
    expect(find.text('Admin Accounts Cannot Place Orders'), findsOneWidget);

    container.read(routerProvider).go('/orders');
    await tester.pumpAndSettle();
    expect(find.text('Permission Denied'), findsOneWidget);
    expect(find.text('Customer Account Required'), findsOneWidget);
  });

  testWidgets('Admin Manage Categories dialog supports add, rename, and delete',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authService = AuthService.mock();
    await authService.signInWithEmail(
      email: 'admin@pokemart.com',
      password: 'adminpassword',
    );

    await tester.pumpWidget(
      buildTestApp(
        authService: authService,
        supabaseService: SupabaseService.mock(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.category_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Manage Categories'), findsOneWidget);

    // Add category
    await tester.enterText(
      find.widgetWithText(TextFormField, 'New category name'),
      'Key Items',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(find.text('Key Items'), findsOneWidget);

    // Rename category
    await tester.tap(find.byTooltip('Rename Key Items'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Category Name'),
      'Rare Key Items',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Rare Key Items'), findsOneWidget);

    // Delete category with confirmation
    await tester.tap(find.byTooltip('Delete Rare Key Items'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Are you sure you want to delete the category "Rare Key Items"?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Rare Key Items'), findsNothing);
  });

  testWidgets(
      'Dynamic theme toggle, filter order, and inline ellipsis pagination work cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authService = AuthService.mock();
    await authService.signInWithEmail(
      email: 'ash@pokemart.com',
      password: 'password123',
    );

    final container = ProviderContainer(
      overrides: [
        supabaseServiceProvider.overrideWithValue(SupabaseService.mock()),
        authServiceProvider.overrideWithValue(authService),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PokeMartApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Theme toggle icon switches between dark and light mode icons
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    // 2. Open View All Products and check Filter panel chip order
    await tester.tap(find.text('View All'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    final allChip = find.widgetWithText(FilterChip, 'All');
    final favChip = find.widgetWithText(FilterChip, 'Favorites Only');
    expect(allChip, findsOneWidget);
    expect(favChip, findsOneWidget);
    expect(
      tester.getTopLeft(allChip).dx < tester.getTopLeft(favChip).dx,
      isTrue,
    );

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    // 3. Inline ellipsis pagination jumps to page 5 and renders neighboring pages
    final ellipsisFinder = find.text('...').first;
    await tester.ensureVisible(ellipsisFinder);
    await tester.pumpAndSettle();

    await tester.tap(ellipsisFinder);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    final ellipsisInput = find.descendant(
      of: find.byKey(const ValueKey<String>('ellipsis-right')),
      matching: find.byType(TextField),
    );
    expect(ellipsisInput, findsOneWidget);

    await tester.enterText(ellipsisInput, '5');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();

    expect(container.read(catalogProvider).currentPage, 5);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });
}
