import 'package:to_do_list/models/task.dart';

abstract class StorageStrategy {
  Future<void> guardarTarea(Task task);
  Future<List<Task>> leerTareas();
  Future<bool> editarTarea(Task tarea);
  Future<bool> eliminarTarea(String tareaId);
  Future<List<String>> leerCategorias();
  Future<bool> agregarCategoria(String categoriaNombre);
  Future<bool> eliminarCategoria(String categoriaNombre);
  Future<List<Task>> leerCategoriasFiltradas(String nombreCategoria);
  Future<Map<DateTime, int>> getTasksPerDay();
}
