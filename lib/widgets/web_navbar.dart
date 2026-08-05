import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'airplane_painters.dart';

class WebNavbar extends StatelessWidget {
  const WebNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showNavLinks = width >= 950;
    final showProfileText = width >= 600;

    return Container(
      height: 64,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width > 700 ? 32 : 16),
      decoration: BoxDecoration(
        color: AppColors.tealDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Brand Logo & Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.accentCream,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(22, 22),
                    painter: AirplaneLineArtPainter(
                      color: AppColors.tealDark,
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'FLIGHT BOOKING',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          // Flexible Middle Space with optional Nav Links
          Expanded(
            child: showNavLinks
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNavLink('Search Flights', isActive: true),
                      const SizedBox(width: 12),
                      _buildNavLink('My Passes'),
                      const SizedBox(width: 12),
                      _buildNavLink('Offers'),
                      const SizedBox(width: 12),
                      _buildNavLink('Support'),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // User Profile
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accentCream,
                child: Icon(Icons.person, color: AppColors.tealDark, size: 18),
              ),
              if (showProfileText) ...[
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ALFHARIZKY FAUZI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Passenger Pass',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String title, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withAlpha(30) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
