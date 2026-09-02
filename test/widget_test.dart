import 'package:flutter_test/flutter_test.dart';
import 'package:csshop/main.dart';

void main() {
  testWidgets('CSShop home screen smoke and widget test',
      (WidgetTester tester) async {
    // Build the CSShop application and trigger a frame
    await tester.pumpWidget(const CSShopApp());
    await tester.pumpAndSettle();

    // Verify that the store title renders cleanly
    expect(find.text('CSShop'), findsOneWidget);

    // Verify that the title and products section render
    expect(find.text('CSShop - The CSSEC Merch Store'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
  });
}
