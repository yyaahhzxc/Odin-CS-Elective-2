import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/main.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/providers/pokemon_provider.dart';
import 'package:pokedex_app/screens/pokedex_screen.dart';
import 'package:pokedex_app/screens/pokemon_detail_screen.dart';
import 'package:pokedex_app/widgets/loading_view.dart';
import 'package:pokedex_app/widgets/type_badge.dart';

void main() {
  const samplePokemon1 = Pokemon(
    id: 1,
    name: 'bulbasaur',
    imageUrl: 'https://example.com/bulbasaur.png',
    types: ['grass', 'poison'],
  );

  const samplePokemon2 = Pokemon(
    id: 4,
    name: 'charmander',
    imageUrl: 'https://example.com/charmander.png',
    types: ['fire'],
  );

  group('PokedexApp & Riverpod Initialization Tests', () {
    testWidgets('Renders PokedexApp root with AppBar title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pokemonListProvider.overrideWith(() => _MockPokemonListNotifier([])),
          ],
          child: const PokedexApp(),
        ),
      );

      expect(find.text('Starter Pokédex'), findsOneWidget);
    });

    testWidgets('Renders loading indicator when fetching data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pokemonListProvider
                .overrideWith(() => _MockLoadingPokemonListNotifier()),
          ],
          child: const MaterialApp(home: PokedexScreen()),
        ),
      );

      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets('Renders Pokemon cards when data is loaded', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pokemonListProvider.overrideWith(
                () => _MockPokemonListNotifier([samplePokemon1, samplePokemon2])),
          ],
          child: const MaterialApp(home: PokedexScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Charmander'), findsOneWidget);
      expect(find.text('#0001'), findsOneWidget);
      expect(find.text('#0004'), findsOneWidget);
    });
  });

  group('Favorites & Pokeball Indicator Tests', () {
    testWidgets('Toggling favorite updates Pokeball icon and counter badge',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pokemonListProvider.overrideWith(
                () => _MockPokemonListNotifier([samplePokemon1])),
          ],
          child: const MaterialApp(home: PokedexScreen()),
        ),
      );

      await tester.pump();

      // Find the card favorite button
      final cardFavoriteFinder = find.byKey(const Key('favorite_button_1'));
      expect(cardFavoriteFinder, findsOneWidget);

      // Tap on card favorite button
      await tester.tap(cardFavoriteFinder);
      await tester.pumpAndSettle();

      // Badge in AppBar leading should show '1' favorite
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('Type Filter Tests', () {
    testWidgets('Filtering by Fire displays only Fire-type Pokemon',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pokemonListProvider.overrideWith(
                () => _MockPokemonListNotifier([samplePokemon1, samplePokemon2])),
          ],
          child: const MaterialApp(home: PokedexScreen()),
        ),
      );

      await tester.pump();

      // Both are rendered initially
      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Charmander'), findsOneWidget);

      // Tap on FIRE filter chip directly by key
      await tester.tap(find.byKey(const Key('type_chip_fire')));
      await tester.pumpAndSettle();

      // Only Charmander should be visible
      expect(find.text('Charmander'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsNothing);

      // Tap on Clear button
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Both should be visible again
      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Charmander'), findsOneWidget);
    });
  });

  group('Nickname Hierarchy & Detail Screen Tests', () {
    testWidgets(
        'Displays nickname as primary title and species name as subtitle',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          pokemonListProvider.overrideWith(
              () => _MockPokemonListNotifier([samplePokemon2])),
        ],
      );

      // Assign nickname "Blaze" to Charmander (ID 4)
      container.read(nicknamesProvider.notifier).setNickname(4, 'Blaze');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PokedexScreen()),
        ),
      );

      await tester.pump();

      // Primary title is Blaze
      expect(find.text('Blaze'), findsOneWidget);
      // Subtitle is Charmander
      expect(find.text('Charmander'), findsOneWidget);
    });

    testWidgets('Detail screen reflects custom nickname and species name',
        (tester) async {
      final container = ProviderContainer();
      container.read(selectedPokemonProvider.notifier).selectPokemon(samplePokemon2);
      container.read(nicknamesProvider.notifier).setNickname(4, 'Blaze');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PokemonDetailScreen()),
        ),
      );

      await tester.pump();

      // Title in AppBar and Header
      expect(find.text('Blaze'), findsWidgets);
      // Species name subtitle
      expect(find.text('Charmander'), findsWidgets);
      expect(find.text('#0004'), findsOneWidget);
      // Pencil edit icon is present beside name
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });
  });

  group('Pokemon Model & Formatting Tests', () {
    test('Parses raw PokéAPI JSON structure correctly', () {
      final sampleJson = {
        'id': 1,
        'name': 'bulbasaur',
        'sprites': {
          'other': {
            'official-artwork': {
              'front_default':
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
            },
          },
        },
        'types': [
          {
            'type': {'name': 'grass'},
          },
          {
            'type': {'name': 'poison'},
          },
        ],
      };

      final pokemon = Pokemon.fromJson(sampleJson);

      expect(pokemon.id, 1);
      expect(pokemon.name, 'bulbasaur');
      expect(pokemon.displayName, 'Bulbasaur');
      expect(pokemon.formattedId, '#0001');
      expect(pokemon.generation, 1);
      expect(pokemon.regionName, 'Kanto');
      expect(pokemon.types, ['grass', 'poison']);
    });
  });

  group('TypeBadge Component Tests', () {
    testWidgets('Renders capitalized badge text with appropriate styling',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypeBadge(typeName: 'fire'),
          ),
        ),
      );

      expect(find.text('FIRE'), findsOneWidget);
    });
  });
}

class _MockPokemonListNotifier extends PokemonListNotifier {
  final List<Pokemon> initialPokemons;

  _MockPokemonListNotifier(this.initialPokemons);

  @override
  Future<List<Pokemon>> build() async {
    return initialPokemons;
  }
}

class _MockLoadingPokemonListNotifier extends PokemonListNotifier {
  @override
  Future<List<Pokemon>> build() async {
    state = const AsyncValue.loading();
    return [];
  }
}
