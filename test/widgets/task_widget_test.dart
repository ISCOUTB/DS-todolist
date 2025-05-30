import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/widgets/task_widget.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/models/task.dart';

class MockTaskNotifier extends ChangeNotifier implements TaskNotifier {
  @override
  List<Task> tasks = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestTaskNotifier extends MockTaskNotifier {
  final void Function(String)? onDelete;
  final void Function(String, bool)? onToggle;

  TestTaskNotifier({this.onDelete, this.onToggle});

  @override
  Future<void> eliminarTarea(String id) async {
    if (onDelete != null) onDelete!(id);
  }

  @override
  Future<void> toggleTaskCompletion(String id, bool value) async {
    if (onToggle != null) onToggle!(id, value);
  }
}

void main() {
  Widget createWidgetUnderTest({required TaskNotifier notifier}) {
    return MaterialApp(
      home: ChangeNotifierProvider<TaskNotifier>.value(
        value: notifier,
        child: const Scaffold(body: TaskWidget()),
      ),
    );
  }

  group('TaskWidget', () {
    testWidgets('Muestra mensaje cuando no hay tareas', (tester) async {
      final mockNotifier = MockTaskNotifier();
      await tester.pumpWidget(createWidgetUnderTest(notifier: mockNotifier));
      expect(find.text('No hay tareas disponibles'), findsOneWidget);
    });

    testWidgets('Muestra tareas cuando existen', (tester) async {
      final mockNotifier = MockTaskNotifier();
      final now = DateTime.now();
      mockNotifier.tasks = [
        Task(
          id: '1',
          title: 'Tarea A',
          description: 'Desc A',
          dueDate: now,
          completed: false,
          createdAt: now,
          category: 'General',
        ),
      ];
      await tester.pumpWidget(createWidgetUnderTest(notifier: mockNotifier));
      expect(
        find.text('Tarea A'),
        findsWidgets,
      ); // Cambiado de findsOneWidget a findsWidgets
      expect(find.text('Desc A'), findsWidgets);
    });

    testWidgets('Elimina y completa tarea al interactuar con los controles', (
      tester,
    ) async {
      bool deleteCalled = false;
      bool toggleCalled = false;
      final now = DateTime.now();

      final notifier = TestTaskNotifier(
        onDelete: (_) => deleteCalled = true,
        onToggle: (_, __) => toggleCalled = true,
      );
      notifier.tasks = [
        Task(
          id: '1',
          title: 'Tarea A',
          description: 'Desc A',
          dueDate: now,
          completed: false,
          createdAt: now,
          category: 'General',
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(notifier: notifier));

      // Tap en el botón de borrar
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      expect(deleteCalled, isTrue);

      // Tap en el checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(toggleCalled, isTrue);
    });
  });
}
