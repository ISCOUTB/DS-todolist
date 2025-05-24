import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/components/sorter_button.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_notifier.dart';

void main() {
  testWidgets('SorterButton muestra opciones y ordena tareas', (
    WidgetTester tester,
  ) async {
    final taskNotifier = TaskNotifier();
    // Carga tareas de prueba
    taskNotifier.loadFilteredTasks([
      Task(
        id: '1',
        title: 'B tarea',
        description: '',
        dueDate: DateTime(2024, 5, 20),
        completed: false,
        createdAt: DateTime.now(),
        category: 'General',
      ),
      Task(
        id: '2',
        title: 'A tarea',
        description: '',
        dueDate: DateTime(2024, 5, 10),
        completed: false,
        createdAt: DateTime.now(),
        category: 'General',
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider<TaskNotifier>.value(
        value: taskNotifier,
        child: const MaterialApp(home: Scaffold(body: SorterButton())),
      ),
    );

    // Abre el menú
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    // Verifica que las opciones estén presentes
    expect(find.text('Ordenar por fecha'), findsOneWidget);
    expect(find.text('Ordenar por título'), findsOneWidget);

    // Selecciona "Ordenar por título"
    await tester.tap(find.text('Ordenar por título'));
    await tester.pumpAndSettle();

    // Verifica que la primera tarea ahora sea la que empieza con 'A'
    expect(taskNotifier.tasks.first.title, 'A tarea');
  });
}
