import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/api_storage.dart';
import 'package:to_do_list/services/storage_switch.dart';
import 'package:to_do_list/services/task_sorter.dart';

class TaskNotifier extends ChangeNotifier {
  List<Task> _tasks = [];
  final storage = StorageSwitch(ApiStorage());

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await storage.leerTareas();
    _tasks = await TaskSorter.sortTasksByDueDate(_tasks);
    notifyListeners(); // Notifica a los widgets que los datos han cambiado
  }

  Future<void> addTask(Task task) async {
    await storage.guardarTarea(task);
    await loadTasks(); // Recarga las tareas después de añadir una nueva
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
    notifyListeners();
  }

  Future<Map<DateTime, int>> getTasksPerDay() async {
    final tasksPerDay = await storage.getTasksPerDay();
    return tasksPerDay.map((key, value) {
      final normalizedKey = DateTime.utc(key.year, key.month, key.day);
      return MapEntry(normalizedKey, value);
    });
  }
}
