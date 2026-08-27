import 'package:flutter/material.dart';
import '../constants/app_breakpoints.dart';
import '../constants/app_colors.dart';
import '../responsive/desktop_body.dart';
import '../responsive/mobile_body.dart';
import '../responsive/responsive_layout.dart';
import '../responsive/tablet_body.dart';
import '../widgets/adaptive_app_bar.dart';
import '../widgets/adaptive_drawer.dart';

/// Main root view for the Responsive and Adaptive Dashboard.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _activeDestination = 'DASHBOARD';

  void _handleDestinationSelected(String destination) {
    setState(() {
      _activeDestination = destination;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= AppBreakpoints.tabletMaxWidth;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const AdaptiveAppBar(
        title: 'responsivedashboard',
      ),
      // Drawer is enabled only on mobile and tablet screen widths
      drawer: isDesktop
          ? null
          : AdaptiveDrawer(
              selectedDestination: _activeDestination,
              onDestinationSelected: _handleDestinationSelected,
            ),
      body: const ResponsiveLayout(
        mobileBody: MobileBody(),
        tabletBody: TabletBody(),
        desktopBody: DesktopBody(),
      ),
    );
  }
}
