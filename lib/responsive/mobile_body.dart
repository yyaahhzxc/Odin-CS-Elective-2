import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/wireframe_box.dart';
import '../widgets/wireframe_tile.dart';

/// Mobile layout representation (< 600px).
///
/// Features a 2x2 top grid of wireframe boxes followed by 4 vertically
/// expanding wireframe rectangular tiles that fill the remaining screen height.
class MobileBody extends StatelessWidget {
  const MobileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Top 2x2 Grid of 4 Wireframe Boxes
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) => const WireframeBox(),
                    ),
                    const SizedBox(height: 12.0),
                    // Bottom 4 Wireframe Tiles
                    ...List.generate(4, (index) {
                      final bool isLast = index == 3;
                      return WireframeTile(
                        height: 72.0,
                        margin: EdgeInsets.only(bottom: isLast ? 0.0 : 12.0),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
