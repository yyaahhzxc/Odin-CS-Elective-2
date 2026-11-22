import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

/// Centralized state manager for user authentication sessions and role permissions.
///
/// Exposed via Riverpod `authProvider`. Does not directly reference Supabase SDK types.
class AuthManager extends ChangeNotifier {
  final AuthService _service;
  final VoidCallback? onSignedIn;
  final VoidCallback? onSignedOut;
  StreamSubscription<AuthChangeKind>? _authSubscription;

  bool _isLoading = false;
  String? _errorMessage;

  AuthManager({
    AuthService? service,
    this.onSignedIn,
    this.onSignedOut,
  }) : _service = service ?? AuthService() {
    _authSubscription = _service.sessionEvents.listen((kind) async {
      if (kind == AuthChangeKind.signedIn || kind == AuthChangeKind.updated) {
        try {
          await _service.fetchUserProfile();
        } on AppAuthException catch (e) {
          _errorMessage = e.message;
        } catch (_) {}
        if (kind == AuthChangeKind.signedIn && _service.isAuthenticated) {
          onSignedIn?.call();
        }
      } else if (kind == AuthChangeKind.signedOut) {
        _errorMessage = null;
        onSignedOut?.call();
      }
      notifyListeners();
    });

    if (_service.isAuthenticated) {
      Future.microtask(() async {
        try {
          await _service.fetchUserProfile();
        } on AppAuthException catch (e) {
          _errorMessage = e.message;
        } catch (_) {}
        if (_service.isAuthenticated) {
          onSignedIn?.call();
        }
        notifyListeners();
      });
    }
  }

  /// Underlying authentication service reference.
  AuthService get service => _service;

  /// Active user profile containing role ('customer' or 'admin').
  UserProfile? get currentProfile => _service.currentProfile;

  /// Returns true if an authenticated user session is active.
  bool get isAuthenticated => _service.isAuthenticated;

  /// Returns true if the active user holds the `admin` role.
  bool get isAdmin => _service.isAdmin;

  /// Returns true if the active user is a customer.
  bool get isCustomer => _service.isCustomer;

  /// Active user role string ('admin', 'customer', or 'guest').
  String get role => !isAuthenticated
      ? 'guest'
      : (isAdmin ? 'admin' : 'customer');

  /// Unique user identifier when authenticated.
  String? get userId => _service.userId;

  /// Display name or username for the active user.
  String get displayName => _service.displayName;

  /// User's email address if authenticated.
  String? get email => _service.email;

  /// User's username if available from profile or metadata.
  String? get username => _service.username;

  /// Provider name (e.g., 'google', 'github', or 'email').
  String get provider => _service.provider;

  /// Loading state indicator during authentication requests.
  bool get isLoading => _isLoading;

  /// Most recent authentication error message, if any.
  String? get errorMessage => _errorMessage;

  /// Authenticates using either an email address or a username with password.
  Future<bool> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.signInWithIdentifier(
        identifier: identifier,
        password: password,
      );
      if (_service.isAuthenticated) {
        onSignedIn?.call();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Sign in failed. Please check your network and credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Authenticates using email and password credentials.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) {
    return signInWithIdentifier(identifier: email, password: password);
  }

  /// Registers a new customer account with optional username and name metadata.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String username = '',
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
      if (_service.isAuthenticated) {
        onSignedIn?.call();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Registration failed. Please check your credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Triggers third-party Google OAuth authentication.
  Future<bool> signInWithGoogle({String? redirectTo}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.signInWithGoogle(redirectTo: redirectTo);
      if (success && _service.isAuthenticated) {
        onSignedIn?.call();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Google sign-in could not be completed.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Triggers third-party GitHub OAuth authentication.
  Future<bool> signInWithGitHub({String? redirectTo}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.signInWithGitHub(redirectTo: redirectTo);
      if (success && _service.isAuthenticated) {
        onSignedIn?.call();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'GitHub sign-in could not be completed.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Signs out the current user session and clears dependent session caches.
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.signOut();
      onSignedOut?.call();
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
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
