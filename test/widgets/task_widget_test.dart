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
  });
}
