import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/services/storage_switch.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/storage_strategy.dart';

class MockStorageStrategy implements StorageStrategy {
  List<Task> tasks = [];
  List<String> categorias = [];
  Map<DateTime, int> perDay = {};
  bool returnBool = true;

  @override
  Future<void> guardarTarea(Task task) async {
    tasks.add(task);
  }

  @override
  Future<List<Task>> leerTareas() async {
    return tasks;
  }

  @override
  Future<bool> eliminarTarea(String idtarea) async {
    tasks.removeWhere((t) => t.id == idtarea);
    return returnBool;
  }

  @override
  Future<bool> agregarCategoria(String categoriaNombre) async {
    categorias.add(categoriaNombre);
    return returnBool;
  }

  @override
  Future<bool> eliminarCategoria(String categoriaNombre) async {
    categorias.remove(categoriaNombre);
    return returnBool;
  }

  @override
  Future<List<Task>> leerCategoriasFiltradas(String nombreCategoria) async {
    return tasks.where((t) => t.category == nombreCategoria).toList();
  }

  @override
  Future<List<String>> leerCategorias() async {
    return categorias;
  }

  @override
  Future<bool> editarTarea(Task tarea) async {
    final idx = tasks.indexWhere((t) => t.id == tarea.id);
    if (idx != -1) {
      tasks[idx] = tarea;
      return true;
    }
    return false;
  }

  @override
  Future<Map<DateTime, int>> getTasksPerDay() async {
    return perDay;
  }
}

void main() {
  group('StorageSwitch', () {
    late StorageSwitch storage;
    late MockStorageStrategy mock;

    setUp(() {
      mock = MockStorageStrategy();
      storage = StorageSwitch(mock);
    });

    test('guardarTarea llama a la estrategia', () async {
      final task = Task(
        id: '1',
        title: 'Tarea',
        description: 'desc',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat',
      );
      await storage.guardarTarea(task);
      expect(mock.tasks, contains(task));
    });

    test('leerTareas llama a la estrategia', () async {
      final task = Task(
        id: '2',
        title: 'Tarea2',
        description: 'desc2',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat2',
      );
      mock.tasks.add(task);
      final result = await storage.leerTareas();
      expect(result, contains(task));
    });

    test('eliminarTarea llama a la estrategia', () async {
      final task = Task(
        id: '3',
        title: 'Tarea3',
        description: 'desc3',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat3',
      );
      mock.tasks.add(task);
      final result = await storage.eliminarTarea('3');
      expect(result, true);
      expect(mock.tasks.any((t) => t.id == '3'), isFalse);
    });

    test('agregarCategoria llama a la estrategia', () async {
      final result = await storage.agregarCategoria('Nueva');
      expect(result, true);
      expect(mock.categorias, contains('Nueva'));
    });

    test('eliminarCategoria llama a la estrategia', () async {
      mock.categorias.add('Eliminar');
      final result = await storage.eliminarCategoria('Eliminar');
      expect(result, true);
      expect(mock.categorias, isNot(contains('Eliminar')));
    });

    test('leerCategoriasFiltradas llama a la estrategia', () async {
      final task = Task(
        id: '4',
        title: 'Tarea4',
        description: 'desc4',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat4',
      );
      mock.tasks.add(task);
      final result = await storage.leerCategoriasFiltradas('cat4');
      expect(result, contains(task));
    });

    test('leerCategorias llama a la estrategia', () async {
      mock.categorias.addAll(['catA', 'catB']);
      final result = await storage.leerCategorias();
      expect(result, containsAll(['catA', 'catB']));
    });

    test('editarTarea llama a la estrategia', () async {
      final task = Task(
        id: '5',
        title: 'Tarea5',
        description: 'desc5',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat5',
      );
      mock.tasks.add(task);
      final edited = Task(
        id: '5',
        title: 'Editada',
        description: 'desc5',
        dueDate: DateTime.now(),
        completed: true,
        createdAt: DateTime.now(),
        category: 'cat5',
      );
      final result = await storage.editarTarea(edited);
      expect(result, true);
      expect(mock.tasks.first.title, 'Editada');
    });

    test('getTasksPerDay llama a la estrategia', () async {
      mock.perDay = {DateTime(2024, 1, 1): 2};
      final result = await storage.getTasksPerDay();
      expect(result[DateTime(2024, 1, 1)], 2);
    });

    test('setStrategy cambia la estrategia', () async {
      final other = MockStorageStrategy();
      storage.setStrategy(other);
      expect(
        () => storage.guardarTarea(
          Task(
            id: 'x',
            title: 'T',
            description: '',
            dueDate: DateTime.now(),
            completed: false,
            createdAt: DateTime.now(),
            category: '',
          ),
        ),
        returnsNormally,
      );
    });
  });
}
