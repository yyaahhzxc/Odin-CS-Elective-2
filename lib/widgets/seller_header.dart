import 'package:flutter/material.dart';

/// Presentation widget displaying the CSSEC seller profile banner and council stats.
///
/// Designed with inspiration from the Magis Market seller profile layout,
/// adapted to the Ateneo de Davao Computer Studies Student Executive Council.
///
/// Implemented as a [StatelessWidget] since all council branding and metadata
/// are static and do not change after initialization.
class SellerHeader extends StatelessWidget {
  const SellerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.light
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF334155),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Banner Background with CSSEC Cover Graphic
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      const Color(0xFF4C1D95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Image.asset(
                  'assets/images/cssec_banner.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback gradient if banner asset is unavailable
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            const Color(0xFF3B0764),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Overlapping Council Chameleon Avatar
              Positioned(
                top: 70,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: colorScheme.primaryContainer,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/cssec_logo.jpg',
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.storefront_rounded,
                            size: 40,
                            color: colorScheme.primary,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Spacing for overlapping avatar
          const SizedBox(height: 52),

          // Council Title and Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  'CSSEC Merch Store',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Computer Studies Student Executive Council • AdDU',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Social Handles Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialChip(context, Icons.alternate_email, '@ADDU_CS'),
                    const SizedBox(width: 8),
                    _buildSocialChip(context, Icons.verified_user_outlined, 'Official Store'),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick Statistics Row (Inspired by Magis Market metrics)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(context, Icons.inventory_2_outlined, '6 Items', 'Catalog'),
                      _buildDivider(context),
                      _buildStatItem(context, Icons.star_rounded, '4.9 (140+)', 'Rating'),
                      _buildDivider(context),
                      _buildStatItem(context, Icons.calendar_today_outlined, 'AY 25-26', 'Term'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 24,
      width: 1,
      color: theme.dividerColor.withAlpha(80),
    );
  }
}
