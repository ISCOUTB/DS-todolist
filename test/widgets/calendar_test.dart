import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list/services/storage_switch.dart';
import 'package:to_do_list/widgets/calendar.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/models/task.dart';

class MockTaskNotifier extends ChangeNotifier implements TaskNotifier {
  @override
  List<Task> tasks = [];

  @override
  Future<void> loadTasks() async {}

  @override
  late StorageSwitch storage;

  // ...otros métodos de TaskNotifier si es necesario...

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget createWidgetUnderTest({required TaskNotifier notifier}) {
    return MaterialApp(
      home: ChangeNotifierProvider<TaskNotifier>.value(
        value: notifier,
        child: const Scaffold(body: Calendar()),
      ),
    );
  }

  group('Calendar Widget Tests', () {
    testWidgets('Calendar se renderiza correctamente', (
      WidgetTester tester,
    ) async {
      final mockNotifier = MockTaskNotifier();
      await tester.pumpWidget(createWidgetUnderTest(notifier: mockNotifier));
      expect(find.byType(Calendar), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('Muestra mensaje cuando no hay tareas para el día', (
      WidgetTester tester,
    ) async {
      final mockNotifier = MockTaskNotifier();
      await tester.pumpWidget(createWidgetUnderTest(notifier: mockNotifier));
      await tester.pumpAndSettle();
      expect(find.text('No hay tareas para este día.'), findsOneWidget);
    });

    testWidgets('Muestra tareas para el día seleccionado', (
      WidgetTester tester,
    ) async {
      final mockNotifier = MockTaskNotifier();
      final today = DateTime.now();
      mockNotifier.tasks = [
        Task(
          id: '1',
          title: 'Tarea 1',
          description: 'Descripción 1',
          dueDate: today,
          completed: false,
          createdAt: today,
          category: 'General',
        ),
      ];
      await tester.pumpWidget(createWidgetUnderTest(notifier: mockNotifier));
      await tester.pumpAndSettle();
      expect(find.text('Tarea 1'), findsOneWidget);
      expect(find.text('Descripción 1'), findsOneWidget);
    });
  });
}
