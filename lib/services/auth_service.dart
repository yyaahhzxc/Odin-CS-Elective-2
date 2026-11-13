import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/user_profile.dart';

/// Service managing user authentication sessions and role resolution via Supabase Auth.
///
/// Supports email/password credentials, user registration with metadata (firstname, lastname, username),
/// third-party OAuth providers (Google, GitHub), profile & role lookup (`customer` vs `admin`),
/// and deterministic mock fallbacks for testing.
class AuthService {
  final SupabaseClient? _client;
  User? _mockUser;
  UserProfile? _cachedProfile;

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

  /// Cached user profile containing `role` ('customer' or 'admin').
  UserProfile? get currentProfile => _cachedProfile;

  /// Returns true if the active user holds the 'admin' role.
  bool get isAdmin {
    if (_cachedProfile != null) {
      return _cachedProfile!.isAdmin;
    }
    final user = currentUser;
    if (user == null) return false;
    final roleMeta = user.userMetadata?['role']?.toString().toLowerCase() ??
        user.appMetadata['role']?.toString().toLowerCase() ??
        '';
    if (roleMeta == 'admin') return true;
    final lowerEmail = user.email?.toLowerCase();
    if (lowerEmail == 'admin@pokemart.com' ||
        lowerEmail == 'ysodin@addu.edu.ph') {
      return true;
    }
    return false;
  }

  /// Returns true if the active user is a customer.
  bool get isCustomer => isAuthenticated && !isAdmin;

  /// Returns the display username extracted from profile, user metadata, or email prefix.
  String get displayName {
    if (_cachedProfile != null && _cachedProfile!.fullName.isNotEmpty) {
      return _cachedProfile!.fullName;
    }
    final user = currentUser;
    if (user == null) return 'Guest';
    final metadata = user.userMetadata;
    if (metadata != null) {
      if (metadata['full_name'] != null &&
          metadata['full_name'].toString().trim().isNotEmpty) {
        return metadata['full_name'].toString().trim();
      }
      final first = (metadata['firstname'] ?? metadata['first_name'] ?? '')
          .toString()
          .trim();
      final last = (metadata['lastname'] ?? metadata['last_name'] ?? '')
          .toString()
          .trim();
      final combined = [first, last].where((s) => s.isNotEmpty).join(' ');
      if (combined.isNotEmpty) return combined;

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

  /// Fetches the user's profile and role from `public.profiles` joined with `public.roles`.
  Future<UserProfile?> fetchUserProfile() async {
    final user = currentUser;
    if (user == null) {
      _cachedProfile = null;
      return null;
    }

    final client = _client;
    if (client != null && SupabaseConfig.isConfigured && _mockUser == null) {
      try {
        final data = await client
            .from('profiles')
            .select('id, email, firstname, lastname, role_id, roles(role)')
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          _cachedProfile = UserProfile.fromJson(data);
          return _cachedProfile;
        }
      } catch (_) {
        // Fallback to metadata if profiles table is not yet migrated
      }
    }

    final lowerEmail = user.email?.toLowerCase();
    final isDefaultAdmin = lowerEmail == 'admin@pokemart.com' ||
        lowerEmail == 'ysodin@addu.edu.ph' ||
        user.userMetadata?['role'] == 'admin';

    _cachedProfile = UserProfile(
      id: user.id,
      email: user.email ?? '',
      firstName: (user.userMetadata?['firstname'] ??
              user.userMetadata?['first_name'] ??
              '')
          .toString(),
      lastName: (user.userMetadata?['lastname'] ??
              user.userMetadata?['last_name'] ??
              '')
          .toString(),
      roleId: isDefaultAdmin ? 2 : 1,
      role: isDefaultAdmin ? 'admin' : 'customer',
    );
    return _cachedProfile;
  }

  /// Allows switching role in demo/testing or updating role when permitted.
  void setDemoRole(String role) {
    final user = currentUser;
    if (user == null) return;
    final normalized = role.toLowerCase() == 'admin' ? 'admin' : 'customer';
    _cachedProfile = (_cachedProfile ??
            UserProfile(
              id: user.id,
              email: user.email ?? '',
            ))
        .copyWith(
      roleId: normalized == 'admin' ? 2 : 1,
      role: normalized,
    );
  }

  /// Authenticates using email and password credentials.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final client = _client;
    if (client != null && SupabaseConfig.isConfigured) {
      await client.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );
      await fetchUserProfile();
      return;
    }

    // Fallback simulation for test and offline environments
    final isAdminEmail = trimmedEmail.toLowerCase() == 'admin@pokemart.com';
    setMockUser(
      User(
        id: 'mock-user-${trimmedEmail.hashCode.abs()}',
        appMetadata: {
          'provider': 'email',
          'role': isAdminEmail ? 'admin' : 'customer',
        },
        userMetadata: {
          'username': trimmedEmail.split('@').first,
          'email': trimmedEmail,
          'role': isAdminEmail ? 'admin' : 'customer',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: trimmedEmail,
      ),
    );
  }

  /// Registers a new user account with email, password, username, and name metadata.
  /// Every new account starts as a customer (`role_id = 1`).
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
          // Match exact keys expected by `handle_new_user` trigger in Supabase Setup.pdf
          'firstname': trimmedFirst,
          'lastname': trimmedLast,
          if (trimmedFirst.isNotEmpty) 'first_name': trimmedFirst,
          if (trimmedLast.isNotEmpty) 'last_name': trimmedLast,
          'full_name': fullName.isNotEmpty ? fullName : username.trim(),
          'role': 'customer',
        },
      );
      await fetchUserProfile();
      return;
    }

    // Fallback simulation for test and offline environments
    setMockUser(
      User(
        id: 'mock-user-${email.hashCode.abs()}',
        appMetadata: {'provider': 'email', 'role': 'customer'},
        userMetadata: {
          'username': username.trim(),
          'firstname': trimmedFirst,
          'lastname': trimmedLast,
          if (trimmedFirst.isNotEmpty) 'first_name': trimmedFirst,
          if (trimmedLast.isNotEmpty) 'last_name': trimmedLast,
          'full_name': fullName.isNotEmpty ? fullName : username.trim(),
          'email': email.trim(),
          'role': 'customer',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email.trim(),
      ),
    );
  }

  /// Initiates third-party OAuth authentication with Google.
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

    setMockUser(
      const User(
        id: 'mock-google-user-001',
        appMetadata: {'provider': 'google', 'role': 'customer'},
        userMetadata: {
          'username': 'Google Trainer',
          'full_name': 'Google Trainer',
          'firstname': 'Google',
          'lastname': 'Trainer',
          'email': 'trainer@gmail.com',
          'role': 'customer',
        },
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
        email: 'trainer@gmail.com',
      ),
    );
    return true;
  }

  /// Initiates third-party OAuth authentication with GitHub.
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

    setMockUser(
      const User(
        id: 'mock-github-user-001',
        appMetadata: {'provider': 'github', 'role': 'customer'},
        userMetadata: {
          'username': 'GitHub Trainer',
          'full_name': 'GitHub Trainer',
          'firstname': 'GitHub',
          'lastname': 'Trainer',
          'email': 'trainer@github.com',
          'role': 'customer',
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
    _mockUser = null;
    _cachedProfile = null;
    final client = _client;
    if (client != null && SupabaseConfig.isConfigured) {
      try {
        await client.auth.signOut();
      } catch (_) {
        // Ignore network errors during sign-out cleanup
      }
    }
    _mockStreamController.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  /// Injects a mock user session for deterministic unit and widget testing.
  @visibleForTesting
  void setMockUser(User? user) {
    _mockUser = user;
    if (user == null) {
      _cachedProfile = null;
    } else {
      final isDefaultAdmin =
          user.email?.toLowerCase() == 'admin@pokemart.com' ||
              user.userMetadata?['role'] == 'admin';
      _cachedProfile = UserProfile(
        id: user.id,
        email: user.email ?? '',
        firstName: (user.userMetadata?['firstname'] ??
                user.userMetadata?['first_name'] ??
                '')
            .toString(),
        lastName: (user.userMetadata?['lastname'] ??
                user.userMetadata?['last_name'] ??
                '')
            .toString(),
        roleId: isDefaultAdmin ? 2 : 1,
        role: isDefaultAdmin ? 'admin' : 'customer',
      );
    }
    final session = user != null
        ? Session(
            accessToken: 'mock-access-token',
            tokenType: 'bearer',
            user: user,
          )
        : null;
    _mockStreamController.add(
      AuthState(
        user != null ? AuthChangeEvent.signedIn : AuthChangeEvent.signedOut,
        session,
      ),
    );
  }

  /// Releases internal stream resources.
  void dispose() {
    _mockStreamController.close();
  }
}
