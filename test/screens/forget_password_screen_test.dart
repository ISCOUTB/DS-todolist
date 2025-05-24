import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/screens/forget_password_screen.dart';

void main() {
  group('ForgetPasswordScreen', () {
    testWidgets('muestra los widgets principales', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgetPasswordScreen()));

      expect(find.text('Reinicio de contraseña'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enviar Email'), findsOneWidget);
      expect(find.byIcon(Icons.password), findsOneWidget);
    });
  });
}
