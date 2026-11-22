import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/user_profile.dart';

/// Discrete authentication lifecycle events emitted by [AuthService].
enum AuthChangeKind {
  signedIn,
  signedOut,
  updated,
}

/// Domain exception representing authentication and profile authorization errors.
class AppAuthException implements Exception {
  final String message;

  const AppAuthException(this.message);

  @override
  String toString() => message;
}

/// Service managing user authentication sessions and role resolution via Supabase Auth.
///
/// Supports email/password credentials, registration metadata, third-party OAuth
/// providers (Google, GitHub), profile and role lookup from `public.profiles`
/// joined with `public.roles`, and deterministic mock mode for automated tests.
class AuthService {
  final SupabaseClient? _client;
  final bool _isMockMode;
  User? _mockUser;
  UserProfile? _cachedProfile;
  final Map<String, User> _mockUsersByEmail = {};

  final StreamController<AuthChangeKind> _mockStreamController =
      StreamController<AuthChangeKind>.broadcast();
  final Map<String, User> _mockUsersByUsername = {};

  static SupabaseClient? _resolveClient(SupabaseClient? client) {
    if (client != null) return client;
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Creates an [AuthService] bound to the configured [SupabaseClient] (or falls back to mock if uninitialized).
  AuthService([SupabaseClient? client])
      : this._fromResolvedClient(_resolveClient(client));

  AuthService._fromResolvedClient(this._client)
      : _isMockMode = _client == null;

  /// Creates an isolated in-memory mock [AuthService] for unit and widget tests.
  AuthService.mock()
      : _client = null,
        _isMockMode = true;

  User? get _activeUser =>
      _isMockMode ? _mockUser : _client?.auth.currentSession?.user;

  /// Unique identifier of the currently authenticated user, if any.
  String? get userId => _activeUser?.id;

  /// Email address of the currently authenticated user, if any.
  String? get email => _activeUser?.email;

  /// Authentication provider identifier (e.g. 'email', 'google', 'github').
  String get provider =>
      _activeUser?.appMetadata['provider']?.toString() ?? 'email';

  /// Returns true when an active authenticated user session exists.
  bool get isAuthenticated => _activeUser != null;

  /// Cached user profile loaded from `public.profiles` and `public.roles`.
  UserProfile? get currentProfile => _cachedProfile;

  /// Active user's handle/username from profile or metadata, if present.
  String? get username {
    final profileUsername = _cachedProfile?.username.trim() ?? '';
    if (profileUsername.isNotEmpty) return profileUsername;
    final metaUsername =
        _activeUser?.userMetadata?['username']?.toString().trim() ?? '';
    return metaUsername.isNotEmpty ? metaUsername : null;
  }

  /// Returns true if the active user holds the `admin` role.
  ///
  /// In live mode, role status is resolved strictly from the database profile.
  bool get isAdmin {
    if (_client != null && !_isMockMode) {
      return _cachedProfile?.isAdmin ?? false;
    }
    if (_cachedProfile != null) {
      return _cachedProfile!.isAdmin;
    }
    final user = _activeUser;
    if (user == null) return false;
    final roleMeta = user.userMetadata?['role']?.toString().toLowerCase() ??
        user.appMetadata['role']?.toString().toLowerCase() ??
        '';
    return roleMeta == 'admin' ||
        user.email?.toLowerCase() == 'admin@pokemart.com';
  }

  /// Returns true if the active user is an authenticated customer.
  bool get isCustomer => isAuthenticated && !isAdmin;

  /// Display name extracted from profile, OAuth/user metadata, or email prefix.
  String get displayName {
    if (_cachedProfile != null && _cachedProfile!.fullName.isNotEmpty) {
      return _cachedProfile!.fullName;
    }
    final user = _activeUser;
    if (user == null) return 'Guest';
    final metadata = user.userMetadata;
    if (metadata != null) {
      final full = (metadata['full_name'] ?? metadata['name'] ?? '')
          .toString()
          .trim();
      if (full.isNotEmpty) return full;

      final first = (metadata['firstname'] ??
              metadata['first_name'] ??
              metadata['given_name'] ??
              '')
          .toString()
          .trim();
      final last = (metadata['lastname'] ??
              metadata['last_name'] ??
              metadata['family_name'] ??
              '')
          .toString()
          .trim();
      final combined = [first, last].where((s) => s.isNotEmpty).join(' ');
      if (combined.isNotEmpty) return combined;

      final handle = metadata['username']?.toString().trim() ?? '';
      if (handle.isNotEmpty) return handle;
    }
    if (user.email != null && user.email!.contains('@')) {
      return user.email!.split('@').first;
    }
    return 'Trainer';
  }

  /// Broadcast stream delivering normalized authentication lifecycle events.
  Stream<AuthChangeKind> get sessionEvents {
    final client = _client;
    if (client != null && !_isMockMode) {
      return client.auth.onAuthStateChange.map((state) {
        if (state.event == AuthChangeEvent.signedOut) {
          _cachedProfile = null;
          return AuthChangeKind.signedOut;
        }
        if (state.event == AuthChangeEvent.initialSession) {
          return state.session != null
              ? AuthChangeKind.signedIn
              : AuthChangeKind.signedOut;
        }
        if (state.event == AuthChangeEvent.signedIn) {
          return AuthChangeKind.signedIn;
        }
        return AuthChangeKind.updated;
      });
    }
    return _mockStreamController.stream;
  }

  /// Fetches the user's profile and role from `public.profiles` joined with `public.roles`.
  Future<UserProfile?> fetchUserProfile() async {
    final user = _activeUser;
    if (user == null) {
      _cachedProfile = null;
      return null;
    }

    final client = _client;
    if (client != null && !_isMockMode) {
      try {
        final data = await client
            .from('profiles')
            .select(
              'id, email, username, firstname, lastname, role_id, roles(role)',
            )
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          _cachedProfile = UserProfile.fromJson(data);
          return _cachedProfile;
        }

        // Default strictly to customer when the profile trigger row is unavailable
        _cachedProfile = _profileFromMetadata(user, isAdminRole: false);
        return _cachedProfile;
      } on PostgrestException catch (e) {
        throw AppAuthException('Unable to load user profile: ${e.message}');
      }
    }

    final isMockAdmin = user.email?.toLowerCase() == 'admin@pokemart.com' ||
        user.userMetadata?['role']?.toString().toLowerCase() == 'admin';
    _cachedProfile = _profileFromMetadata(user, isAdminRole: isMockAdmin);
    return _cachedProfile;
  }

  UserProfile _profileFromMetadata(User user, {required bool isAdminRole}) {
    final meta = user.userMetadata;
    final first = (meta?['firstname'] ??
            meta?['first_name'] ??
            meta?['given_name'] ??
            '')
        .toString();
    final last = (meta?['lastname'] ??
            meta?['last_name'] ??
            meta?['family_name'] ??
            '')
        .toString();
    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      username: (meta?['username'] ?? '').toString(),
      firstName: first,
      lastName: last,
      roleId: isAdminRole ? 2 : 1,
      role: isAdminRole ? 'admin' : 'customer',
    );
  }

  /// Authenticates using either an email address or a username with password.
  Future<void> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final trimmed = identifier.trim();
    final isEmail = trimmed.contains('@');
    final client = _client;

    if (client != null && !_isMockMode) {
      String resolvedEmail = trimmed;
      if (!isEmail) {
        dynamic result;
        try {
          result = await client.rpc(
            'resolve_email_for_username',
            params: {'p_username': trimmed},
          );
        } on PostgrestException catch (e) {
          throw AppAuthException(
            'Username sign-in requires running the latest supabase_schema.sql (${e.message}).',
          );
        }
        final resolved = result?.toString().trim() ?? '';
        if (resolved.isEmpty) {
          throw const AppAuthException(
            'No account found with that username.',
          );
        }
        resolvedEmail = resolved;
      }

      try {
        await client.auth.signInWithPassword(
          email: resolvedEmail,
          password: password,
        );
        await fetchUserProfile();
        return;
      } on AuthException catch (e) {
        throw AppAuthException(e.message);
      }
    }

    if (!isEmail) {
      final byUsername = _mockUsersByUsername[trimmed.toLowerCase()];
      if (byUsername != null) {
        setMockUser(byUsername);
        return;
      }
      final isAdminUsername = trimmed.toLowerCase() == 'admin';
      final mockEmail = isAdminUsername
          ? 'admin@pokemart.com'
          : '${trimmed.toLowerCase()}@pokemart.com';
      setMockUser(
        User(
          id: 'mock-user-${mockEmail.hashCode.abs()}',
          appMetadata: {
            'provider': 'email',
            'role': isAdminUsername ? 'admin' : 'customer',
          },
          userMetadata: {
            'username': trimmed,
            'email': mockEmail,
            'role': isAdminUsername ? 'admin' : 'customer',
          },
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: mockEmail,
        ),
      );
      return;
    }

    final existing = _mockUsersByEmail[trimmed.toLowerCase()];
    if (existing != null) {
      setMockUser(existing);
      return;
    }

    final isMockAdmin = trimmed.toLowerCase() == 'admin@pokemart.com';
    setMockUser(
      User(
        id: 'mock-user-${trimmed.hashCode.abs()}',
        appMetadata: {
          'provider': 'email',
          'role': isMockAdmin ? 'admin' : 'customer',
        },
        userMetadata: {
          'username': trimmed.split('@').first,
          'email': trimmed,
          'role': isMockAdmin ? 'admin' : 'customer',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: trimmed,
      ),
    );
  }

  /// Authenticates using email and password credentials.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return signInWithIdentifier(identifier: email, password: password);
  }

  /// Registers a new customer account (`role_id = 1` assigned by database trigger).
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String username = '',
    String? firstName,
    String? lastName,
  }) async {
    final client = _client;
    final trimmedEmail = email.trim();
    final trimmedUsername = username.trim();
    final trimmedFirst = firstName?.trim() ?? '';
    final trimmedLast = lastName?.trim() ?? '';
    final fullName = [trimmedFirst, trimmedLast]
        .where((s) => s.isNotEmpty)
        .join(' ');

    if (client != null && !_isMockMode) {
      try {
        final response = await client.auth.signUp(
          email: trimmedEmail,
          password: password,
          data: {
            if (trimmedUsername.isNotEmpty) 'username': trimmedUsername,
            'firstname': trimmedFirst,
            'lastname': trimmedLast,
            if (trimmedFirst.isNotEmpty) 'first_name': trimmedFirst,
            if (trimmedLast.isNotEmpty) 'last_name': trimmedLast,
            if (fullName.isNotEmpty || trimmedUsername.isNotEmpty)
              'full_name': fullName.isNotEmpty ? fullName : trimmedUsername,
          },
        );
        if (response.session != null) {
          await fetchUserProfile();
        }
        return;
      } on AuthException catch (e) {
        throw AppAuthException(e.message);
      } on PostgrestException catch (e) {
        throw AppAuthException(e.message);
      }
    }

    final mockUser = User(
      id: 'mock-user-${trimmedEmail.hashCode.abs()}',
      appMetadata: const {'provider': 'email', 'role': 'customer'},
      userMetadata: {
        if (trimmedUsername.isNotEmpty) 'username': trimmedUsername,
        'firstname': trimmedFirst,
        'lastname': trimmedLast,
        if (trimmedFirst.isNotEmpty) 'first_name': trimmedFirst,
        if (trimmedLast.isNotEmpty) 'last_name': trimmedLast,
        'full_name': fullName.isNotEmpty ? fullName : trimmedUsername,
        'email': trimmedEmail,
        'role': 'customer',
      },
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: trimmedEmail,
    );
    _mockUsersByEmail[trimmedEmail.toLowerCase()] = mockUser;
    if (trimmedUsername.isNotEmpty) {
      _mockUsersByUsername[trimmedUsername.toLowerCase()] = mockUser;
    }
    setMockUser(mockUser);
  }

  /// Initiates third-party OAuth authentication with Google.
  Future<bool> signInWithGoogle({String? redirectTo}) async {
    final client = _client;
    if (client != null && !_isMockMode) {
      try {
        final redirectUrl = redirectTo ??
            (kIsWeb ? null : 'io.supabase.pokemart://login-callback');
        return await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectUrl,
        );
      } on AuthException catch (e) {
        throw AppAuthException(e.message);
      }
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
    if (client != null && !_isMockMode) {
      try {
        final redirectUrl = redirectTo ??
            (kIsWeb ? null : 'io.supabase.pokemart://login-callback');
        return await client.auth.signInWithOAuth(
          OAuthProvider.github,
          redirectTo: redirectUrl,
        );
      } on AuthException catch (e) {
        throw AppAuthException(e.message);
      }
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

  /// Terminates the active user session and clears cached profile state.
  Future<void> signOut() async {
    _mockUser = null;
    _cachedProfile = null;
    final client = _client;
    if (client != null && !_isMockMode) {
      try {
        await client.auth.signOut();
      } on AuthException catch (e) {
        throw AppAuthException(e.message);
      }
    }
    _mockStreamController.add(AuthChangeKind.signedOut);
  }

  /// Injects a mock user session for unit and widget tests.
  @visibleForTesting
  void setMockCredentials({
    required String id,
    required String email,
    String username = '',
    String firstName = '',
    String lastName = '',
    String provider = 'email',
    String role = 'customer',
  }) {
    setMockUser(
      User(
        id: id,
        appMetadata: {'provider': provider, 'role': role},
        userMetadata: {
          'username': username,
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'role': role,
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
    );
  }

  /// Injects a mock Supabase [User] for deterministic unit and widget tests.
  @visibleForTesting
  void setMockUser(User? user) {
    _mockUser = user;
    if (user == null) {
      _cachedProfile = null;
    } else {
      final isMockAdmin =
          user.email?.toLowerCase() == 'admin@pokemart.com' ||
              user.userMetadata?['role']?.toString().toLowerCase() == 'admin';
      _cachedProfile = _profileFromMetadata(user, isAdminRole: isMockAdmin);
    }
    _mockStreamController.add(
      user != null ? AuthChangeKind.signedIn : AuthChangeKind.signedOut,
    );
  }

  /// Releases internal stream resources.
  void dispose() {
    _mockStreamController.close();
  }
}
