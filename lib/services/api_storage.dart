import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/storage_strategy.dart';
import 'package:to_do_list/models/persistent_identifier.dart';

class ApiStorage implements StorageStrategy {
  final String baseUrl = 'http://miapiservice.sytes.net:5000';

  Future<String> _getUuid() async {
    return await PersistentIdentifier.getDeviceId();
  }

  @override
  Future<void> guardarTarea(Task task) async {
    final uuid = await _getUuid();
    final url = Uri.parse('$baseUrl/guardar_json/$uuid');
    try {
      final taskJson = {'datos': task.toJson()};
      debugPrint('JSON enviado: ${jsonEncode(taskJson)}');

      final respuesta = await http.post(
        url,
        body: jsonEncode(taskJson),
        headers: {'Content-Type': 'application/json'},
      );

      if (respuesta.statusCode == 200) {
        debugPrint('Tarea guardada exitosamente en el servidor.');
      } else {
        debugPrint(
          'Error al guardar la tarea en el servidor: ${respuesta.statusCode}, '
          'Respuesta: ${respuesta.body}',
        );
      }
    } catch (e) {
      debugPrint('Error al guardar la tarea en el servidor: $e');
    }
  }

  @override
  Future<List<Task>> leerTareas() async {
    final uuid = await _getUuid();
    final url = Uri.parse('$baseUrl/leer_json/$uuid');
    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        return (data['tasks'] as List)
            .map((task) => Task.fromJson(task))
            .toList();
      }
    } catch (e) {
      debugPrint('Error al leer datos desde el servidor: $e');
    }
    return [];
  }

  @override
  Future<bool> eliminarTarea(String tareaId) async {
    final uuid = await _getUuid();
    final url = Uri.parse('$baseUrl/eliminar_tarea/$uuid/$tareaId');
    try {
      final respuesta = await http.delete(url);
      if (respuesta.statusCode == 200) {
        debugPrint('Tarea eliminada exitosamente del servidor.');
        return true;
      } else {
        debugPrint('Error al eliminar la tarea: ${respuesta.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al eliminar la tarea desde el servidor: $e');
    }
    return false;
  }

  @override
  Future<bool> eliminarCategoria(String categoriaNombre) async {
    final uuid = await _getUuid();
    final url = Uri.parse('$baseUrl/eliminar_categoria/$uuid/$categoriaNombre');
    try {
      final respuesta = await http.delete(url);
      if (respuesta.statusCode == 200) {
        debugPrint('Categoría eliminada exitosamente del servidor.');
        return true;
      } else {
        debugPrint('Error al eliminar la categoría: ${respuesta.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al eliminar la categoría desde el servidor: $e');
    }
    return false;
  }

  @override
  Future<bool> editarTarea(Task tarea) async {
    final eliminado = await eliminarTarea(tarea.id);
    if (eliminado) {
      try {
        await guardarTarea(tarea);
        debugPrint('Tarea editada exitosamente en el servidor.');
        return true;
      } catch (e) {
        debugPrint('Error al editar la tarea en el servidor: $e');
      }
    } else {
      debugPrint('Error al eliminar la tarea para editarla.');
    }
    return false;
  }

  @override
  Future<List<Task>> leerCategoriasFiltradas(String nombreCategoria) async {
    final uuid = await _getUuid();
    final url = Uri.parse('$baseUrl/buscar_categoria/$uuid/$nombreCategoria');
    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final decodedData = jsonDecode(respuesta.body);

        if (decodedData is List) {
          return decodedData.map((task) => Task.fromJson(task)).toList();
        } else if (decodedData is Map<String, dynamic> &&
            decodedData['tasks'] is List) {
          return (decodedData['tasks'] as List)
              .map((task) => Task.fromJson(task))
              .toList();
        }
      } else {
        debugPrint(
          'Error al leer las categorías filtradas: ${respuesta.statusCode}',
        );
      }
    } catch (e) {
      debugPrint(
        'Error al leer las categorías filtradas desde el servidor: $e',
      );
    }
    return [];
  }

  @override
  Future<List<String>> leerCategorias() async {
    final uuid = await _getUuid();
    final url = Uri.parse('$baseUrl/leer_categorias/$uuid');
    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final List<dynamic> data = jsonDecode(respuesta.body);
        return data.map((item) => item['name'] as String).toList();
      } else {
        debugPrint('Error al leer las categorías: ${respuesta.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al leer las categorías desde el servidor: $e');
    }
    return [];
  }

  @override
  Future<bool> agregarCategoria(String categoriaNombre) async {
    final uuid = await _getUuid();
    final url = Uri.parse('$baseUrl/agregar_categoria/$uuid');
    try {
      final respuesta = await http.post(
        url,
        body: jsonEncode({"name": categoriaNombre}),
        headers: {'Content-Type': 'application/json'},
      );

      if (respuesta.statusCode == 200) {
        debugPrint('Categoría agregada exitosamente en el servidor.');
        return true;
      } else {
        debugPrint('Error al agregar la categoría: ${respuesta.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al agregar la categoría en el servidor: $e');
    }
    return false;
  }

  @override
  Future<Map<DateTime, int>> getTasksPerDay() async {
    try {
      // Obtiene las tareas desde el servidor
      final List<Task> tasks = await leerTareas();

      // Procesa las tareas para contar cuántas hay por día
      final Map<DateTime, int> tasksPerDay = {};
      for (var task in tasks) {
        if (task.dueDate != null) {
          final dueDate = DateTime(
            task.dueDate!.year,
            task.dueDate!.month,
            task.dueDate!.day,
          );
          tasksPerDay[dueDate] = (tasksPerDay[dueDate] ?? 0) + 1;
        }
      }

      return tasksPerDay;
    } catch (e) {
      debugPrint('Error al obtener las tareas por día: $e');
      return {};
    }
  }
}
