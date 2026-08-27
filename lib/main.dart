import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'views/dashboard_page.dart';

void main() {
  runApp(const ResponsiveDashboardApp());
}

/// Root application widget initializing themes and entry point.
class ResponsiveDashboardApp extends StatelessWidget {
  const ResponsiveDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          surface: AppColors.scaffoldBackground,
          primary: AppColors.appBarBackground,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}
