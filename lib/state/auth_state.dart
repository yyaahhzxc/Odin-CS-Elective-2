import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

/// Centralized state manager for user authentication sessions.
///
/// Implemented using [ChangeNotifier] to provide reactive authentication state
/// management across the application tree without external state libraries.
class AuthManager extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<AuthState>? _authSubscription;

  bool _isLoading = false;
  String? _errorMessage;

  AuthManager({AuthService? service}) : _service = service ?? AuthService() {
    _authSubscription = _service.authStateChanges.listen((data) {
      notifyListeners();
    });
  }

  /// Underlying authentication service reference.
  AuthService get service => _service;

  /// Current authenticated user instance, if logged in.
  User? get currentUser => _service.currentUser;

  /// Returns true if an authenticated user session is active.
  bool get isAuthenticated => _service.isAuthenticated;

  /// Display name or username for the active user.
  String get displayName => _service.displayName;

  /// User's email address if authenticated.
  String? get email => _service.currentUser?.email;

  /// Provider name (e.g., 'google' or 'email').
  String get provider {
    final appMeta = _service.currentUser?.appMetadata;
    return appMeta?['provider']?.toString() ?? 'email';
  }

  /// Loading state indicator during network authentication requests.
  bool get isLoading => _isLoading;

  /// Most recent authentication error message, if any.
  String? get errorMessage => _errorMessage;

  /// Authenticates using standard email and password.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.signInWithEmail(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Sign in failed. Please check your network and credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registers a new user account with email, password, and custom username.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please check your credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Triggers 3rd-party Google OAuth authentication.
  Future<bool> signInWithGoogle({String? redirectTo}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.signInWithGoogle(redirectTo: redirectTo);
      _isLoading = false;
      notifyListeners();
      return success;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Google authentication encountered an unexpected error.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Triggers 3rd-party GitHub OAuth authentication.
  Future<bool> signInWithGitHub({String? redirectTo}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.signInWithGitHub(redirectTo: redirectTo);
      _isLoading = false;
      notifyListeners();
      return success;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'GitHub authentication encountered an unexpected error.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Signs the user out of the active session.
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.signOut();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  /// Clears any cached error messages.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}

/// InheritedNotifier exposing [AuthManager] reactively down the widget tree.
class AuthScope extends InheritedNotifier<AuthManager> {
  const AuthScope({
    super.key,
    required AuthManager manager,
    required super.child,
  }) : super(notifier: manager);

  /// Accesses the nearest [AuthManager] instance up the widget tree.
  static AuthManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found in context');
    return scope!.notifier!;
  }

  /// Safely retrieves [AuthManager] if an [AuthScope] exists in context.
  static AuthManager? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
  }
}
