import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/hive_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockPathProvider extends PathProviderPlatform {
  @override
  Future<String> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = MockPathProvider();
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>('tasks');
    await Hive.openBox<String>('categories');
  });

  group('HiveStorage', () {
    late HiveStorage hiveStorage;

    setUp(() {
      hiveStorage = HiveStorage();
    });

    tearDown(() async {
      await Hive.box<Task>('tasks').clear();
      await Hive.box<String>('categories').clear();
    });

    test('Debería guardar una tarea en Hive', () async {
      final task = Task(
        id: '1',
        title: 'Comprar comida',
        description: 'Ir al supermercado',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      );

      await hiveStorage.guardarTarea(task);

      final box = Hive.box<Task>('tasks');
      expect(box.get('1')?.title, 'Comprar comida');
    });

    test('Debería eliminar una tarea de Hive', () async {
      final task = Task(
        id: '1',
        title: 'Comprar comida',
        description: 'Ir al supermercado',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      );

      await hiveStorage.guardarTarea(task);
      await hiveStorage.eliminarTarea('1');

      final box = Hive.box<Task>('tasks');
      expect(box.get('1'), null);
    });

    test(
      'Al abrir el box de categorías vacío, inicializa con categorías por defecto',
      () async {
        // Cierra y elimina el box para simular primer uso
        final boxName = 'categories';
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box<String>(boxName).close();
        }
        await Hive.deleteBoxFromDisk(boxName);

        final hiveStorage = HiveStorage();
        // Forzamos la apertura del box usando leerCategorias (que usa _getBox)
        final categorias = await hiveStorage.leerCategorias();

        expect(categorias, containsAll(['General', 'Trabajo', 'Personal']));
      },
    );

    test('Debería leer tareas de Hive', () async {
      final task1 = Task(
        id: '1',
        title: 'Tarea 1',
        description: 'Desc 1',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      );
      final task2 = Task(
        id: '2',
        title: 'Tarea 2',
        description: 'Desc 2',
        dueDate: DateTime.now(),
        completed: true,
        createdAt: DateTime.now(),
        category: 'Trabajo',
      );
      await hiveStorage.guardarTarea(task1);
      await hiveStorage.guardarTarea(task2);

      final tasks = await hiveStorage.leerTareas();
      expect(tasks.length, 2);
      expect(tasks.any((t) => t.id == '1'), isTrue);
      expect(tasks.any((t) => t.id == '2'), isTrue);
    });

    test('Debería editar una tarea en Hive', () async {
      final task = Task(
        id: '1',
        title: 'Original',
        description: 'Desc',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      );
      await hiveStorage.guardarTarea(task);

      final editedTask = Task(
        id: '1',
        title: 'Editada',
        description: 'Desc editada',
        dueDate: DateTime.now(),
        completed: true,
        createdAt: DateTime.now(),
        category: 'Trabajo',
      );
      final result = await hiveStorage.editarTarea(editedTask);
      expect(result, true);

      final box = Hive.box<Task>('tasks');
      expect(box.get('1')?.title, 'Editada');
      expect(box.get('1')?.completed, true);
    });

    test('Debería devolver false al editar tarea inexistente', () async {
      final task = Task(
        id: 'no-existe',
        title: 'No existe',
        description: 'Nada',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      );
      final result = await hiveStorage.editarTarea(task);
      expect(result, false);
    });

    test('Debería agregar y leer categorías', () async {
      await hiveStorage.agregarCategoria('Personal');
      await hiveStorage.agregarCategoria('Trabajo');
      final categorias = await hiveStorage.leerCategorias();
      expect(categorias, contains('Personal'));
      expect(categorias, contains('Trabajo'));
    });

    test('Debería eliminar una categoría', () async {
      await hiveStorage.agregarCategoria('Eliminar');
      var categorias = await hiveStorage.leerCategorias();
      expect(categorias, contains('Eliminar'));

      final result = await hiveStorage.eliminarCategoria('Eliminar');
      expect(result, true);

      categorias = await hiveStorage.leerCategorias();
      expect(categorias, isNot(contains('Eliminar')));
    });

    test('Debería devolver false al eliminar categoría inexistente', () async {
      final result = await hiveStorage.eliminarCategoria('NoExiste');
      expect(result, false);
    });

    test('Debería filtrar tareas por categoría', () async {
      final task1 = Task(
        id: '1',
        title: 'Tarea 1',
        description: 'Desc 1',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      );
      final task2 = Task(
        id: '2',
        title: 'Tarea 2',
        description: 'Desc 2',
        dueDate: DateTime.now(),
        completed: true,
        createdAt: DateTime.now(),
        category: 'Trabajo',
      );
      await hiveStorage.guardarTarea(task1);
      await hiveStorage.guardarTarea(task2);

      final filtradas = await hiveStorage.leerCategoriasFiltradas('Personal');
      expect(filtradas.length, 1);
      expect(filtradas.first.category, 'Personal');
    });
    test('Debería devolver false al agregar categoría duplicada', () async {
      await hiveStorage.agregarCategoria('Duplicada');
      final result = await hiveStorage.agregarCategoria('Duplicada');
      expect(result, false);
    });

    test('leerCategorias retorna lista vacía si hay error', () async {
      // Simula error cerrando el box
      final box = Hive.box<String>('categories');
      await box.close();
      final categorias = await hiveStorage.leerCategorias();
      expect(categorias, isA<List<String>>());
    });

    test('leerTareas retorna lista vacía si hay error', () async {
      // Cierra el box y vuelve a abrirlo para evitar errores de estado en otros tests
      final boxName = 'tasks';
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<Task>(boxName).close();
      }
      // Elimina el box del registro de Hive para simular error
      Hive.deleteBoxFromDisk(boxName);
      // Ahora, leerTareas debería manejar el error y retornar []
      final tareas = await hiveStorage.leerTareas();
      expect(tareas, isA<List<Task>>());
      expect(tareas, isEmpty);
      // Reabre el box para siguientes tests
      await Hive.openBox<Task>(boxName);
    });

    test('eliminarTarea retorna false si hay error', () async {
      final boxName = 'tasks';
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<Task>(boxName).close();
      }
      Hive.deleteBoxFromDisk(boxName);
      final result = await hiveStorage.eliminarTarea('no-existe');
      expect(result, false);
      await Hive.openBox<Task>(boxName);
    });

    test('editarTarea retorna false si hay error', () async {
      final boxName = 'tasks';
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<Task>(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      final task = Task(
        id: '1',
        title: 'Error',
        description: 'Error',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Error',
      );
      final result = await hiveStorage.editarTarea(task);
      expect(result, false);
      // Reabre el box para siguientes tests
      await Hive.openBox<Task>(boxName);
    });

    test('agregarCategoria retorna false si hay error', () async {
      final boxName = 'categories';
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<String>(boxName).close();
      }
      Hive.deleteBoxFromDisk(boxName);
      final result = await hiveStorage.agregarCategoria('Error');
      expect(result, false);
      await Hive.openBox<String>(boxName);
    });

    test('eliminarCategoria retorna false si hay error', () async {
      final boxName = 'categories';
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<String>(boxName).close();
      }
      Hive.deleteBoxFromDisk(boxName);
      final result = await hiveStorage.eliminarCategoria('Error');
      expect(result, false);
      await Hive.openBox<String>(boxName);
    });

    test('leerCategoriasFiltradas retorna lista vacía si hay error', () async {
      final boxName = 'tasks';
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<Task>(boxName).close();
      }
      Hive.deleteBoxFromDisk(boxName);
      final result = await hiveStorage.leerCategoriasFiltradas('Error');
      expect(result, isA<List<Task>>());
      expect(result, isEmpty);
      await Hive.openBox<Task>(boxName);
    });

    test('getTasksPerDay retorna mapa vacío si hay error', () async {
      final boxName = 'tasks';
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<Task>(boxName).close();
      }
      Hive.deleteBoxFromDisk(boxName);
      final map = await hiveStorage.getTasksPerDay();
      expect(map, isA<Map<DateTime, int>>());
      expect(map.isEmpty, true);
      await Hive.openBox<Task>(boxName);
    });
  });
}
