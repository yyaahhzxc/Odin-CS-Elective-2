import 'package:flutter_test/flutter_test.dart';
import 'package:flight_booking_app/main.dart';

void main() {
  testWidgets('Spotify Now Playing UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpotifyActivityApp());

    // Verify that track title and artist are rendered.
    expect(find.text('Akasaka Sad'), findsOneWidget);
    expect(find.text('Rina Sawayama'), findsOneWidget);
  });
}
