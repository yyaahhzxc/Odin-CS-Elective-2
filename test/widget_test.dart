import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_app/main.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/providers/pokemon_provider.dart';
import 'package:pokedex_app/screens/pokedex_screen.dart';
import 'package:pokedex_app/screens/pokemon_detail_screen.dart';
import 'package:pokedex_app/widgets/error_view.dart';
import 'package:pokedex_app/widgets/loading_view.dart';
import 'package:pokedex_app/widgets/type_badge.dart';

class MockSuccessPokemonProvider extends PokemonProvider {
  final List<Pokemon> mockList;

  MockSuccessPokemonProvider(this.mockList);

  @override
  List<Pokemon> get pokemons => mockList;

  @override
  PokemonStateStatus get status => PokemonStateStatus.success;

  @override
  Future<void> fetchPokemons({bool forceRefresh = false}) async {}
}

class MockErrorPokemonProvider extends PokemonProvider {
  final String error;

  MockErrorPokemonProvider(this.error);

  @override
  PokemonStateStatus get status => PokemonStateStatus.error;

  @override
  String get errorMessage => error;

  @override
  Future<void> fetchPokemons({bool forceRefresh = false}) async {}
}

void main() {
  const samplePokemon = Pokemon(
    id: 1,
    name: 'bulbasaur',
    imageUrl: 'https://example.com/bulbasaur.png',
    types: ['grass', 'poison'],
  );

  group('PokedexApp & Provider Integration Tests', () {
    testWidgets('Renders centered title and initial loading state', (WidgetTester tester) async {
      await tester.pumpWidget(const PokedexApp());

      expect(find.text('Starter Pokédex'), findsOneWidget);
      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Renders error state when provider encounters an error', (WidgetTester tester) async {
      final mockProvider = MockErrorPokemonProvider('Connection failed');

      await tester.pumpWidget(
        ChangeNotifierProvider<PokemonProvider>.value(
          value: mockProvider,
          child: const MaterialApp(home: PokedexScreen()),
        ),
      );

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Connection failed'), findsOneWidget);
    });

    testWidgets('Renders pokemon grid on provider success state', (WidgetTester tester) async {
      final mockProvider = MockSuccessPokemonProvider([samplePokemon]);

      await tester.pumpWidget(
        ChangeNotifierProvider<PokemonProvider>.value(
          value: mockProvider,
          child: const MaterialApp(home: PokedexScreen()),
        ),
      );

      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('#0001'), findsOneWidget);
      expect(find.text('GRASS'), findsOneWidget);
    });

    testWidgets('Navigates to PokemonDetailScreen and reads state from provider', (WidgetTester tester) async {
      final provider = PokemonProvider();
      provider.selectPokemon(samplePokemon);

      await tester.pumpWidget(
        ChangeNotifierProvider<PokemonProvider>.value(
          value: provider,
          child: const MaterialApp(home: PokemonDetailScreen()),
        ),
      );

      // Verify page contents come from Provider App State (Requirement 9)
      expect(find.text('Bulbasaur'), findsNWidgets(2)); // AppBar and Title
      expect(find.text('#0001'), findsOneWidget);
      expect(find.text('National Dex Number'), findsOneWidget);
      expect(find.text('Gen 1'), findsOneWidget);
      expect(find.text('Kanto'), findsOneWidget);
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
              'front_default': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
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
      expect(pokemon.imageUrl, contains('1.png'));
    });

    test('Computes correct generation and region for Gen 9 starter', () {
      final sampleJson = {
        'id': 906,
        'name': 'sprigatito',
        'sprites': {},
        'types': [
          {
            'type': {'name': 'grass'},
          },
        ],
      };

      final pokemon = Pokemon.fromJson(sampleJson);

      expect(pokemon.id, 906);
      expect(pokemon.displayName, 'Sprigatito');
      expect(pokemon.formattedId, '#0906');
      expect(pokemon.generation, 9);
      expect(pokemon.regionName, 'Paldea');
      expect(pokemon.types, ['grass']);
    });
  });

  group('TypeBadge Component Tests', () {
    testWidgets('Renders capitalized badge text with appropriate styling', (WidgetTester tester) async {
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
