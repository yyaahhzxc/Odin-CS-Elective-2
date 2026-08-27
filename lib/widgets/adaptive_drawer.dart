import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Navigation drawer and desktop sidebar component.
///
/// Adapts its presentation between a slide-out mobile/tablet drawer and a
/// persistent left sidebar on desktop screen sizes with clean, straight edges.
class AdaptiveDrawer extends StatelessWidget {
  /// Indicates whether the widget is rendered as a persistent desktop sidebar.
  final bool isPermanentSidebar;

  /// Optional callback invoked when a navigation destination is selected.
  final ValueChanged<String>? onDestinationSelected;

  /// Currently active destination identifier.
  final String selectedDestination;

  const AdaptiveDrawer({
    super.key,
    this.isPermanentSidebar = false,
    this.onDestinationSelected,
    this.selectedDestination = 'DASHBOARD',
  });

  @override
  Widget build(BuildContext context) {
    final bool isCupertino =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    final Widget content = Material(
      color: AppColors.drawerBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 36.0),
            // Header Heart Icon
            Center(
              child: Icon(
                isCupertino ? CupertinoIcons.heart_fill : Icons.favorite,
                size: 52.0,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 48.0),
            // Navigation Menu Items
            _buildNavItem(
              context: context,
              title: 'DASHBOARD',
              icon: isCupertino ? CupertinoIcons.home : Icons.home,
              isSelected: selectedDestination == 'DASHBOARD',
            ),
            _buildNavItem(
              context: context,
              title: 'SETTINGS',
              icon: isCupertino ? CupertinoIcons.settings : Icons.settings,
              isSelected: selectedDestination == 'SETTINGS',
            ),
            _buildNavItem(
              context: context,
              title: 'ABOUT',
              icon: isCupertino
                  ? CupertinoIcons.info_circle
                  : Icons.info_outline,
              isSelected: selectedDestination == 'ABOUT',
            ),
            _buildNavItem(
              context: context,
              title: 'LOGOUT',
              icon: isCupertino
                  ? CupertinoIcons.square_arrow_right
                  : Icons.logout,
              isSelected: selectedDestination == 'LOGOUT',
            ),
          ],
        ),
      ),
    );

    if (isPermanentSidebar) {
      return Container(
        width: 240.0,
        decoration: const BoxDecoration(
          color: AppColors.drawerBackground,
          borderRadius: BorderRadius.zero,
          border: Border(
            right: BorderSide(
              color: Color(0xFFE0E0E0),
              width: 1.0,
            ),
          ),
        ),
        child: content,
      );
    }

    return Drawer(
      backgroundColor: AppColors.drawerBackground,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: content,
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return MouseRegion(
      cursor: kIsWeb || Theme.of(context).platform == TargetPlatform.windows ||
              Theme.of(context).platform == TargetPlatform.macOS ||
              Theme.of(context).platform == TargetPlatform.linux
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.textDark : AppColors.textMuted,
          size: 22.0,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13.0,
            letterSpacing: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 2.0),
        dense: true,
        onTap: () {
          if (!isPermanentSidebar) {
            Navigator.of(context).pop();
          }
          onDestinationSelected?.call(title);
        },
      ),
    );
  }
}
