import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/data_manager.dart';

class TaskNotifier extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await DataManager.leerDatosJSON();
    notifyListeners(); // Notifica a los widgets que los datos han cambiado
  }

  Future<void> loadFilteredTasks(List<Task> filteredtasks) async {
    _tasks = filteredtasks;
    notifyListeners(); // Notifica a los widgets que los datos han cambiado
  }

  Future<void> addTask(Task task) async {
    await DataManager.guardarDatosJSON(task);
    await loadTasks(); // Recarga las tareas después de añadir una nueva
  }

  Future<void> eliminarTarea(String tareaId) async {
    final resultado = await DataManager.eliminarTarea(tareaId);
    if (resultado) {
      await loadTasks(); // Recarga las tareas después de eliminar una
      notifyListeners();
    }
  }

  Future<void> eliminarCategoria(String categoriaNombre) async {
    final resultado = await DataManager.eliminarCategoria(categoriaNombre);
    if (resultado) {
      // Aquí puedes recargar las categorías si es necesario
      notifyListeners();
    }
  }

  Future<void> editarTarea(Task tarea) async {
    final resultado = await DataManager.editarTarea(tarea);
    if (resultado) {
      await loadTasks(); // Recarga las tareas después de editar una
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id, bool isCompleted) {
    final task = tasks.firstWhere((task) => task.id == id);
    task.completed = isCompleted;
    notifyListeners();
  }
}
