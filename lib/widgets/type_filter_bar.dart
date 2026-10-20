import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';

/// Horizontally scrollable filter bar styled after Shadcn badge controls.
///
/// Features:
/// - 12px (0.75rem) pill badges with micro-animations.
/// - Available starter types: Grass, Fire, Water, Poison, Flying, etc.
/// - Clear button appears dynamically when a filter is active.
class TypeFilterBar extends ConsumerWidget {
  const TypeFilterBar({super.key});

  static const List<String> availableTypes = [
    'Grass',
    'Fire',
    'Water',
    'Poison',
    'Flying',
    'Ground',
    'Ghost',
    'Fighting',
    'Dark',
    'Fairy',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(selectedTypeFilterProvider);
    final notifier = ref.read(selectedTypeFilterProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // "All" filter chip
            _FilterChip(
              label: 'All',
              isActive: activeFilter == null,
              onTap: () => notifier.clearFilter(),
            ),
            const SizedBox(width: 6),

            // Clear Filter button (Smoothly visible next to All when filter is active)
            if (activeFilter != null) ...[
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => notifier.clearFilter(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      SizedBox(width: 4),
                      Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Elemental types chips
            ...availableTypes.map((type) {
              final isSelected =
                  activeFilter?.toLowerCase() == type.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: _FilterChip(
                  label: type,
                  isActive: isSelected,
                  onTap: () => notifier.selectType(type.toLowerCase()),
                ),
              );
            }),

          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.white : const Color(0xFF475569),
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
