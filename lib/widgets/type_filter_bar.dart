import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';

/// Collapsible elemental type filter bar with color-coded chips.
class TypeFilterBar extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;

  const TypeFilterBar({
    super.key,
    this.isExpanded = false,
    this.onToggle,
  });

  /// Official Pokémon types in canonical reference order.
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
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(selectedTypeFilterProvider);
    final notifier = ref.read(selectedTypeFilterProvider.notifier);
    final filteredPokemons = ref.watch(filteredPokemonsProvider);
    final filteredCount = filteredPokemons.length;

    return Container(
      padding: const EdgeInsets.all(14.0),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  key: const Key('toggle_type_filter_title_button'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: onToggle,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filter by Type',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (activeFilter != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$filteredCount filtered ${_capitalize(activeFilter)}-type Pokémon found',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              InkWell(
                key: const Key('toggle_type_filter_button'),
                borderRadius: BorderRadius.circular(8),
                onTap: onToggle,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isExpanded ? 'Collapse' : 'Expand',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: [
                          _ColorCodedTypeChip(
                            key: const Key('type_chip_all'),
                            label: 'ALL',
                            chipColor: const Color(0xFF475569),
                            isActive: activeFilter == null,
                            onTap: () => notifier.clearFilter(),
                          ),
                          ...orderedTypes.map((type) {
                            final isSelected =
                                activeFilter?.toLowerCase() == type.toLowerCase();
                            final color = _getTypeColor(type);

                            return _ColorCodedTypeChip(
                              key: Key('type_chip_${type.toLowerCase()}'),
                              label: type.toUpperCase(),
                              chipColor: color,
                              isActive: isSelected,
                              onTap: () => notifier.selectType(type.toLowerCase()),
                            );
                          }),
                        ],
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
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

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
  }
}

class _ColorCodedTypeChip extends StatefulWidget {
  final String label;
  final Color chipColor;
  final bool isActive;
  final VoidCallback onTap;

  const _ColorCodedTypeChip({
    super.key,
    required this.label,
    required this.chipColor,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ColorCodedTypeChip> createState() => _ColorCodedTypeChipState();
}

class _ColorCodedTypeChipState extends State<_ColorCodedTypeChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.chipColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : (widget.isActive ? 1.03 : 1.0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: widget.isActive ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color,
              width: 1.5,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: widget.isActive ? Colors.white : color,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
