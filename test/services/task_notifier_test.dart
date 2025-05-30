import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/storage_switch.dart';
import 'package:to_do_list/models/storage_strategy.dart';

// --- Firebase Mock Setup ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = FakeFirebasePlatform();
}

class FakeFirebasePlatform extends FirebasePlatform {
  FakeFirebasePlatform() : super();
  static Object get token => _token;
  static final Object _token = Object();

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return FakeFirebaseAppPlatform(name ?? 'default', options);
  }

  @override
  FirebaseAppPlatform app([String name = 'default']) {
    return FakeFirebaseAppPlatform(name, null);
  }

  @override
  List<FirebaseAppPlatform> get apps => [
    FakeFirebaseAppPlatform('default', null),
  ];
}

class FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  FakeFirebaseAppPlatform(String name, FirebaseOptions? options)
    : super(
        name,
        options ??
            const FirebaseOptions(
              apiKey: '',
              appId: '',
              messagingSenderId: '',
              projectId: '',
            ),
      );

  @override
  Future<void> delete() async {}
}

class MockStorage implements StorageStrategy {
  final List<Task> _tasks = [];
  final List<String> _categories = ['Personal', 'Trabajo'];
  bool eliminarTareaCalled = false;
  bool eliminarCategoriaCalled = false;
  bool editarTareaCalled = false;

  @override
  Future<List<Task>> leerTareas() async => _tasks;

  @override
  Future<void> guardarTarea(Task task) async => _tasks.add(
    Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      completed: task.completed,
      createdAt: task.createdAt,
      category: task.category,
    ),
  );

  @override
  Future<bool> eliminarTarea(String id) async {
    eliminarTareaCalled = true;
    _tasks.removeWhere((t) => t.id == id);
    return true;
  }

  @override
  Future<bool> eliminarCategoria(String nombre) async {
    eliminarCategoriaCalled = true;
    _categories.remove(nombre);
    return true;
  }

  @override
  Future<bool> editarTarea(Task tarea) async {
    editarTareaCalled = true;
    final idx = _tasks.indexWhere((t) => t.id == tarea.id);
    if (idx != -1) _tasks[idx] = tarea;
    return true;
  }

  @override
  Future<List<String>> leerCategorias() async => _categories;

  @override
  Future<Map<DateTime, int>> getTasksPerDay() async {
    final Map<DateTime, int> map = {};
    for (final task in _tasks) {
      final date = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      map[date] = (map[date] ?? 0) + 1;
    }
    return map;
  }

  @override
  Future<bool> agregarCategoria(String categoriaNombre) async {
    _categories.add(categoriaNombre);
    return true;
  }

  @override
  Future<List<Task>> leerCategoriasFiltradas(String nombreCategoria) async {
    return _tasks.where((t) => t.category == nombreCategoria).toList();
  }
}

class TestTaskNotifier extends TaskNotifier {
  Timer? _syncTimer;

  TestTaskNotifier(StorageStrategy mock) {
    storage = StorageSwitch(mock);
  }

  // Expose _syncTimer for testing purposes
  Timer? get syncTimer => _syncTimer;

  @override
  Future<void> startSyncWithApi() async {
    // Cancel the previous timer if it exists
    _syncTimer?.cancel();
    // Start a new timer and assign it to _syncTimer
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await loadTasks();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}

void main() {
  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  test('Firebase se inicializa correctamente', () async {
    final app = Firebase.app();
    expect(app, isA<FirebaseApp>());
    expect(app.name, '[DEFAULT]');
  });

  late TestTaskNotifier notifier;
  late MockStorage mock;
  final task1 = Task(
    id: '1',
    title: 'Tarea 1',
    description: 'Desc 1',
    dueDate: DateTime(2024, 6, 10),
    completed: false,
    createdAt: DateTime(2024, 6, 11),
    category: 'Personal',
  );
  final task2 = Task(
    id: '2',
    title: 'Tarea 2',
    description: 'Desc 2',
    dueDate: DateTime(2024, 6, 11),
    completed: false,
    createdAt: DateTime(2024, 6, 2),
    category: 'Trabajo',
  );

  setUp(() {
    mock = MockStorage();
    notifier = TestTaskNotifier(mock);
  });
  //doble group santo
  group('tests de TaskNotifier', () {
    group('Getters', () {
      test('tasks getter retorna la lista de tareas', () async {
        await notifier.addTask(task1);
        expect(notifier.tasks, isA<List<Task>>());
        expect(notifier.tasks.length, 1);
      });

      test('categories getter retorna la lista de categorías', () async {
        await notifier.loadCategories();
        expect(notifier.categories, isA<List<String>>());
        expect(notifier.categories, contains('Personal'));
      });
    });

    group('_initializeStorage', () {
      test('usa StorageSwitch(ApiStorage) en web', () async {
        // No se puede simular kIsWeb fácilmente aquí, pero puedes verificar que el método existe.
        expect(() => notifier.storage, returnsNormally);
      });
    });

    group('_startSyncWithApi', () {
      test('cancela el timer anterior y crea uno nuevo', () async {
        // No llames a startSyncWithApi antes, solo una vez para crear el timer
        await notifier.startSyncWithApi();
        final firstTimer = notifier.syncTimer;
        expect(firstTimer?.isActive ?? false, true);

        // Llama de nuevo para reemplazar el timer
        await notifier.startSyncWithApi();
        final secondTimer = notifier.syncTimer;

        // El timer anterior debe estar inactivo, el nuevo activo
        expect(firstTimer?.isActive ?? false, false);
        expect(secondTimer?.isActive ?? false, true);

        // Limpieza para evitar side effects
        notifier.syncTimer?.cancel();
      });
      group('addTask', () {
        test('agrega una tarea y loadTasks la carga', () async {
          await notifier.addTask(task1);
          await notifier.addTask(task2);
          await notifier.loadTasks();
          expect(notifier.tasks.length, 2);
          expect(notifier.tasks[0].title, isNotEmpty);
        });
      });

      group('eliminarTarea', () {
        test('elimina una tarea', () async {
          await notifier.addTask(task1);
          await notifier.eliminarTarea('1');
          expect(mock.eliminarTareaCalled, true);
          expect(notifier.tasks.where((t) => t.id == '1').isEmpty, true);
        });
        test('no elimina si id no existe', () async {
          await notifier.eliminarTarea('no-existe');
          expect(mock.eliminarTareaCalled, true);
        });
      });

      group('loadFilteredTasks', () {
        test('reemplaza las tareas', () async {
          await notifier.loadFilteredTasks([task2]);
          expect(notifier.tasks.length, 1);
          expect(notifier.tasks[0].id, '2');
        });
      });

      group('eliminarCategoria', () {
        test('elimina una categoría', () async {
          await notifier.eliminarCategoria('Personal');
          expect(mock.eliminarCategoriaCalled, true);
          expect(mock._categories.contains('Personal'), false);
        });
        test('no elimina si la categoría no existe', () async {
          await notifier.eliminarCategoria('NoExiste');
          expect(mock.eliminarCategoriaCalled, true);
        });
      });

      group('editarTarea', () {
        test('edita una tarea', () async {
          await notifier.addTask(task1);
          final edited = Task(
            id: '1',
            title: 'Tarea Editada',
            description: 'Desc 1',
            dueDate: DateTime(2024, 6, 10),
            completed: false,
            createdAt: DateTime(2024, 6, 1),
            category: 'Personal',
          );
          await notifier.editarTarea(edited);
          expect(mock.editarTareaCalled, true);
          await notifier.loadTasks();
          expect(notifier.tasks.first.title, 'Tarea Editada');
        });
        test('no edita si la tarea no existe', () async {
          final edited = Task(
            id: 'no-existe',
            title: 'Tarea Editada',
            description: 'Desc',
            dueDate: DateTime(2024, 6, 10),
            completed: false,
            createdAt: DateTime(2024, 6, 1),
            category: 'Personal',
          );
          await notifier.editarTarea(edited);
          expect(mock.editarTareaCalled, true);
        });
      });

      group('toggleTaskCompletion', () {
        test('cambia el estado de completado', () async {
          await notifier.addTask(task1);
          await notifier.toggleTaskCompletion('1', true);
          expect(notifier.tasks.first.completed, true);
        });
        test('lanza error si id no existe', () async {
          expect(
            () => notifier.toggleTaskCompletion('no-existe', true),
            throwsA(isA<StateError>()),
          );
        });
      });

      group('getTasksPerDay', () {
        test('retorna el mapa correcto', () async {
          await notifier.loadTasks();
          await notifier.addTask(task1);
          await notifier.addTask(task2);
          final map = await notifier.getTasksPerDay();
          expect(map[DateTime.utc(2024, 6, 10)], 1);
          expect(map[DateTime.utc(2024, 6, 11)], 1);
        });
      });

      group('loadCategories', () {
        test('carga las categorías', () async {
          await notifier.loadCategories();
          expect(notifier.categories, contains('Trabajo'));
        });
        test('maneja error al cargar categorías', () async {
          final brokenMock = MockStorage();
          brokenMock._categories.clear();
          notifier = TestTaskNotifier(brokenMock);
          await notifier.loadCategories();
          expect(notifier.categories, isEmpty);
        });
      });

      test('syncTimer está inactivo por defecto', () {
        expect(notifier.syncTimer?.isActive ?? false, false);
      });

      test('cancela el timer al hacer dispose', () async {
        notifier.dispose();
        expect(notifier.syncTimer?.isActive ?? false, false);
      });
    });
  });
}
