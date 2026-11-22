import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csshop/main.dart';
import 'package:csshop/providers/app_providers.dart';
import 'package:csshop/screens/login_screen.dart';
import 'package:csshop/services/auth_service.dart';
import 'package:csshop/services/supabase_service.dart';
import 'package:csshop/state/auth_state.dart';

void main() {
  setUp(() {
    SupabaseService.resetMockData();
  });

  group('AuthManager Unit Tests', () {
    test('Initializes with unauthenticated state', () {
      final authService = AuthService.mock();
      final authManager = AuthManager(service: authService);

      expect(authManager.isAuthenticated, isFalse);
      expect(authManager.isAdmin, isFalse);
      expect(authManager.displayName, 'Guest');
      expect(authManager.email, isNull);
    });

    test('Authenticates via Google OAuth simulation', () async {
      final authService = AuthService.mock();
      final authManager = AuthManager(service: authService);

      final success = await authManager.signInWithGoogle();

      expect(success, isTrue);
      expect(authManager.isAuthenticated, isTrue);
      expect(authManager.isAdmin, isFalse);
      expect(authManager.displayName, 'Google Trainer');
      expect(authManager.email, 'trainer@gmail.com');
      expect(authManager.provider, 'google');
    });

    test('Authenticates via GitHub OAuth simulation', () async {
      final authService = AuthService.mock();
      final authManager = AuthManager(service: authService);

      final success = await authManager.signInWithGitHub();

      expect(success, isTrue);
      expect(authManager.isAuthenticated, isTrue);
      expect(authManager.displayName, 'GitHub Trainer');
      expect(authManager.email, 'trainer@github.com');
      expect(authManager.provider, 'github');
    });

    test('Authenticates via Email and Password simulation', () async {
      final authService = AuthService.mock();
      final authManager = AuthManager(service: authService);

      final success = await authManager.signInWithEmail(
        email: 'ash@pokemart.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authManager.isAuthenticated, isTrue);
      expect(authManager.isAdmin, isFalse);
      expect(authManager.displayName, 'ash');
      expect(authManager.email, 'ash@pokemart.com');
      expect(authManager.provider, 'email');
    });

    test('Registers new customer account with custom username and name',
        () async {
      final authService = AuthService.mock();
      final authManager = AuthManager(service: authService);

      final success = await authManager.signUpWithEmail(
        email: 'red@pokemart.com',
        password: 'championpass',
        username: 'red_trainer',
        firstName: 'Red',
        lastName: 'Ketchum',
      );

      expect(success, isTrue);
      expect(authManager.isAuthenticated, isTrue);
      expect(authManager.isAdmin, isFalse);
      expect(authManager.displayName, 'Red Ketchum');
      expect(authManager.username, 'red_trainer');
      expect(authManager.email, 'red@pokemart.com');
    });

    test('Authenticates via registered username and password simulation',
        () async {
      final authService = AuthService.mock();
      final authManager = AuthManager(service: authService);

      await authManager.signUpWithEmail(
        email: 'red@pokemart.com',
        password: 'championpass',
        username: 'red_trainer',
        firstName: 'Red',
        lastName: 'Ketchum',
      );
      await authManager.signOut();
      expect(authManager.isAuthenticated, isFalse);

      final success = await authManager.signInWithIdentifier(
        identifier: 'red_trainer',
        password: 'championpass',
      );

      expect(success, isTrue);
      expect(authManager.isAuthenticated, isTrue);
      expect(authManager.email, 'red@pokemart.com');
      expect(authManager.username, 'red_trainer');
      expect(authManager.displayName, 'Red Ketchum');
    });

    test('Authenticates admin account in mock mode', () async {
      final authService = AuthService.mock();
      final authManager = AuthManager(service: authService);

      final success = await authManager.signInWithEmail(
        email: 'admin@pokemart.com',
        password: 'adminpassword',
      );

      expect(success, isTrue);
      expect(authManager.isAuthenticated, isTrue);
      expect(authManager.isAdmin, isTrue);
    });

    test('Signs out and resets session state', () async {
      final authService = AuthService.mock();
      final authManager = AuthManager(service: authService);

      await authManager.signInWithGoogle();
      expect(authManager.isAuthenticated, isTrue);

      await authManager.signOut();
      expect(authManager.isAuthenticated, isFalse);
      expect(authManager.isAdmin, isFalse);
      expect(authManager.displayName, 'Guest');
      expect(authManager.email, isNull);
    });
  });

  group('LoginScreen & Auth Gate Widget Tests', () {
    testWidgets('Unauthenticated app launch routes to LoginScreen auth gate',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseServiceProvider.overrideWithValue(SupabaseService.mock()),
            authServiceProvider.overrideWithValue(AuthService.mock()),
          ],
          child: const PokeMartApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back, Trainer!'), findsOneWidget);
      expect(find.text('Email or Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with GitHub'), findsOneWidget);
      expect(find.text('Most Popular Products'), findsNothing);
    });

    testWidgets(
        'Toggles to Sign Up mode with First Name, Last Name, and Username fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseServiceProvider.overrideWithValue(SupabaseService.mock()),
            authServiceProvider.overrideWithValue(AuthService.mock()),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Create an Account'), findsWidgets);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets(
        'Signing in with Google displays Profile view without demo role switcher',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseServiceProvider.overrideWithValue(SupabaseService.mock()),
            authServiceProvider.overrideWithValue(AuthService.mock()),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Google Trainer'), findsOneWidget);
      expect(find.text('trainer@gmail.com'), findsOneWidget);
      expect(find.text('Role: CUSTOMER'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Customer View'), findsNothing);
      expect(find.text('Admin View'), findsNothing);
    });

    testWidgets(
        'Admin role displays Add Product FAB, Manage Categories, and Edit/Delete controls while hiding Cart',
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
        ProviderScope(
          overrides: [
            supabaseServiceProvider.overrideWithValue(SupabaseService.mock()),
            authServiceProvider.overrideWithValue(authService),
          ],
          child: const PokeMartApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Product'), findsOneWidget);
      expect(find.byIcon(Icons.category_outlined), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsWidgets);
      expect(find.byIcon(Icons.delete_outline), findsWidgets);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsNothing);
    });
  });
}
