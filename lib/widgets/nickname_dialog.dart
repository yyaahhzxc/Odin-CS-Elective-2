import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import 'pokedex_toast.dart';

/// Modal dialog for editing or removing a Pokémon's custom nickname.
class NicknameDialog extends ConsumerStatefulWidget {
  final Pokemon pokemon;

  const NicknameDialog({
    super.key,
    required this.pokemon,
  });

  static Future<void> show(BuildContext context, Pokemon pokemon) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => NicknameDialog(pokemon: pokemon),
    );
  }

  @override
  ConsumerState<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends ConsumerState<NicknameDialog> {
  late final TextEditingController _controller;
  bool _hasInitialNickname = false;

  @override
  void initState() {
    super.initState();
    final currentNickname =
        ref.read(nicknamesProvider)[widget.pokemon.id] ?? '';
    _hasInitialNickname = currentNickname.isNotEmpty;
    _controller = TextEditingController(text: currentNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getSuggestedNicknameHint(Pokemon pokemon) {
    final types = pokemon.types.map((t) => t.toLowerCase()).toSet();
    if (types.contains('fire')) {
      return 'e.g. Blaze, Ember, Pyro...';
    } else if (types.contains('water')) {
      return 'e.g. Splash, Aqua, Bubbles...';
    } else if (types.contains('grass')) {
      return 'e.g. Sprout, Leafy, Ivy...';
    } else if (types.contains('electric')) {
      return 'e.g. Sparky, Volt, Bolt...';
    }
    return 'e.g. Champ, Ace, Buddy...';
  }

  void _saveNickname() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ref.read(nicknamesProvider.notifier).removeNickname(widget.pokemon.id);
      showPokedexToast(
        context,
        'Nickname removed for ${widget.pokemon.displayName}',
        icon: const Icon(Icons.delete_outline_rounded,
            size: 16, color: Color(0xFFEF4444)),
      );
    } else {
      ref
          .read(nicknamesProvider.notifier)
          .setNickname(widget.pokemon.id, text);
      showPokedexToast(
        context,
        'Nickname set to "$text"!',
        icon: const Icon(Icons.check_circle_rounded,
            size: 16, color: Color(0xFF22C55E)),
      );
    }
    Navigator.of(context).pop();
  }

  void _removeNickname() {
    ref.read(nicknamesProvider.notifier).removeNickname(widget.pokemon.id);
    showPokedexToast(
      context,
      'Nickname removed for ${widget.pokemon.displayName}.',
      icon: const Icon(Icons.delete_outline_rounded,
          size: 16, color: Color(0xFFEF4444)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6.0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Nickname',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Set a custom name for ${widget.pokemon.displayName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  hintText: _getSuggestedNicknameHint(widget.pokemon),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _saveNickname(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_hasInitialNickname) ...[
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      onPressed: _removeNickname,
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                  ],
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF334155),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onPressed: _saveNickname,
                    child: const Text(
                      'Save',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
