import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/models/storage_strategy.dart';
import 'package:to_do_list/models/task.dart';

class MockStorageStrategy implements StorageStrategy {
  final List<Task> _tasks = [];
  final List<String> _categories = [];

  @override
  Future<void> guardarTarea(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<List<Task>> leerTareas() async {
    return _tasks;
  }

  @override
  Future<bool> editarTarea(Task tarea) async {
    final index = _tasks.indexWhere((t) => t.id == tarea.id);
    if (index != -1) {
      _tasks[index] = tarea;
      return true;
    }
    return false;
  }

  @override
  Future<bool> eliminarTarea(String tareaId) async {
    final initialLength = _tasks.length;
    _tasks.removeWhere((t) => t.id == tareaId);
    return _tasks.length < initialLength;
  }

  @override
  Future<List<String>> leerCategorias() async {
    return _categories;
  }

  @override
  Future<bool> agregarCategoria(String categoriaNombre) async {
    if (!_categories.contains(categoriaNombre)) {
      _categories.add(categoriaNombre);
      return true;
    }
    return false;
  }

  @override
  Future<bool> eliminarCategoria(String categoriaNombre) async {
    return _categories.remove(categoriaNombre);
  }

  @override
  Future<List<Task>> leerCategoriasFiltradas(String nombreCategoria) async {
    return _tasks.where((t) => t.category == nombreCategoria).toList();
  }

  @override
  Future<Map<DateTime, int>> getTasksPerDay() async {
    final map = <DateTime, int>{};
    for (final task in _tasks) {
      final date = task.dueDate ?? DateTime(2000);
      map[date] = (map[date] ?? 0) + 1;
    }
    return map;
  }
}

void main() {
  group('StorageStrategy', () {
    late StorageStrategy storage;
    final task = Task(
      id: '1',
      title: 'Test',
      description: 'Desc',
      dueDate: DateTime(2025, 5, 20),
      completed: false,
      createdAt: DateTime.now(),
      category: 'General',
    );

    setUp(() {
      storage = MockStorageStrategy();
    });

    test('guardarTarea y leerTareas', () async {
      await storage.guardarTarea(task);
      final tasks = await storage.leerTareas();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test');
    });

    test('editarTarea', () async {
      await storage.guardarTarea(task);
      final edited = Task(
        id: task.id,
        title: 'Editado',
        description: task.description,
        dueDate: task.dueDate,
        completed: task.completed,
        createdAt: task.createdAt,
        category: task.category,
      );
      final result = await storage.editarTarea(edited);
      expect(result, true);
      final tasks = await storage.leerTareas();
      expect(tasks.first.title, 'Editado');
    });

    test('eliminarTarea', () async {
      await storage.guardarTarea(task);
      final result = await storage.eliminarTarea(task.id);
      expect(result, true);
      final tasks = await storage.leerTareas();
      expect(tasks.isEmpty, true);
    });

    test('agregarCategoria y leerCategorias', () async {
      final result = await storage.agregarCategoria('Nueva');
      expect(result, true);
      final cats = await storage.leerCategorias();
      expect(cats, contains('Nueva'));
    });

    test('eliminarCategoria', () async {
      await storage.agregarCategoria('Nueva');
      final result = await storage.eliminarCategoria('Nueva');
      expect(result, true);
      final cats = await storage.leerCategorias();
      expect(cats, isNot(contains('Nueva')));
    });

    test('leerCategoriasFiltradas', () async {
      final t1 = Task(
        id: '2',
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        completed: task.completed,
        createdAt: task.createdAt,
        category: 'Trabajo',
      );
      await storage.guardarTarea(t1);
      final filtered = await storage.leerCategoriasFiltradas('Trabajo');
      expect(filtered.length, 1);
      expect(filtered.first.category, 'Trabajo');
    });

    test('getTasksPerDay', () async {
      await storage.guardarTarea(task);
      final map = await storage.getTasksPerDay();
      expect(map[task.dueDate], 1);
    });
  });
}
