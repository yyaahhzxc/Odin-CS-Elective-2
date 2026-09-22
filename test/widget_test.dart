import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:async_profile_app/main.dart';

void main() {
  testWidgets('AsyncProfileApp loads profile after simulated delay', (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncProfileApp());

    // Initially, FutureBuilder is in waiting state showing the progress indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Fetching profile data...'), findsOneWidget);

    // Fast-forward time by 2 seconds to let the Future resolve.
    await tester.pump(const Duration(seconds: 2));

    // Profile card should now be rendered.
    expect(find.text('Yahyah Odin'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
