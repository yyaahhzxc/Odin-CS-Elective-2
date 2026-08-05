import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/airplane_painters.dart';
import 'choose_flight_screen.dart';
import 'web_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return const WebLoginScreen();
        } else {
          return const MobileLoginView();
        }
      },
    );
  }
}

class MobileLoginView extends StatefulWidget {
  const MobileLoginView({super.key});

  @override
  State<MobileLoginView> createState() => _MobileLoginViewState();
}

class _MobileLoginViewState extends State<MobileLoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToChooseFlight() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChooseFlightScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tealBackground,
      body: Stack(
        children: [
          // Background Airplane Watermark at top right
          Positioned(
            top: -30,
            right: -60,
            width: 320,
            height: 320,
            child: CustomPaint(
              painter: AirplaneWatermarkPainter(
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          // Background Airplane Watermark at bottom left
          Positioned(
            bottom: -40,
            left: -50,
            width: 350,
            height: 350,
            child: CustomPaint(
              painter: AirplaneWatermarkPainter(
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // Header Graphic: Yellow/Cream Circle with Airplane Line-Art
                  Center(
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            right: 15,
                            bottom: 25,
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                color: AppColors.accentCream,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: AirplaneLineArtPainter(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Input Field 1: Username / Email
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.white70, size: 20),
                      hintText: 'Username / Email',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(153), fontSize: 13),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Field 2: Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70, size: 20),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(153), fontSize: 13),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60, width: 1),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // LOGIN Button
                  SizedBox(
                    width: 160,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _navigateToChooseFlight,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.tealBackground,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Not a member ? Join now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member ? ',
                        style: TextStyle(
                          color: Colors.white.withAlpha(217),
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToChooseFlight,
                        child: const Text(
                          'Join now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Forgot your password ?
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Forgot your password ?',
                      style: TextStyle(
                        color: Colors.white.withAlpha(166),
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Bottom Title Typography: "BOOK YOUR NEXT FLIGHT"
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          'BOOK YOUR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'NEXT FLIGHT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
