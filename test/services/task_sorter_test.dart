import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_sorter.dart';

void main() {
  group('TaskSorter', () {
    final taskA = Task(
      id: '1',
      title: 'Comprar pan',
      description: 'Ir a la tienda',
      dueDate: DateTime(2024, 6, 10),
      completed: false,
      createdAt: DateTime(2024, 6, 1),
      category: 'Personal',
    );
    final taskB = Task(
      id: '2',
      title: 'Aprender Dart',
      description: 'Estudiar el lenguaje Dart',
      dueDate: DateTime(2024, 6, 5),
      completed: false,
      createdAt: DateTime(2024, 6, 2),
      category: 'Estudio',
    );
    final taskC = Task(
      id: '3',
      title: 'Zanjar cuentas',
      description: 'Pagar servicios',
      dueDate: null,
      completed: false,
      createdAt: DateTime(2024, 6, 3),
      category: 'Finanzas',
    );

    test(
      'sortTasksByTitle ordena las tareas alfabéticamente por título',
      () async {
        final tasks = [taskA, taskB, taskC];
        final sorted = await TaskSorter.sortTasksByTitle(List.from(tasks));
        expect(sorted[0].title, 'Aprender Dart');
        expect(sorted[1].title, 'Comprar pan');
        expect(sorted[2].title, 'Zanjar cuentas');
      },
    );

    test(
      'sortTasksByDueDate ordena las tareas por fecha de vencimiento (nulls al final)',
      () async {
        final tasks = [taskA, taskB, taskC];
        final sorted = await TaskSorter.sortTasksByDueDate(List.from(tasks));
        expect(sorted[0].title, 'Aprender Dart'); // 2024-06-05
        expect(sorted[1].title, 'Comprar pan'); // 2024-06-10
        expect(sorted[2].title, 'Zanjar cuentas'); // null
      },
    );
  });
}
