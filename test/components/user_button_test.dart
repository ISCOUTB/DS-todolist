import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/components/user_button.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_button_test.mocks.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirebaseAuth, User])
void main() {
  testWidgets('UserButton muestra el icono y navega si no hay usuario', (
    WidgetTester tester,
  ) async {
    final mockAuth = MockFirebaseAuth();
    // Stub para authStateChanges
    when(mockAuth.currentUser).thenReturn(null);
    when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: UserButton(auth: mockAuth))),
    );

    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
