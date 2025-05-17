import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/components/my_button.dart';

void main() {
  testWidgets('MyButton muestra el texto y responde al tap', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: 'Presionar',
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verifica que el texto se muestre
    expect(find.text('Presionar'), findsOneWidget);

    // Simula el tap
    await tester.tap(find.byType(MyButton));
    await tester.pump();

    // Verifica que el callback se ejecutó
    expect(tapped, isTrue);
  });
}
