import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/main.dart';

void main() {
  testWidgets('Pokédex app renders title and starts in loading state', (WidgetTester tester) async {
    // Build the PokedexApp widget tree
    await tester.pumpWidget(const PokedexApp());

    // Verify the presence of the header title
    expect(find.text('Pokédex Starters'), findsOneWidget);
    expect(find.text('Generations 1 – 9 • 27 Pokémon'), findsOneWidget);
  });
}
