import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/boarding_pass_ticket.dart';
import 'web_flight_dashboard.dart';

class BoardingPassScreen extends StatelessWidget {
  const BoardingPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return const WebFlightDashboard();
        } else {
          return const MobileBoardingPassView();
        }
      },
    );
  }
}

class MobileBoardingPassView extends StatelessWidget {
  const MobileBoardingPassView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tealBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Back Arrow & Skip Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate back to Screen 1 (Login)
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Main Boarding Pass Ticket Container
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: const BoardingPassTicketCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
