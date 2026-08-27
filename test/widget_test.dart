import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';
import 'package:responsive_dashboard/responsive/desktop_body.dart';
import 'package:responsive_dashboard/responsive/mobile_body.dart';
import 'package:responsive_dashboard/responsive/tablet_body.dart';

void main() {
  testWidgets('Renders Mobile layout on small screen widths', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ResponsiveDashboardApp());
    await tester.pumpAndSettle();

    expect(find.text('responsivedashboard'), findsOneWidget);
    expect(find.byType(MobileBody), findsOneWidget);
    expect(find.byType(TabletBody), findsNothing);
    expect(find.byType(DesktopBody), findsNothing);
  });

  testWidgets('Renders Tablet layout on medium screen widths', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ResponsiveDashboardApp());
    await tester.pumpAndSettle();

    expect(find.text('responsivedashboard'), findsOneWidget);
    expect(find.byType(MobileBody), findsNothing);
    expect(find.byType(TabletBody), findsOneWidget);
    expect(find.byType(DesktopBody), findsNothing);
  });

  testWidgets('Renders Desktop layout on large screen widths', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ResponsiveDashboardApp());
    await tester.pumpAndSettle();

    expect(find.text('responsivedashboard'), findsOneWidget);
    expect(find.byType(MobileBody), findsNothing);
    expect(find.byType(TabletBody), findsNothing);
    expect(find.byType(DesktopBody), findsOneWidget);
  });
}
