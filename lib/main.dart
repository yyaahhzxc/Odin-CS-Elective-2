import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/responsive_home.dart';

void main() {
  runApp(const FlightBookingApp());
}

class FlightBookingApp extends StatelessWidget {
  const FlightBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Booking UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.tealPrimary,
        scaffoldBackgroundColor: AppColors.tealBackground,
        fontFamily: 'Roboto',
      ),
      home: const ResponsiveHome(),
    );
  }
}
