import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';

/// Empty details page fulfilling the first-half exam milestone requirement:
/// "Half of the project (incl. Design theme, home screen, routing to an empty details page)".
///
/// Implemented as a [StatelessWidget] with an [AppBar] and placeholder content.
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Scaffold with an AppBar on every screen as required
      appBar: AppBar(
        title: Text(product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Shop',
          onPressed: () {
            // Navigation 2.0 back navigation
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      // Empty details screen placeholder for the first-half milestone
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: ${product.formattedPrice}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Details page placeholder for the first-half milestone.\nFull product details, cart, and checkout will be implemented in the second half.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
