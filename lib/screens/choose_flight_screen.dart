import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/airplane_painters.dart';
import 'boarding_pass_screen.dart';
import 'web_flight_dashboard.dart';

class ChooseFlightScreen extends StatelessWidget {
  const ChooseFlightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return const WebFlightDashboard();
        } else {
          return const MobileChooseFlightView();
        }
      },
    );
  }
}

class MobileChooseFlightView extends StatefulWidget {
  const MobileChooseFlightView({super.key});

  @override
  State<MobileChooseFlightView> createState() => _MobileChooseFlightViewState();
}

class _MobileChooseFlightViewState extends State<MobileChooseFlightView> {
  bool isRoundTrip = true;
  int selectedFlightIndex = 0;

  void _navigateToBoardingPass() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BoardingPassScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.tealDark, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    onPressed: _navigateToBoardingPass,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.tealDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Hero Card: CHOOSE YOUR FLIGHT
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.tealBackground,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tealDark.withAlpha(51),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background Airplane Watermark
                          Positioned(
                            right: -20,
                            top: -20,
                            width: 220,
                            height: 200,
                            child: CustomPaint(
                              painter: AirplaneWatermarkPainter(
                                color: Colors.white.withAlpha(31),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'CHOOSE\nYOUR FLIGHT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    height: 1.15,
                                    letterSpacing: 1.2,
                                  ),
                                ),

                                // Segmented Toggle Pills: ROUND TRIP vs ONE WAY
                                Container(
                                  height: 44,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(51),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() => isRoundTrip = true),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isRoundTrip ? Colors.white : Colors.transparent,
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                            child: Text(
                                              'ROUND TRIP',
                                              style: TextStyle(
                                                color: isRoundTrip ? AppColors.tealDark : Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() => isRoundTrip = false),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: !isRoundTrip ? Colors.white : Colors.transparent,
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                            child: Text(
                                              'ONE WAY',
                                              style: TextStyle(
                                                color: !isRoundTrip ? AppColors.tealDark : Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Flight Selection Option 1
                    _buildFlightCard(
                      index: 0,
                      fromCity: 'Los Angeles',
                      fromCode: 'SFO',
                      fromTime: '21.30',
                      fromDate: '',
                      toCity: 'Los Angeles',
                      toCode: 'NYC',
                      toTime: '21.30',
                      toDate: 'Sat-10 September',
                    ),

                    const SizedBox(height: 32),

                    // Flight Selection Option 2
                    _buildFlightCard(
                      index: 1,
                      fromCity: 'Los Angeles',
                      fromCode: 'NYC',
                      fromTime: '21.30',
                      fromDate: 'Sat-10 August',
                      toCity: 'Los Angeles',
                      toCode: 'SFO',
                      toTime: '21.30',
                      toDate: 'Sat-11 September',
                    ),

                    const SizedBox(height: 48),

                    // BOOK NOW Button
                    SizedBox(
                      width: 150,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _navigateToBoardingPass,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealBackground,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          'BOOK NOW',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightCard({
    required int index,
    required String fromCity,
    required String fromCode,
    required String fromTime,
    required String fromDate,
    required String toCity,
    required String toCode,
    required String toTime,
    required String toDate,
  }) {
    final isSelected = selectedFlightIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedFlightIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.tealPrimary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Origin City
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fromCity,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    fromCode,
                    style: const TextStyle(
                      color: AppColors.tealDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    fromTime,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                    ),
                  ),
                  if (fromDate.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      fromDate,
                      style: const TextStyle(
                        color: AppColors.tealDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Middle Flight Trajectory Arrow
            SizedBox(
              width: 70,
              height: 40,
              child: CustomPaint(
                painter: FlightTrajectoryPainter(
                  color: AppColors.tealLight,
                  isReturn: index == 1,
                ),
              ),
            ),

            // Right Destination City
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    toCity,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    toCode,
                    style: const TextStyle(
                      color: AppColors.tealDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    toTime,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                    ),
                  ),
                  if (toDate.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      toDate,
                      style: const TextStyle(
                        color: AppColors.tealDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
