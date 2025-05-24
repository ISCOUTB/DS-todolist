import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/screens/register_screen.dart';

void main() {
  group('RegisterScreen', () {
    testWidgets('muestra los campos y botones principales', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterScreen()),
      );

      expect(find.text('Registrate como un nuevo usuario'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Registrar'), findsOneWidget);
      expect(find.byIcon(Icons.supervised_user_circle), findsOneWidget);
      expect(find.text('O continua con'), findsOneWidget);
    });
  });
}
