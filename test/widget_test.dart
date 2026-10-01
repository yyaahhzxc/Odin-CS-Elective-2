import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/main.dart';

void main() {
  testWidgets('Pokédex app renders title and starts in loading state', (WidgetTester tester) async {
    // Build the PokedexApp widget tree
    await tester.pumpWidget(const PokedexApp());

    // Verify the presence of the header title and subtitle
    expect(find.text('Pokédex'), findsOneWidget);
    expect(find.text('Starter Pokémon • Generations 1–9'), findsOneWidget);
  });
}
