import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/widgets/list_item_widget.dart';
import 'package:to_do_list/models/task.dart';

void main() {
  Task buildTask({bool completed = false}) => Task(
    id: '1',
    title: 'Test Task',
    description: 'Test Description',
    dueDate: DateTime.utc(2023, 10, 1),
    completed: completed,
    createdAt: DateTime.now(),
    category: 'TestCat',
  );

  group('ListItemWidget', () {
    testWidgets('Renderiza título y descripción', (tester) async {
      final task = buildTask();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListItemWidget(
              task: task,
              onDelete: () {},
              onToggleCompleted: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Test Task'), findsWidgets);
      expect(find.text('Test Description'), findsWidgets);
      expect(find.textContaining('Categoria: TestCat'), findsOneWidget);
    });

    testWidgets('Llama a onDelete al presionar el botón de eliminar', (
      tester,
    ) async {
      bool deleted = false;
      final task = buildTask();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListItemWidget(
              task: task,
              onDelete: () {
                deleted = true;
              },
              onToggleCompleted: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(deleted, true);
    });

    testWidgets('Llama a onToggleCompleted al cambiar el checkbox', (
      tester,
    ) async {
      bool? completedValue;
      final task = buildTask();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListItemWidget(
              task: task,
              onDelete: () {},
              onToggleCompleted: (val) {
                completedValue = val;
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(completedValue, isNotNull);
    });
  });
}
