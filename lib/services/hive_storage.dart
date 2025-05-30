import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/storage_strategy.dart';
import 'package:flutter/material.dart';

class HiveStorage implements StorageStrategy {
  final String boxName = 'tasks';
  final String categoryBoxName = 'categories';

  Future<Box<T>> _getBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      final box = Hive.box<T>(name);
      // Inicializa categorías por defecto si es el box de categorías y está vacío
      if (name == categoryBoxName && box.isEmpty) {
        await box.addAll(['General', 'Trabajo', 'Personal'] as Iterable<T>);
      }
      return box;
    } else {
      final box = await Hive.openBox<T>(name);
      // Inicializa categorías por defecto si es el box de categorías y está vacío
      if (name == categoryBoxName && box.isEmpty) {
        await box.addAll(['General', 'Trabajo', 'Personal'] as Iterable<T>);
      }
      return box;
    }
  }

  @override
  Future<void> guardarTarea(Task task) async {
    try {
      final box = await _getBox<Task>(boxName);
      await box.put(task.id, task);
      debugPrint('Datos guardados exitosamente en Hive: ${task.toJson()}');
    } catch (e) {
      debugPrint('Error al guardar datos en Hive: $e');
    }
  }

  @override
  Future<List<Task>> leerTareas() async {
    try {
      final box = await _getBox<Task>(boxName);
      final tasks = box.values.toList();
      debugPrint('Datos leídos exitosamente desde Hive: $tasks');
      return tasks;
    } catch (e) {
      debugPrint('Error al leer datos desde Hive: $e');
      return [];
    }
  }

  @override
  Future<bool> eliminarTarea(String id) async {
    try {
      final box = Hive.box<Task>('tasks');
      if (box.containsKey(id)) {
        await box.delete(id);
        debugPrint('Tarea eliminada exitosamente de Hive.');
        return true;
      }
      debugPrint('No se encontró la tarea para eliminar.');
      return false;
    } catch (e) {
      debugPrint('Error al eliminar la tarea: $e');
      return false;
    }
  }

  @override
  Future<bool> agregarCategoria(String categoria) async {
    try {
      if (!Hive.isBoxOpen('categories')) {
        debugPrint('Error: Box "categories" is not open.');
        return false;
      }
      final box = Hive.box<String>('categories');
      if (box.values.contains(categoria)) {
        return false;
      }
      await box.add(categoria);
      debugPrint('Categoría agregada exitosamente en Hive: $categoria');
      return true;
    } catch (e) {
      debugPrint('Error al agregar categoría en Hive: $e');
      return false;
    }
  }

  @override
  Future<bool> editarTarea(Task tarea) async {
    try {
      final box = await _getBox<Task>(boxName);
      if (box.containsKey(tarea.id)) {
        await box.put(tarea.id, tarea);
        debugPrint('Tarea editada exitosamente en Hive: ${tarea.toJson()}');
        return true;
      } else {
        debugPrint('La tarea no existe en Hive: ${tarea.id}');
        return false;
      }
    } catch (e) {
      debugPrint('Error al editar tarea en Hive: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminarCategoria(String categoriaNombre) async {
    try {
      final box = await _getBox<String>(categoryBoxName);
      final key = box.keys.firstWhere(
        (k) => box.get(k) == categoriaNombre,
        orElse: () => null,
      );
      if (key != null) {
        await box.delete(key);
        debugPrint(
          'Categoría eliminada exitosamente de Hive: $categoriaNombre',
        );
        return true;
      } else {
        debugPrint('La categoría no existe en Hive: $categoriaNombre');
        return false;
      }
    } catch (e) {
      debugPrint('Error al eliminar categoría desde Hive: $e');
      return false;
    }
  }

  @override
  Future<List<String>> leerCategorias() async {
    try {
      final box = await _getBox<String>(categoryBoxName);
      final categories = box.values.toList();
      debugPrint('Categorías leídas exitosamente desde Hive: $categories');
      return categories;
    } catch (e) {
      debugPrint('Error al leer categorías desde Hive: $e');
      return [];
    }
  }

  @override
  Future<List<Task>> leerCategoriasFiltradas(String nombreCategoria) async {
    try {
      final box = await _getBox<Task>(boxName);
      final tasks =
          box.values.where((task) => task.category == nombreCategoria).toList();
      debugPrint(
        'Tareas filtradas por categoría "$nombreCategoria" leídas desde Hive: $tasks',
      );
      return tasks;
    } catch (e) {
      debugPrint('Error al leer tareas filtradas por categoría desde Hive: $e');
      return [];
    }
  }

  @override
  Future<Map<DateTime, int>> getTasksPerDay() async {
    try {
      final box = await _getBox<Task>(boxName);
      final tasksPerDay = <DateTime, int>{};

      for (var task in box.values) {
        final date = DateTime(task.date.year, task.date.month, task.date.day);
        tasksPerDay[date] = (tasksPerDay[date] ?? 0) + 1;
      }

      debugPrint('Tareas por día leídas exitosamente desde Hive: $tasksPerDay');
      return tasksPerDay;
    } catch (e) {
      debugPrint('Error al leer tareas por día desde Hive: $e');
      return {};
    }
  }
}
