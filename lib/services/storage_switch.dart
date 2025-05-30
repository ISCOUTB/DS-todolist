import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/storage_strategy.dart';

class StorageSwitch {
  late StorageStrategy _strategy;

  StorageSwitch(StorageStrategy strategy) {
    _strategy = strategy;
  }

  void setStrategy(StorageStrategy strategy) {
    _strategy = strategy;
  }

  Future<void> guardarTarea(task) async {
    await _strategy.guardarTarea(task);
  }

  Future<List<Task>> leerTareas() async {
    return await _strategy.leerTareas();
  }

  Future<bool> eliminarTarea(String idtarea) async {
    return await _strategy.eliminarTarea(idtarea);
  }

  Future<bool> agregarCategoria(String categoriaNombre) async {
    return await _strategy.agregarCategoria(categoriaNombre);
  }

  Future<bool> eliminarCategoria(String categoriaNombre) async {
    return await _strategy.eliminarCategoria(categoriaNombre);
  }

  Future<List<Task>> leerCategoriasFiltradas(String nombreCategoria) async {
    return await _strategy.leerCategoriasFiltradas(nombreCategoria);
  }

  Future<List<String>> leerCategorias() async {
    return await _strategy.leerCategorias();
  }

  Future<bool> editarTarea(Task tarea) async {
    return await _strategy.editarTarea(tarea);
  }

  Future<Map<DateTime, int>> getTasksPerDay() async {
    return await _strategy.getTasksPerDay();
  }
}
