import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_list/models/task.dart';
import "package:to_do_list/models/storage_strategy.dart";

class ApiStorage implements StorageStrategy {
  final String baseUrl = 'http://172.191.195.204:5000';

  @override
  Future<void> guardarTarea(Task task) async {
    final url = Uri.parse('$baseUrl/guardar_json');
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
    final url = Uri.parse('$baseUrl/leer_json');
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
    final url = Uri.parse('$baseUrl/eliminar_tarea/$tareaId');
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
    final url = Uri.parse('$baseUrl/eliminar_categoria/$categoriaNombre');
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
    final url = Uri.parse('$baseUrl/buscar_categoria/$nombreCategoria');
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
    final url = Uri.parse('$baseUrl/leer_categorias');
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
    final url = Uri.parse('$baseUrl/agregar_categoria');
    try {
      final respuesta = await http.post(
        url,
        body: jsonEncode(categoriaNombre),
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
}
