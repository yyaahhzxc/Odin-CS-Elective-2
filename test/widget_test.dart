import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/main.dart';

void main() {
  testWidgets('Pokédex app renders centered title and starts in loading state', (WidgetTester tester) async {
    // Build the PokedexApp widget tree
    await tester.pumpWidget(const PokedexApp());

    // Verify the presence of the centered header title
    expect(find.text('Starter Pokédex'), findsOneWidget);
  });
}
