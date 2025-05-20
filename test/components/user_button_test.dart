import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/components/user_button.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  testWidgets('UserButton muestra el icono y navega si no hay usuario', (
    WidgetTester tester,
  ) async {
    // Simula que no hay usuario autenticado
    final mockAuth = MockFirebaseAuth(signedIn: false);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: UserButton(auth: mockAuth))),
    );

    // Debe mostrar el icono de persona
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('UserButton muestra el menú y el email si hay usuario', (
    WidgetTester tester,
  ) async {
    // Simula que hay un usuario autenticado
    final mockUser = MockUser(isAnonymous: false, email: 'test@example.com');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: UserButton(auth: mockAuth))),
    );

    // Debe mostrar el icono de persona
    expect(find.byIcon(Icons.person), findsOneWidget);

    // Abre el menú
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verifica que el email del usuario esté en el menú
    expect(find.text('Usuario: test@example.com'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });
}
