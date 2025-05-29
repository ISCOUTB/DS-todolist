import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('muestra los campos y botones principales', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.text('Bienvenido Otra Vez'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Olvidaste tu contraseña?'), findsOneWidget);
      expect(find.text('No tienes una cuenta?'), findsOneWidget);
      expect(find.text('Registrate'), findsOneWidget);
    });
  });
}
