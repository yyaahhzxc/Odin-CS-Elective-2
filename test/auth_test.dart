import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csshop/main.dart';
import 'package:csshop/screens/login_screen.dart';
import 'package:csshop/services/auth_service.dart';
import 'package:csshop/services/supabase_service.dart';
import 'package:csshop/state/auth_state.dart';
import 'package:csshop/state/cart_state.dart';
import 'package:csshop/state/catalog_state.dart';

void main() {
  group('AuthManager Unit Tests', () {
    test('Initializes with unauthenticated state', () {
      final authService = AuthService();
      final authManager = AuthManager(service: authService);

      expect(authManager.isAuthenticated, isFalse);
      expect(authManager.currentUser, isNull);
      expect(authManager.displayName, 'Guest');
      expect(authManager.email, isNull);
    });

    test('Authenticates via Google OAuth simulation', () async {
      final authService = AuthService();
      final authManager = AuthManager(service: authService);

      final success = await authManager.signInWithGoogle();

      expect(success, isTrue);
      expect(authManager.isAuthenticated, isTrue);
      expect(authManager.displayName, 'Google Trainer');
      expect(authManager.email, 'trainer@gmail.com');
      expect(authManager.provider, 'google');
    });

    test('Authenticates via GitHub OAuth simulation', () async {
      final authService = AuthService();
      final authManager = AuthManager(service: authService);

      final success = await authManager.signInWithGitHub();

      expect(success, isTrue);
      expect(authManager.isAuthenticated, isTrue);
      expect(authManager.displayName, 'GitHub Trainer');
      expect(authManager.email, 'trainer@github.com');
      expect(authManager.provider, 'github');
    });

    test('Authenticates via Email and Password simulation', () async {
      final authService = AuthService();
      final authManager = AuthManager(service: authService);

      final success = await authManager.signInWithEmail(
        email: 'ash@pokemart.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authManager.isAuthenticated, isTrue);
      expect(authManager.displayName, 'ash');
      expect(authManager.email, 'ash@pokemart.com');
      expect(authManager.provider, 'email');
    });

    test('Registers new account with custom username and name', () async {
      final authService = AuthService();
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
      expect(authManager.displayName, 'Red Ketchum');
      expect(authManager.email, 'red@pokemart.com');
    });

    test('Signs out and resets session state', () async {
      final authService = AuthService();
      final authManager = AuthManager(service: authService);

      await authManager.signInWithGoogle();
      expect(authManager.isAuthenticated, isTrue);

      await authManager.signOut();
      expect(authManager.isAuthenticated, isFalse);
      expect(authManager.currentUser, isNull);
      expect(authManager.displayName, 'Guest');
    });
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders Sign In form fields and Google OAuth option',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authService = AuthService();
      final authManager = AuthManager(service: authService);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthScope(
            manager: authManager,
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and input fields
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with GitHub'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('Toggles to Sign Up mode with First Name, Last Name, and Username fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authService = AuthService();
      final authManager = AuthManager(service: authService);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthScope(
            manager: authManager,
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Sign Up tab
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

    testWidgets('Signing in with Google shows profile and Sign Out button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authService = AuthService();
      final authManager = AuthManager(service: authService);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthScope(
            manager: authManager,
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Continue with Google
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      // Should now render profile view
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Google Trainer'), findsOneWidget);
      expect(find.text('trainer@gmail.com'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Return to Shop'), findsOneWidget);
    });

    testWidgets('Full navigation from Home to Login Screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final catalogManager = CatalogManager(service: SupabaseService(null));
      await catalogManager.fetchCatalog();
      final cartManager = CartManager();
      final authManager = AuthManager(service: AuthService());

      await tester.pumpWidget(
        PokeMartApp(
          catalogManager: catalogManager,
          cartManager: cartManager,
          authManager: authManager,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Account icon in home appbar
      await tester.tap(find.byIcon(Icons.account_circle_outlined));
      await tester.pumpAndSettle();

      // Verify we arrived at LoginScreen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with GitHub'), findsOneWidget);
    });
  });
}
