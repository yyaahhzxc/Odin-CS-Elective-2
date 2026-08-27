import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/adaptive_drawer.dart';
import '../widgets/wireframe_box.dart';
import '../widgets/wireframe_tile.dart';

/// Desktop layout representation (>= 1100px).
///
/// Features a three-column architecture:
/// 1. Persistent left navigation sidebar
/// 2. Center main content with a 4-column box grid and 4 vertically expanded list tiles
/// 3. Right supplementary column with two proportionally expanded wireframe panel cards
class DesktopBody extends StatelessWidget {
  const DesktopBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Persistent Left Navigation Sidebar
          const AdaptiveDrawer(isPermanentSidebar: true),

          // 2. Middle Main Dashboard Content
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 16.0),
              child: Column(
                children: [
                  // Top 4-column single-row grid of wireframe boxes
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) => const WireframeBox(),
                  ),
                  const SizedBox(height: 16.0),
                  // 4 wireframe rectangular tiles dynamically expanding to fill the screen
                  Expanded(
                    child: Column(
                      children: List.generate(4, (index) {
                        final bool isLast = index == 3;
                        return Expanded(
                          child: WireframeTile(
                            margin:
                                EdgeInsets.only(bottom: isLast ? 0.0 : 16.0),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Right Supplementary Column
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 16.0, 20.0, 16.0),
              child: Column(
                children: const [
                  // Upper primary panel card
                  Expanded(
                    flex: 3,
                    child: WireframeBox(
                      color: AppColors.wireframeBox,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Lower secondary panel card
                  Expanded(
                    flex: 2,
                    child: WireframeBox(
                      color: AppColors.wireframeTile,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
