import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

/// Centralized state manager for user authentication sessions and role permissions.
///
/// Implemented using [ChangeNotifier] and exposed via Riverpod providers and [AuthScope].
class AuthManager extends ChangeNotifier {
  final AuthService _service;
  final VoidCallback? onSignedOut;
  StreamSubscription<AuthState>? _authSubscription;

  bool _isLoading = false;
  String? _errorMessage;

  AuthManager({
    AuthService? service,
    this.onSignedOut,
  }) : _service = service ?? AuthService() {
    _authSubscription = _service.authStateChanges.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
        await _service.fetchUserProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        onSignedOut?.call();
      }
      notifyListeners();
    });
    if (_service.isAuthenticated) {
      _service.fetchUserProfile().then((_) => notifyListeners());
    }
  }

  /// Underlying authentication service reference.
  AuthService get service => _service;

  /// Current authenticated user instance, if logged in.
  User? get currentUser => _service.currentUser;

  /// Active user profile containing role ('customer' or 'admin').
  UserProfile? get currentProfile => _service.currentProfile;

  /// Returns true if an authenticated user session is active.
  bool get isAuthenticated => _service.isAuthenticated;

  /// Returns true if the active user is an Admin.
  bool get isAdmin => _service.isAdmin;

  /// Returns true if the active user is a Customer.
  bool get isCustomer => _service.isCustomer;

  /// Active user role string ('admin', 'customer', or 'guest').
  String get role => !isAuthenticated
      ? 'guest'
      : (isAdmin ? 'admin' : 'customer');

  /// Display name or username for the active user.
  String get displayName => _service.displayName;

  /// User's email address if authenticated.
  String? get email => _service.currentUser?.email;

  /// Provider name (e.g., 'google', 'github', or 'email').
  String get provider {
    final appMeta = _service.currentUser?.appMetadata;
    return appMeta?['provider']?.toString() ?? 'email';
  }

  /// Loading state indicator during network authentication requests.
  bool get isLoading => _isLoading;

  /// Most recent authentication error message, if any.
  String? get errorMessage => _errorMessage;

  /// Switches active role for demonstration or testing purposes.
  void setRoleForDemo(String newRole) {
    _service.setDemoRole(newRole);
    notifyListeners();
  }

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

  /// Registers a new user account with email, password, and custom metadata.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String? firstName,
    String? lastName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
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
      _errorMessage = 'Google sign-in could not be completed.';
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
      _errorMessage = 'GitHub sign-in could not be completed.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Signs out the current user session and triggers cart cleanup.
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.signOut();
      onSignedOut?.call();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears any displayed authentication error banner.
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

/// Scoped inherited notifier providing [AuthManager] down the widget tree.
class AuthScope extends InheritedNotifier<AuthManager> {
  const AuthScope({
    super.key,
    required AuthManager manager,
    required super.child,
  }) : super(notifier: manager);

  /// Retrieves the nearest [AuthManager] in the widget tree.
  static AuthManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found in current widget context.');
    return scope!.notifier!;
  }

  /// Retrieves the nearest [AuthManager], or null if not present.
  static AuthManager? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
  }
}
