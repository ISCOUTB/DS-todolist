import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/api_storage.dart';
import 'package:to_do_list/services/storage_switch.dart';
import 'package:to_do_list/services/task_sorter.dart';
import 'package:to_do_list/services/hive_storage.dart';

class TaskNotifier extends ChangeNotifier {
  List<Task> _tasks = [];
  List<String> _categories = [];

  late StorageSwitch storage;
  Timer? _syncTimer;

  TaskNotifier() {
    _initializeStorage();
  }

  List<Task> get tasks => _tasks;
  List<String> get categories => _categories;

  Future<void> _initializeStorage() async {
    if (kIsWeb) {
      // Si está en la web, usa la API
      storage = StorageSwitch(ApiStorage());
    } else if (Platform.isAndroid) {
      // Si está en Android, usa Hive
      storage = StorageSwitch(HiveStorage());

      // Configura la sincronización con la API cada hora si hay conexión
      startSyncWithApi();
    } else {
      // Por defecto, usa Hive
      storage = StorageSwitch(HiveStorage());
    }
  }

  Future<void> startSyncWithApi() async {
    // Cancela el temporizador anterior si existe
    if (_syncTimer != null) {
      _syncTimer!.cancel();
      _syncTimer = null;
    }

    final connectivity = Connectivity();
    final firebaseAuth = FirebaseAuth.instance;

    _syncTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final connectivityResult = await connectivity.checkConnectivity();
      // ignore: unrelated_type_equality_checks
      final bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected && firebaseAuth.currentUser != null) {
        // Si hay conexión y el usuario ha iniciado sesión en Firebase, sincroniza con la API
        final apiStorage = ApiStorage();
        for (final task in _tasks) {
          await apiStorage.guardarTarea(task);
        }
        debugPrint('Datos sincronizados con la API.');
      }
    });
  }

  Future<void> loadTasks() async {
    _tasks = await storage.leerTareas();
    _tasks = await TaskSorter.sortTasksByDueDate(_tasks);
    notifyListeners(); // Notifica a los widgets que los datos han cambiado
  }

  Future<void> addTask(Task task) async {
    await storage.guardarTarea(task);
    await loadTasks(); // Recarga las tareas después de añadir una nueva
    notifyListeners();
  }

  Future<void> eliminarTarea(String tareaId) async {
    final resultado = await storage.eliminarTarea(tareaId);
    if (resultado) {
      await loadTasks(); // Recarga las tareas después de eliminar una
      notifyListeners();
    }
  }

  Future<void> loadFilteredTasks(List<Task> filteredtasks) async {
    _tasks = filteredtasks;
    notifyListeners(); // Notifica a los widgets que los datos han cambiado
  }

  Future<void> eliminarCategoria(String categoriaNombre) async {
    final resultado = await storage.eliminarCategoria(categoriaNombre);
    if (resultado) {
      // Aquí puedes recargar las categorías si es necesario
      notifyListeners();
    }
  }

  Future<void> editarTarea(Task tarea) async {
    final resultado = await storage.editarTarea(tarea);
    if (resultado) {
      await loadTasks(); // Recarga las tareas después de editar una
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    final task = tasks.firstWhere((task) => task.id == id);
    task.completed = isCompleted;
    editarTarea(task); // Guarda la tarea actualizada
    notifyListeners();
  }

  Future<Map<DateTime, int>> getTasksPerDay() async {
    final tasksPerDay = await storage.getTasksPerDay();
    return tasksPerDay.map((key, value) {
      final normalizedKey = DateTime.utc(key.year, key.month, key.day);
      return MapEntry(normalizedKey, value);
    });
  }

  Future<void> loadCategories() async {
    try {
      _categories = await storage.leerCategorias();
      notifyListeners(); // Notifica a los widgets dependientes
    } catch (e) {
      debugPrint('Error al cargar las categorías: $e');
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}
