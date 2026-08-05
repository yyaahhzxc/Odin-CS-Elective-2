import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/airplane_painters.dart';
import 'web_flight_dashboard.dart';

class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WebFlightDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 600),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  children: [
                    // Left Split Hero Banner (50%)
                    Expanded(
                      child: Container(
                        color: AppColors.tealBackground,
                        child: Stack(
                          children: [
                            // Background Watermark
                            Positioned(
                              right: -40,
                              bottom: -40,
                              width: 380,
                              height: 380,
                              child: CustomPaint(
                                painter: AirplaneWatermarkPainter(
                                  color: Colors.white.withAlpha(20),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(48.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Logo Graphic
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accentCream,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: CustomPaint(
                                            size: const Size(30, 30),
                                            painter: AirplaneLineArtPainter(
                                              color: AppColors.tealDark,
                                              strokeWidth: 2.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Text(
                                        'FLIGHT BOOKING',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Center Hero Text
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'BOOK YOUR',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'NEXT FLIGHT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 3.0,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Manage your tickets, choose round-trip or one-way flights, and preview your instant boarding passes online.',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Footer note
                                  const Text(
                                    '© 2026 Flight Booking Portal',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right Split Login Form (50%)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56.0, vertical: 48.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: AppColors.tealDark,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Please sign in to access your flight bookings.',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Username / Email Input
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline, color: AppColors.tealPrimary, size: 20),
                                hintText: 'Username / Email',
                                hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.tealPrimary, width: 2),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Password Input
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline, color: AppColors.tealPrimary, size: 20),
                                hintText: 'Password',
                                hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.tealPrimary, width: 2),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // LOGIN Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _navigateToDashboard,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tealBackground,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: AppColors.tealDark.withAlpha(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  'LOGIN TO DASHBOARD',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Not a member ? Join now
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Not a member ? ',
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: _navigateToDashboard,
                                  child: const Text(
                                    'Join now',
                                    style: TextStyle(
                                      color: AppColors.tealPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
