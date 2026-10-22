import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import 'nickname_dialog.dart';
import 'pokeball_icon.dart';
import 'pokedex_toast.dart';
import 'type_badge.dart';

/// A minimalist, borderless Pokemon card styled after PokemonDB with Shadcn touches.
///
/// Features:
/// - Nickname priority: If a nickname exists, it is displayed as the primary title
///   with the actual Pokemon name as the subtitle.
/// - Pokeball indicator: Filled active / Outlined inactive with isolated tap handling
///   and a subtle scale micro-animation.
/// - Edit nickname action accessible directly from card long-press or edit button.
class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;

  const PokemonCard({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(pokemon.id);
    final nickname = ref.watch(nicknamesProvider)[pokemon.id];
    final hasNickname = nickname != null && nickname.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: () => NicknameDialog.show(context, pokemon),
        onTap: () {
          ref.read(selectedPokemonProvider.notifier).selectPokemon(pokemon);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PokemonDetailScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Action Row (Dex ID on left, Pokeball favorite on right)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pokemon.formattedId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    _FavoriteButton(
                      key: Key('favorite_button_${pokemon.id}'),
                      isFavorite: isFavorite,
                      onTap: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(pokemon.id);
                        showPokedexToast(
                          context,
                          !isFavorite
                              ? 'Added ${pokemon.displayName} to Favorites!'
                              : 'Removed ${pokemon.displayName} from Favorites.',
                          icon: PokeballIcon(isFavorite: !isFavorite, size: 16),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 1. Centered High-Resolution Official Artwork Sprite
              SizedBox(
                height: 85,
                child: Center(
                  child: pokemon.imageUrl.isNotEmpty
                      ? Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image_outlined,
                              size: 36,
                              color: Color(0xFF94A3B8),
                            );
                          },
                        )
                      : const Icon(
                          Icons.image_not_supported_outlined,
                          size: 36,
                          color: Color(0xFF94A3B8),
                        ),
                ),
              ),
              const SizedBox(height: 8),

              // 2. Primary Title: Custom Nickname (if set) OR Original Pokemon Name
              Text(
                hasNickname ? nickname : pokemon.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              // 3. Subtitle: Actual Pokemon Name (if custom nickname is present)
              if (hasNickname) ...[
                const SizedBox(height: 1),
                Text(
                  pokemon.displayName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 6),

              // 4. Elemental Type Badges
              Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children: pokemon.types
                    .map((type) => TypeBadge(typeName: type))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive Pokeball favorite button with Shadcn-style micro-scale animation.
class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: PokeballIcon(
            isFavorite: widget.isFavorite,
            size: 16.0,
          ),
        ),
      ),
    );
  }
}
