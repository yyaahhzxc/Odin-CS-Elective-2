import 'package:flutter/material.dart';

/// Clean placeholder view displayed when the API returns an empty dataset.
///
/// Adheres strictly to the requirement to handle empty states gracefully.
class EmptyView extends StatelessWidget {
  final String message;

  const EmptyView({
    super.key,
    this.message = 'No starter Pokémon found.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
