import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../state/auth_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';

/// Screen managing user authentication (Sign In, Create Account, Google & GitHub OAuth, and Profile).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _setMode(bool isSignUp) {
    if (_isSignUpMode == isSignUp) return;
    setState(() {
      _isSignUpMode = isSignUp;
      _formKey.currentState?.reset();
    });
    ref.read(authProvider).clearError();
  }

  void _navigateBackOrHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go('/');
    }
  }

  Future<void> _submitForm(AuthManager auth) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUpMode) {
      final username = _usernameController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      final success = await auth.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
      );

      if (!mounted) return;

      if (success) {
        if (auth.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome to PokéMart, ${auth.displayName}!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _navigateBackOrHome();
        } else {
          // Supabase email confirmation required before session activation
          _showEmailConfirmationNotice(email);
        }
      }
    } else {
      final success = await auth.signInWithIdentifier(
        identifier: email,
        password: password,
      );

      if (!mounted) return;

      if (success && auth.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${auth.displayName}!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _navigateBackOrHome();
      }
    }
  }

  void _showEmailConfirmationNotice(String email) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.mark_email_read_outlined, size: 40),
        title: const Text('Confirm Your Email'),
        content: Text(
          'We sent a confirmation link to $email. Please click the link in your email to activate your account and sign in.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _setMode(false);
            },
            child: const Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(AuthManager auth) async {
    final success = await auth.signInWithGoogle();
    if (success && auth.isAuthenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed in with Google as ${auth.displayName}!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _navigateBackOrHome();
    }
  }

  Future<void> _handleGitHubSignIn(AuthManager auth) async {
    final success = await auth.signInWithGitHub();
    if (success && auth.isAuthenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed in with GitHub as ${auth.displayName}!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _navigateBackOrHome();
    }
  }

  Future<void> _handleSignOut(AuthManager auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await auth.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed out.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final auth = ref.watch(authProvider);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          auth.isAuthenticated
              ? 'Account'
              : (_isSignUpMode ? 'Create Account' : 'Sign In'),
        ),
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: _navigateBackOrHome,
              )
            : null,
        actions: !auth.isAuthenticated
            ? [
                _buildThemeToggleButton(theme, colorScheme),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      bottomNavigationBar:
          auth.isAuthenticated ? const AppBottomNav(currentIndex: 2) : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: auth.isAuthenticated
                    ? KeyedSubtree(
                        key: const ValueKey<String>('profile-view'),
                        child: _buildProfileView(
                          context,
                          auth,
                          colorScheme,
                          theme,
                        ),
                      )
                    : KeyedSubtree(
                        key: const ValueKey<String>('auth-card'),
                        child: _buildAuthCard(
                          context,
                          auth,
                          colorScheme,
                          theme,
                          isDark,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleButton(ThemeData theme, ColorScheme colorScheme) {
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.pogoCoinGold : colorScheme.primary;
    final tintBg = isDark
        ? AppTheme.pogoCoinGold.withAlpha(28)
        : colorScheme.primary.withAlpha(24);

    return IconButton(
      style: IconButton.styleFrom(backgroundColor: tintBg),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey<bool>(isDark),
          color: accentColor,
          size: 21,
        ),
      ),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: () {
        final current = ref.read(themeModeProvider);
        ref.read(themeModeProvider.notifier).state =
            current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      },
    );
  }

  Widget _buildProfileView(
    BuildContext context,
    AuthManager auth,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final email = auth.email ?? 'No email on record';
    final displayName = auth.displayName;
    final username = auth.username;
    final provider = auth.provider;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (username != null && username.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '@$username',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Signed in via ${provider.toUpperCase()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: auth.isAdmin
                        ? colorScheme.tertiaryContainer
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Role: ${auth.role.toUpperCase()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: auth.isAdmin
                          ? colorScheme.onTertiaryContainer
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _navigateBackOrHome,
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Return to Shop'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              if (auth.isAdmin) {
                context.go('/admin/orders');
              } else {
                context.push('/orders');
              }
            },
            icon: Icon(
              auth.isAdmin
                  ? Icons.assignment_outlined
                  : Icons.receipt_long_outlined,
            ),
            label: Text(
              auth.isAdmin ? 'Manage All Orders' : 'My Order History',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: auth.isLoading ? null : () => _handleSignOut(auth),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard(
    BuildContext context,
    AuthManager auth,
    ColorScheme colorScheme,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand/Header Icon
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isSignUpMode ? 'Create an Account' : 'Welcome Back, Trainer!',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isSignUpMode
                ? 'Enter your trainer details below to register your PokéMart account.'
                : 'Enter your credentials below to access your account.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Shadcn-style Segmented Tab Control (Sign In | Sign Up)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Sign In',
                    isSelected: !_isSignUpMode,
                    onTap: () => _setMode(false),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: 'Sign Up',
                    isSelected: _isSignUpMode,
                    onTap: () => _setMode(true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Error Banner with smooth expand/collapse
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: auth.errorMessage != null
                  ? Padding(
                      key: ValueKey<String>(auth.errorMessage!),
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              colorScheme.errorContainer.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 20,
                              color: colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey<String>('no-error'),
                    ),
            ),
          ),

          // Form fields wrapped in AutofillGroup
          AutofillGroup(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sign-Up Specific Fields (animated expand/collapse)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isSignUpMode
                          ? Column(
                              key: const ValueKey<String>('signup-top-fields'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // First Name & Last Name Fields (Responsive Row)
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isNarrow = constraints.maxWidth < 340;
                                    if (isNarrow) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _buildFirstNameField(theme),
                                          const SizedBox(height: 14),
                                          _buildLastNameField(theme),
                                        ],
                                      );
                                    }
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _buildFirstNameField(theme),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildLastNameField(theme),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),

                                // Username Field
                                Text(
                                  'Username',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _usernameController,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.username],
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. red_trainer',
                                    prefixIcon:
                                        Icon(Icons.alternate_email, size: 20),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a username';
                                    }
                                    final trimmed = value.trim();
                                    if (trimmed.contains(' ')) {
                                      return 'Username cannot contain spaces';
                                    }
                                    if (trimmed.contains('@')) {
                                      return 'Username cannot contain @';
                                    }
                                    if (trimmed.length < 3) {
                                      return 'Username must be at least 3 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                              ],
                            )
                          : const SizedBox.shrink(
                              key: ValueKey<String>('signin-top-empty'),
                            ),
                    ),
                  ),

                  // Email Field (Sign Up) or Email/Username Field (Sign In)
                  Text(
                    _isSignUpMode ? 'Email' : 'Email or Username',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: _isSignUpMode
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autofillHints: _isSignUpMode
                        ? const [AutofillHints.email]
                        : const [AutofillHints.username, AutofillHints.email],
                    decoration: InputDecoration(
                      hintText: _isSignUpMode
                          ? 'trainer@example.com'
                          : 'trainer_user',
                      prefixIcon: Icon(
                        _isSignUpMode
                            ? Icons.mail_outline
                            : Icons.person_outline,
                        size: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return _isSignUpMode
                            ? 'Please enter your email'
                            : 'Please enter your email or username';
                      }
                      final trimmed = value.trim();
                      if (trimmed.contains(' ')) {
                        return _isSignUpMode
                            ? 'Email cannot contain spaces'
                            : 'Email or username cannot contain spaces';
                      }
                      if (_isSignUpMode || trimmed.contains('@')) {
                        if (!trimmed.contains('@') || !trimmed.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                      } else if (trimmed.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Password Field
                  Text(
                    'Password',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: _isSignUpMode
                        ? TextInputAction.next
                        : TextInputAction.done,
                    autofillHints: [
                      _isSignUpMode
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    onFieldSubmitted:
                        _isSignUpMode ? null : (_) => _submitForm(auth),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (_isSignUpMode && value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  // Confirm Password Field (Sign-up only, animated expand/collapse)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isSignUpMode
                          ? Column(
                              key: const ValueKey<String>(
                                'signup-confirm-password',
                              ),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 14),
                                Text(
                                  'Confirm Password',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onFieldSubmitted: (_) => _submitForm(auth),
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    prefixIcon:
                                        const Icon(Icons.lock_reset, size: 20),
                                    suffixIcon: IconButton(
                                      tooltip: _obscureConfirmPassword
                                          ? 'Show password'
                                          : 'Hide password',
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(
                              key: ValueKey<String>('signin-confirm-empty'),
                            ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Primary Form Submit Button
                  FilledButton(
                    onPressed: auth.isLoading ? null : () => _submitForm(auth),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: auth.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Text(_isSignUpMode ? 'Create Account' : 'Sign In'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Divider: Or Continue With
          Row(
            children: [
              Expanded(child: Divider(color: colorScheme.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR CONTINUE WITH',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Expanded(child: Divider(color: colorScheme.outlineVariant)),
            ],
          ),
          const SizedBox(height: 18),

          // Google 3rd-Party OAuth Button
          OutlinedButton(
            onPressed: auth.isLoading ? null : () => _handleGoogleSignIn(auth),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomPaint(
                  size: Size(18, 18),
                  painter: _GoogleGLogoPainter(),
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // GitHub 3rd-Party OAuth Button
          OutlinedButton(
            onPressed: auth.isLoading ? null : () => _handleGitHubSignIn(auth),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(18, 18),
                  painter: _GitHubLogoPainter(color: colorScheme.onSurface),
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with GitHub',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First Name',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _firstNameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.givenName],
          decoration: const InputDecoration(
            hintText: 'e.g. Red',
            prefixIcon: Icon(Icons.badge_outlined, size: 20),
          ),
          validator: (value) {
            if (_isSignUpMode && (value == null || value.trim().isEmpty)) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLastNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Name',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _lastNameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.familyName],
          decoration: const InputDecoration(
            hintText: 'e.g. Ketchum',
            prefixIcon: Icon(Icons.badge_outlined, size: 20),
          ),
          validator: (value) {
            if (_isSignUpMode && (value == null || value.trim().isEmpty)) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// Segmented tab pill button for switching modes.
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? colorScheme.surface : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Canvas painter rendering Google's official 4-color 'G' insignia.
class _GoogleGLogoPainter extends CustomPainter {
  const _GoogleGLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = math.min(w, h) / 2;
    final strokeWidth = radius * 0.42;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Blue (right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi / 4, math.pi / 2, false, paint);

    // Green (bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi / 4, math.pi / 2, false, paint);

    // Yellow (left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 3 * math.pi / 4, math.pi / 2, false, paint);

    // Red (top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 5 * math.pi / 4, math.pi / 2, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      center.dx - strokeWidth * 0.1,
      center.dy - strokeWidth / 2,
      radius + strokeWidth * 0.1,
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Canvas painter rendering GitHub's Octocat mark from normalized 24x24 vector geometry.
class _GitHubLogoPainter extends CustomPainter {
  final Color color;

  const _GitHubLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final path = Path()
      ..moveTo(12.0, 0.297)
      ..cubicTo(5.37, 0.297, 0.0, 5.67, 0.0, 12.297)
      ..cubicTo(0.0, 17.6, 3.438, 22.097, 8.205, 23.682)
      ..cubicTo(8.805, 23.795, 9.025, 23.424, 9.025, 23.105)
      ..cubicTo(9.025, 22.82, 9.015, 22.065, 9.01, 21.065)
      ..cubicTo(5.672, 21.789, 4.968, 19.455, 4.968, 19.455)
      ..cubicTo(4.422, 18.07, 3.633, 17.7, 3.633, 17.7)
      ..cubicTo(2.546, 16.956, 3.717, 16.971, 3.717, 16.971)
      ..cubicTo(4.922, 17.055, 5.555, 18.207, 5.555, 18.207)
      ..cubicTo(6.625, 20.042, 8.364, 19.512, 9.05, 19.205)
      ..cubicTo(9.158, 18.429, 9.467, 17.9, 9.81, 17.6)
      ..cubicTo(7.145, 17.3, 4.344, 16.268, 4.344, 11.67)
      ..cubicTo(4.344, 10.36, 4.809, 9.29, 5.579, 8.45)
      ..cubicTo(5.444, 8.147, 5.039, 6.927, 5.684, 5.274)
      ..cubicTo(5.684, 5.274, 6.689, 4.952, 8.984, 6.504)
      ..cubicTo(9.944, 6.237, 10.964, 6.105, 11.984, 6.099)
      ..cubicTo(13.004, 6.105, 14.024, 6.237, 14.984, 6.504)
      ..cubicTo(17.264, 4.952, 18.269, 5.274, 18.269, 5.274)
      ..cubicTo(18.914, 6.927, 18.509, 8.147, 18.389, 8.45)
      ..cubicTo(19.154, 9.29, 19.619, 10.36, 19.619, 11.67)
      ..cubicTo(19.619, 16.28, 16.814, 17.295, 14.144, 17.59)
      ..cubicTo(14.564, 17.95, 14.954, 18.686, 14.954, 19.81)
      ..cubicTo(14.954, 21.416, 14.939, 22.706, 14.939, 23.096)
      ..cubicTo(14.939, 23.411, 15.149, 23.786, 15.764, 23.666)
      ..cubicTo(20.565, 22.092, 24.0, 17.592, 24.0, 12.297)
      ..cubicTo(24.0, 5.67, 18.627, 0.297, 12.0, 0.297)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GitHubLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
