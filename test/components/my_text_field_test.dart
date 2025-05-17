import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/components/my_text_field.dart';

void main() {
  testWidgets('MyTextField muestra el hint y actualiza el controlador', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextField(
            controller: controller,
            hintText: 'Escribe aquí',
            obscureText: false,
          ),
        ),
      ),
    );

    // Verifica que el hint se muestre
    expect(find.text('Escribe aquí'), findsOneWidget);

    // Escribe texto en el campo
    await tester.enterText(find.byType(TextField), 'Hola mundo');
    expect(controller.text, 'Hola mundo');
  });
}
