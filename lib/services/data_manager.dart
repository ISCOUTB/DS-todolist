import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:to_do_list/models/task.dart';
import 'package:http/http.dart' as http;

class DataManager {
  static Future<List<String>> loadCategories() async {
    final String response = await rootBundle.loadString('data/categories.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<String>();
  }

  static Future<Map<DateTime, int>> getTasksPerDay() async {
    try {
      // Obtiene las tareas desde el servidor
      final List<Task> tasks = await leerDatosJSON();

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
      print('Error al obtener las tareas por día: $e');
      return {};
    }
  }

  static Future<void> guardarDatosJSON(Task task) async {
    final url = Uri.parse('http://localhost:5000/guardar_json');
    try {
      // Convierte la tarea a JSON
      final taskJson = task.toJson();

      // Realiza la solicitud HTTP POST
      final respuesta = await http.post(
        url,
        body: jsonEncode({'datos': taskJson}),
        headers: {'Content-Type': 'application/json'},
      );

      // Verifica el estado de la respuesta
      if (respuesta.statusCode == 200) {
        print('Tarea guardada exitosamente en el servidor.');
      } else {
        print('Error al guardar la tarea: ${respuesta.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('Error: La solicitud ha excedido el tiempo de espera.');
    } on SocketException catch (_) {
      print('Error: No se pudo conectar con el servidor.');
    } catch (e) {
      print('Error inesperado: $e');
    }
  }

  static Future<List<Task>> leerDatosJSON() async {
    final url = Uri.parse('http://127.0.0.1:5000/leer_json');
    try {
      // Realiza la solicitud HTTP con un tiempo de espera
      final respuesta = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
          ); // Tiempo de espera de 10 segundos

      if (respuesta.statusCode == 200) {
        // Decodificar el cuerpo de la respuesta JSON
        final Map<String, dynamic> data = jsonDecode(respuesta.body);
        return (data['tasks'] as List)
            .map((task) => Task.fromJson(task))
            .toList();
      }
    } on TimeoutException catch (_) {
      print('Error: La solicitud ha excedido el tiempo de espera.');
    } on SocketException catch (_) {
      print('Error: No se pudo conectar con el servidor.');
    } catch (e) {
      print('Error inesperado: $e');
    }
    // Retornar una lista vacía en caso de error
    return [];
  }

  static Future<List<String>> leerCategorias() async {
    final url = Uri.parse('http://127.0.0.1:5000/leer_categorias');
    try {
      // Realiza la solicitud HTTP con un tiempo de espera
      final respuesta = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
          ); // Tiempo de espera de 10 segundos

      if (respuesta.statusCode == 200) {
        // Decodificar el cuerpo de la respuesta JSON como una lista
        final List<dynamic> data = jsonDecode(respuesta.body);

        // Extraer los valores de la clave "name" de cada objeto
        return data.map((item) => item['name'] as String).toList();
      } else {
        print('Error al leer las categorías: ${respuesta.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('Error: La solicitud ha excedido el tiempo de espera.');
    } on SocketException catch (_) {
      print('Error: No se pudo conectar con el servidor.');
    } catch (e) {
      print('Error inesperado: $e');
    }
    // Retornar una lista vacía en caso de error
    return [];
  }

  static Future<List<Task>> leerCategoriasFiltradas(
    String nombreCategoria,
  ) async {
    final url = Uri.parse(
      'http://127.0.0.1:5000/buscar_categoria/$nombreCategoria',
    );
    try {
      final respuesta = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (respuesta.statusCode == 200) {
        final decodedData = jsonDecode(respuesta.body);

        // Verificar si la respuesta es una lista
        if (decodedData is List) {
          return decodedData.map((task) => Task.fromJson(task)).toList();
        } else if (decodedData is Map<String, dynamic> &&
            decodedData['tasks'] is List) {
          return (decodedData['tasks'] as List)
              .map((task) => Task.fromJson(task))
              .toList();
        }
      } else {
        print(
          'Error al leer las categorías filtradas: ${respuesta.statusCode}',
        );
      }
    } on TimeoutException catch (_) {
      print('Error: La solicitud ha excedido el tiempo de espera.');
    } on SocketException catch (_) {
      print('Error: No se pudo conectar con el servidor.');
    } catch (e) {
      print('Error inesperado: $e');
    }
    return [];
  }

  static Future<bool> eliminarTarea(String tareaId) async {
    final url = Uri.parse('http://127.0.0.1:5000/eliminar_tarea/$tareaId');
    try {
      // Realiza la solicitud HTTP DELETE
      final respuesta = await http
          .delete(url)
          .timeout(
            const Duration(seconds: 10),
          ); // Tiempo de espera de 10 segundos

      if (respuesta.statusCode == 200) {
        print('Tarea eliminada exitosamente.');
        return true;
      } else {
        print('Error al eliminar la tarea: ${respuesta.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('Error: La solicitud ha excedido el tiempo de espera.');
    } on SocketException catch (_) {
      print('Error: No se pudo conectar con el servidor.');
    } catch (e) {
      print('Error inesperado: $e');
    }
    return false; // Retorna false en caso de error
  }

  static Future<bool> eliminarCategoria(String categoriaNombre) async {
    final url = Uri.parse(
      'http://127.0.0.1:5000/eliminar_categoria/$categoriaNombre',
    );
    try {
      // Realiza la solicitud HTTP DELETE
      final respuesta = await http
          .delete(url)
          .timeout(
            const Duration(seconds: 10),
          ); // Tiempo de espera de 10 segundos

      if (respuesta.statusCode == 200) {
        print('Categoría eliminada exitosamente.');
        return true;
      } else {
        print('Error al eliminar la categoría: ${respuesta.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('Error: La solicitud ha excedido el tiempo de espera.');
    } on SocketException catch (_) {
      print('Error: No se pudo conectar con el servidor.');
    } catch (e) {
      print('Error inesperado: $e');
    }
    return false; // Retorna false en caso de error
  }

  static Future<bool> editarTarea(Task tarea) async {
    // Primero elimina la tarea existente
    final eliminado = await eliminarTarea(tarea.id);
    if (eliminado) {
      // Luego guarda la tarea con los cambios realizados
      try {
        await guardarDatosJSON(tarea);
        print('Tarea editada exitosamente.');
        return true;
      } catch (e) {
        print('Error al guardar la tarea editada: $e');
      }
    } else {
      print('Error al eliminar la tarea para editarla.');
    }
    return false; // Retorna false si algo falla
  }
}
