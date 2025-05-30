import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/models/task.dart';

void main() {
  group('Task Model', () {
    test('Debería convertir un objeto Task a JSON correctamente', () {
      final task = Task(
        id: '1',
        title: 'Comprar comida',
        description: 'Ir al supermercado',
        dueDate: DateTime.parse('2023-05-10'),
        completed: false,
        createdAt: DateTime.parse('2023-05-09'),
        category: 'Personal',
      );

      final json = task.toJson();

      expect(json, {
        'id': '1',
        'title': 'Comprar comida',
        'description': 'Ir al supermercado',
        'dueDate': '2023-05-10T00:00:00.000',
        'completed': false,
        'createdAt': '2023-05-09T00:00:00.000',
        'category': 'Personal',
      });
    });

    test('Debería crear un objeto Task desde JSON correctamente', () {
      final json = {
        'id': '1',
        'title': 'Comprar comida',
        'description': 'Ir al supermercado',
        'dueDate': '2023-05-10T00:00:00.000',
        'completed': false,
        'createdAt': '2023-05-09T00:00:00.000',
        'category': 'Personal',
      };

      final task = Task.fromJson(json);

      expect(task.id, '1');
      expect(task.title, 'Comprar comida');
      expect(task.description, 'Ir al supermercado');
      expect(task.dueDate, DateTime.parse('2023-05-10'));
      expect(task.completed, false);
      expect(task.createdAt, DateTime.parse('2023-05-09'));
      expect(task.category, 'Personal');
    });
  });

  test('Verifica getter de fecha', () {
    final task = Task(
      id: '1',
      title: 'Comprar comida',
      description: 'Ir al supermercado',
      dueDate: DateTime.parse('2023-05-10'),
      completed: false,
      createdAt: DateTime.parse('2023-05-09'),
      category: 'Personal',
    );

    expect(task.date, null);
  });
}
