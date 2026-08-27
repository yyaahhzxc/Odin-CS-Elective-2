import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_breakpoints.dart';
import '../constants/app_colors.dart';

/// An adaptive application bar that renders either a Material [AppBar] or a
/// [CupertinoNavigationBar] depending on target platform detection.
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title text displayed in the header.
  final String title;

  /// Optional leading widget override.
  final Widget? leading;

  /// Optional actions list.
  final List<Widget>? actions;

  const AdaptiveAppBar({
    super.key,
    this.title = 'responsivedashboard',
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= AppBreakpoints.tabletMaxWidth;
    final bool isCupertino =
        Theme.of(context).platform == TargetPlatform.iOS;

    if (isCupertino) {
      return CupertinoNavigationBar(
        backgroundColor: AppColors.appBarBackground,
        middle: Text(
          title,
          style: const TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
            letterSpacing: 0.5,
          ),
        ),
        leading: isDesktop
            ? const SizedBox.shrink()
            : leading ??
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.bars,
                    color: AppColors.textLight,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
        trailing: actions != null && actions!.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              )
            : null,
      );
    }

    return AppBar(
      backgroundColor: AppColors.appBarBackground,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: !isDesktop,
      iconTheme: const IconThemeData(color: AppColors.textLight),
      leading: isDesktop
          ? const SizedBox.shrink()
          : leading ??
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      actions: actions,
    );
  }
}
