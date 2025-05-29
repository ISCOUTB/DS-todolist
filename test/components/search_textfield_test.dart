import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/components/search_textfield.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_notifier.dart';

void main() {
  testWidgets('Debería filtrar tareas al escribir en el campo de búsqueda', (
    WidgetTester tester,
  ) async {
    final taskNotifier = TaskNotifier();
    taskNotifier.loadFilteredTasks([
      Task(
        id: '1',
        title: 'Comprar comida',
        description: 'Ir al supermercado',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      ),
      Task(
        id: '2',
        title: 'Estudiar Flutter',
        description: 'Revisar documentación oficial',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Trabajo',
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => taskNotifier,
        child: const MaterialApp(home: Scaffold(body: SearchTextfield())),
      ),
    );

    // Escribe en el campo de búsqueda
    await tester.enterText(find.byType(TextField), 'Flutter');
    await tester.pump();

    // Verifica que solo se muestre la tarea filtrada
    expect(taskNotifier.tasks.length, 1);
    expect(taskNotifier.tasks.first.title, 'Estudiar Flutter');
  });

  testWidgets('Debería mostrar todas las tareas al limpiar campo de búsqueda', (
    WidgetTester tester,
  ) async {
    final taskNotifier = TaskNotifier();
    taskNotifier.loadFilteredTasks([
      Task(
        id: '1',
        title: 'Comprar comida',
        description: 'Ir al supermercado',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      ),
      Task(
        id: '2',
        title: 'Estudiar Flutter',
        description: 'Revisar documentación oficial',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Trabajo',
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => taskNotifier,
        child: const MaterialApp(home: Scaffold(body: SearchTextfield())),
      ),
    );

    // Escribe en el campo de búsqueda
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    // Verifica que solo se muestre la tarea filtrada
    expect(taskNotifier.tasks.length, 2);
    expect(taskNotifier.tasks.first.title, 'Comprar comida');
    expect(taskNotifier.tasks.last.title, 'Estudiar Flutter');
  });
}
