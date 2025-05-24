import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/widgets/responsive_widget.dart';

void main() {
  Widget buildTestWidget(double width) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: ResponsiveWidget(
          mobileLayout: const Text('Mobile'),
          tabletLayout: const Text('Tablet'),
          desktopLayout: const Text('Desktop'),
        ),
      ),
    );
  }

  group('ResponsiveWidget', () {
    testWidgets('Muestra mobileLayout si el ancho < 600', (tester) async {
      await tester.pumpWidget(buildTestWidget(500));
      expect(find.text('Mobile'), findsOneWidget);
    });

    testWidgets('Muestra tabletLayout si el ancho >= 600 y < 840', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(700));
      expect(find.text('Tablet'), findsOneWidget);
    });

    testWidgets('Muestra desktopLayout si el ancho >= 840', (tester) async {
      await tester.pumpWidget(buildTestWidget(900));
      expect(find.text('Desktop'), findsOneWidget);
    });
  });
}
