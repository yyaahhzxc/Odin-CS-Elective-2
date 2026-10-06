import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/main.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/widgets/loading_view.dart';
import 'package:pokedex_app/widgets/type_badge.dart';

void main() {
  group('PokedexApp Widget Tests', () {
    testWidgets('Renders centered title and initial loading state', (WidgetTester tester) async {
      await tester.pumpWidget(const PokedexApp());

      // Verify the presence of the header title
      expect(find.text('Starter Pokédex'), findsOneWidget);

      // Verify initial loading indicator state
      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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

