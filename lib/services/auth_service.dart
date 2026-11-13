import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

/// Service managing user authentication sessions via Supabase Auth.
///
/// Supports email/password credentials, user registration with metadata (username),
/// third-party OAuth providers (Google), and deterministic mock fallbacks for testing.
class AuthService {
  final SupabaseClient? _client;
  User? _mockUser;
  final StreamController<AuthState> _mockStreamController =
      StreamController<AuthState>.broadcast();

  static SupabaseClient? _resolveClient(SupabaseClient? client) {
    if (client != null) return client;
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  AuthService([SupabaseClient? client]) : _client = _resolveClient(client);

  /// Currently authenticated Supabase user or active mock user.
  User? get currentUser => _mockUser ?? _client?.auth.currentUser;

  /// Active Supabase authentication session.
  Session? get currentSession => _client?.auth.currentSession;

  /// Returns true if an authenticated user session is active.
  bool get isAuthenticated => currentUser != null;

  /// Returns the display username extracted from user metadata or email prefix.
  String get displayName {
    final user = currentUser;
    if (user == null) return 'Guest';
    final metadata = user.userMetadata;
    if (metadata != null) {
      if (metadata['full_name'] != null &&
          metadata['full_name'].toString().trim().isNotEmpty) {
        return metadata['full_name'].toString().trim();
      }
      if (metadata['username'] != null &&
          metadata['username'].toString().trim().isNotEmpty) {
        return metadata['username'].toString().trim();
      }
    }
    if (user.email != null && user.email!.contains('@')) {
      return user.email!.split('@').first;
    }
    return 'Trainer';
  }

  /// Broadcast stream delivering real-time authentication state updates.
  Stream<AuthState> get authStateChanges {
    final client = _client;
    if (client != null) {
      return client.auth.onAuthStateChange;
    }
    return _mockStreamController.stream;
  }

  /// Authenticates using email and password credentials.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client != null && SupabaseConfig.isConfigured) {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return;
    }

    // Fallback simulation for test and offline environments
    setMockUser(
      User(
        id: 'mock-user-${email.hashCode.abs()}',
        appMetadata: {'provider': 'email'},
        userMetadata: {
          'username': email.split('@').first,
          'email': email.trim(),
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email.trim(),
      ),
    );
  }

  /// Registers a new user account with email, password, username, and name metadata.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String? firstName,
    String? lastName,
  }) async {
    final client = _client;
    final trimmedFirst = firstName?.trim() ?? '';
    final trimmedLast = lastName?.trim() ?? '';
    final fullName = [trimmedFirst, trimmedLast]
        .where((s) => s.isNotEmpty)
        .join(' ');

    if (client != null && SupabaseConfig.isConfigured) {
      await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'username': username.trim(),
          if (trimmedFirst.isNotEmpty) 'first_name': trimmedFirst,
          if (trimmedLast.isNotEmpty) 'last_name': trimmedLast,
          'full_name': fullName.isNotEmpty ? fullName : username.trim(),
        },
      );
      return;
    }

    // Fallback simulation for test and offline environments
    setMockUser(
      User(
        id: 'mock-user-${email.hashCode.abs()}',
        appMetadata: {'provider': 'email'},
        userMetadata: {
          'username': username.trim(),
          if (trimmedFirst.isNotEmpty) 'first_name': trimmedFirst,
          if (trimmedLast.isNotEmpty) 'last_name': trimmedLast,
          'full_name': fullName.isNotEmpty ? fullName : username.trim(),
          'email': email.trim(),
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email.trim(),
      ),
    );
  }

  /// Initiates third-party OAuth authentication with Google.
  ///
  /// On Web, redirects within the active browser context.
  /// On Mobile, deep links through `io.supabase.pokemart://login-callback`.
  Future<bool> signInWithGoogle({String? redirectTo}) async {
    final client = _client;
    if (client != null && SupabaseConfig.isConfigured) {
      final redirectUrl = redirectTo ??
          (kIsWeb ? null : 'io.supabase.pokemart://login-callback');
      return await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
    }

    // Fallback simulation for test and offline environments
    setMockUser(
      const User(
        id: 'mock-google-user-001',
        appMetadata: {'provider': 'google'},
        userMetadata: {
          'username': 'Google Trainer',
          'full_name': 'Google Trainer',
          'email': 'trainer@gmail.com',
        },
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
        email: 'trainer@gmail.com',
      ),
    );
    return true;
  }

  /// Initiates third-party OAuth authentication with GitHub.
  ///
  /// On Web, redirects within the active browser context.
  /// On Mobile, deep links through `io.supabase.pokemart://login-callback`.
  Future<bool> signInWithGitHub({String? redirectTo}) async {
    final client = _client;
    if (client != null && SupabaseConfig.isConfigured) {
      final redirectUrl = redirectTo ??
          (kIsWeb ? null : 'io.supabase.pokemart://login-callback');
      return await client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: redirectUrl,
      );
    }

    // Fallback simulation for test and offline environments
    setMockUser(
      const User(
        id: 'mock-github-user-001',
        appMetadata: {'provider': 'github'},
        userMetadata: {
          'username': 'GitHub Trainer',
          'full_name': 'GitHub Trainer',
          'email': 'trainer@github.com',
        },
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
        email: 'trainer@github.com',
      ),
    );
    return true;
  }

  /// Terminates the active user session and clears authentication state.
  Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
    clearMockUser();
  }

  /// Injects a mock user for unit/widget testing.
  @visibleForTesting
  void setMockUser(User? user) {
    _mockUser = user;
    _mockStreamController.add(
      AuthState(
        user != null ? AuthChangeEvent.signedIn : AuthChangeEvent.signedOut,
        null,
      ),
    );
  }

  /// Clears the active mock user.
  @visibleForTesting
  void clearMockUser() {
    _mockUser = null;
    _mockStreamController.add(
      const AuthState(AuthChangeEvent.signedOut, null),
    );
  }

  /// Releases stream controller resources.
  void dispose() {
    _mockStreamController.close();
  }
}
