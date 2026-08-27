import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/wireframe_box.dart';
import '../widgets/wireframe_tile.dart';

/// Tablet layout representation (600px - 1100px).
///
/// Features a single 4-column horizontal row of wireframe boxes followed by
/// 4 proportionally expanding wireframe rectangular tiles that dynamically
/// fill the entire remaining vertical screen height.
class TabletBody extends StatelessWidget {
  const TabletBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackground,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top 4-column single-row grid of wireframe boxes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    margin: EdgeInsets.only(bottom: isLast ? 0.0 : 16.0),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
