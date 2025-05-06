import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/storage_strategy.dart';
import 'package:flutter/material.dart';

class HiveStorage implements StorageStrategy {
  final String boxName = 'tasks';

  @override
  Future<void> guardarTarea(Task task) async {
    try {
      final box = await Hive.openBox<Task>(
        boxName,
      ); // Asegúrate de que el Box sea de tipo Task
      await box.put(task.id, task); // Almacena el objeto Task directamente
      debugPrint('Datos guardados exitosamente en Hive: ${task.toJson()}');
    } catch (e) {
      debugPrint('Error al guardar datos en Hive: $e');
    }
  }

  @override
  Future<List<Task>> leerTareas() async {
    try {
      final box = await Hive.openBox<Task>(
        boxName,
      ); // Asegúrate de que el Box sea de tipo Task
      final tasks =
          box.values.toList(); // Hive ya deserializa los datos en objetos Task
      debugPrint('Datos leídos exitosamente desde Hive: $tasks');
      return tasks;
    } catch (e) {
      debugPrint('Error al leer datos desde Hive: $e');
      return [];
    }
  }

  @override
  Future<bool> eliminarTarea(String tareaId) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.delete(tareaId);
      debugPrint('Datos eliminados exitosamente de Hive.');
      return true;
    } catch (e) {
      debugPrint('Error al eliminar datos desde Hive: $e');
      return false;
    }
  }

  @override
  Future<bool> agregarCategoria(String categoriaNombre) {
    // TODO: implement agregarCategoria
    throw UnimplementedError();
  }

  @override
  Future<bool> editarTarea(Task tarea) {
    // TODO: implement editarTarea
    throw UnimplementedError();
  }

  @override
  Future<bool> eliminarCategoria(String categoriaNombre) {
    // TODO: implement eliminarCategoria
    throw UnimplementedError();
  }

  @override
  Future<List<String>> leerCategorias() {
    // TODO: implement leerCategorias
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> leerCategoriasFiltradas(String nombreCategoria) {
    // TODO: implement leerCategoriasFiltradas
    throw UnimplementedError();
  }
}
