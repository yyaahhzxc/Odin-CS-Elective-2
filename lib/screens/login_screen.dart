import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_state.dart';

/// Screen managing user authentication (Sign In, Create Account, and Google OAuth).
///
/// Designed with a minimalist, shadcn-inspired aesthetic featuring neutral palettes,
/// crisp borders, responsive layout constraints, and standard form validation.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _formKey.currentState?.reset();
    });
    AuthScope.of(context).clearError();
  }

  Future<void> _submitForm(AuthManager auth) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success = false;
    if (_isSignUpMode) {
      final username = _usernameController.text.trim();
      success = await auth.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );
    } else {
      success = await auth.signInWithEmail(
        email: email,
        password: password,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSignUpMode
                ? 'Account created successfully! Welcome, ${auth.displayName}.'
                : 'Welcome back, ${auth.displayName}!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn(AuthManager auth) async {
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed in with Google as ${auth.displayName}!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    final auth = AuthScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.isAuthenticated ? 'Account' : (_isSignUpMode ? 'Create Account' : 'Sign In')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Shop',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: auth.isAuthenticated
                  ? _buildProfileView(context, auth, colorScheme, theme)
                  : _buildAuthForm(context, auth, colorScheme, theme, isDark),
            ),
          ),
        ),
      ),
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
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Return to Shop'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
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

  Widget _buildAuthForm(
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
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
              _isSignUpMode ? 'Create an Account' : 'Welcome Back',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isSignUpMode
                  ? 'Enter your details below to register your PokéMart account.'
                  : 'Enter your credentials below to access your account.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Error Banner
            if (auth.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 20, color: colorScheme.onErrorContainer),
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
              const SizedBox(height: 16),
            ],

            // Username Field (Sign-up only)
            if (_isSignUpMode) ...[
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
                decoration: const InputDecoration(
                  hintText: 'e.g. red_trainer',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Email Field
            Text(
              'Email',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.mail_outline, size: 20),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

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
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitForm(auth),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
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
            const SizedBox(height: 24),

            // Primary Form Submit Button
            FilledButton(
              onPressed: auth.isLoading ? null : () => _submitForm(auth),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: auth.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isSignUpMode ? 'Create Account' : 'Sign In'),
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
            const SizedBox(height: 20),

            // Google 3rd-Party OAuth Button
            OutlinedButton(
              onPressed: auth.isLoading ? null : () => _handleGoogleSignIn(auth),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: BorderSide(
                  color: colorScheme.outlineVariant,
                ),
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
            const SizedBox(height: 20),

            // Mode Toggle (Sign In <-> Create Account)
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  _isSignUpMode
                      ? 'Already have an account?'
                      : "Don't have an account?",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: auth.isLoading ? null : _toggleMode,
                  child: Text(
                    _isSignUpMode ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            // Continue as Guest link
            Center(
              child: TextButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/');
                  }
                },
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
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
