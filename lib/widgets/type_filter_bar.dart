import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';
import 'type_badge.dart';

/// Expandable type filter bar styled after Shadcn collapsible controls.
///
/// Features:
/// - Arranges all 18 official elemental types in the exact canonical reference order:
///   Normal, Fire, Water, Electric, Grass, Ice, Fighting, Poison, Ground, Flying,
///   Psychic, Bug, Rock, Ghost, Dragon, Dark, Steel, Fairy.
/// - Non-horizontal scrolling: Expands smoothly downwards on mobile/desktop.
/// - Expand/collapse animation with rotating chevron indicator.
/// - Micro-animations on selection with visual feedback and instant reactivity.
class TypeFilterBar extends ConsumerStatefulWidget {
  const TypeFilterBar({super.key});

  /// The 18 official Pokémon elemental types in the required reference order.
  static const List<String> orderedTypes = [
    'Normal',
    'Fire',
    'Water',
    'Electric',
    'Grass',
    'Ice',
    'Fighting',
    'Poison',
    'Ground',
    'Flying',
    'Psychic',
    'Bug',
    'Rock',
    'Ghost',
    'Dragon',
    'Dark',
    'Steel',
    'Fairy',
  ];

  @override
  ConsumerState<TypeFilterBar> createState() => _TypeFilterBarState();
}

class _TypeFilterBarState extends ConsumerState<TypeFilterBar> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(selectedTypeFilterProvider);
    final notifier = ref.read(selectedTypeFilterProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Toggle Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                  color: Color(0xFF0F172A),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Filter by Type',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),

                // Active filter indicator badge
                if (activeFilter != null) ...[
                  TypeBadge(typeName: activeFilter),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => notifier.clearFilter(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded,
                              size: 11, color: Color(0xFF475569)),
                          SizedBox(width: 3),
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  const Text(
                    '(All Types)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),

                const Spacer(),

                // Expand / Collapse Action Button
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _toggleExpanded,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? 'Collapse' : 'Expand',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Downward Expandable Panel with Micro-Animations
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: _isExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 14.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            // "ALL" Option Chip
                            _AnimatedTypeChip(
                              label: 'ALL',
                              isActive: activeFilter == null,
                              onTap: () => notifier.clearFilter(),
                            ),

                            // All 18 Elemental Types in exact order
                            ...TypeFilterBar.orderedTypes.map((type) {
                              final isSelected = activeFilter?.toLowerCase() ==
                                  type.toLowerCase();
                              return _AnimatedTypeChip(
                                key: Key('type_chip_${type.toLowerCase()}'),
                                label: type.toUpperCase(),
                                typeName: type,
                                isActive: isSelected,
                                onTap: () =>
                                    notifier.selectType(type.toLowerCase()),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Shadcn-styled pill chip with animated scale and color transition.
class _AnimatedTypeChip extends StatefulWidget {
  final String label;
  final String? typeName;
  final bool isActive;
  final VoidCallback onTap;

  const _AnimatedTypeChip({
    super.key,
    required this.label,
    this.typeName,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_AnimatedTypeChip> createState() => _AnimatedTypeChipState();
}

class _AnimatedTypeChipState extends State<_AnimatedTypeChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : (widget.isActive ? 1.04 : 1.0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: widget.isActive ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isActive
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.typeName != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _getTypeColor(widget.typeName!),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      widget.isActive ? FontWeight.w700 : FontWeight.w600,
                  color: widget.isActive
                      ? Colors.white
                      : const Color(0xFF475569),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return const Color(0xFF77CC55);
      case 'poison':
        return const Color(0xFFAA5599);
      case 'fire':
        return const Color(0xFFFF4422);
      case 'water':
        return const Color(0xFF3399FF);
      case 'flying':
        return const Color(0xFF8899FF);
      case 'bug':
        return const Color(0xFFAABB22);
      case 'normal':
        return const Color(0xFFAAAA99);
      case 'electric':
        return const Color(0xFFFFCC33);
      case 'ground':
        return const Color(0xFFDDBB77);
      case 'fairy':
        return const Color(0xFFEE99EE);
      case 'fighting':
        return const Color(0xFFBB5544);
      case 'psychic':
        return const Color(0xFFFF5599);
      case 'rock':
        return const Color(0xFFBBAA66);
      case 'steel':
        return const Color(0xFFAAAABB);
      case 'ice':
        return const Color(0xFF66CCFF);
      case 'ghost':
        return const Color(0xFF6666BB);
      case 'dragon':
        return const Color(0xFF7766EE);
      case 'dark':
        return const Color(0xFF775544);
      default:
        return const Color(0xFF888888);
    }
  }
}
