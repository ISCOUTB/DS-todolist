import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:to_do_list/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DataManager {
  static Future<List<String>> loadCategories() async {
    final String response = await rootBundle.loadString('data/categories.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<String>();
  }

  static Future<List<Task>> loadTasks() async {
    final String response = await rootBundle.loadString('data/tasks_data.json');
    final Map<String, dynamic> data = json.decode(response);
    return (data['tasks'] as List).map((task) => Task.fromJson(task)).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    try {
      final filePath = 'data/tasks_data.json'; // Ruta al archivo
      final file = File(filePath);

      final jsonList = tasks.map((item) => item.toJson()).toList();
      await file.writeAsString(json.encode({'tasks': jsonList}));
    } catch (e) {
      print("Error saving todo items: $e");
    }
  }

  static Future<Map<DateTime, int>> getTasksPerDay() async {
    final String response = await rootBundle.loadString('data/tasks_data.json');
    final Map<String, dynamic> data = json.decode(response);

    final Map<DateTime, int> tasksPerDay = {};
    for (var task in data['tasks']) {
      final dueDate = DateTime.parse(task['dueDate']).toUtc();
      tasksPerDay[dueDate] = (tasksPerDay[dueDate] ?? 0) + 1;
    }
    return tasksPerDay;
  }

  static Future<void> saveTasksToCsv(List<Task> tasks) async {
    try {
      final filePath = 'data/tasks_data.csv';
      final file = File(filePath);

      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      final csvData = StringBuffer();
      csvData.writeln(
        'id,title,description,dueDate,completed,createdAt,category',
      ); // Header row
      for (var task in tasks) {
        csvData.writeln(
          '${task.id},${task.title},${task.description},${task.dueDate?.toIso8601String()},${task.completed},${task.createdAt.toIso8601String()},${task.category}',
        ); // Data rows
      }

      await file.writeAsString(csvData.toString());
    } catch (e) {
      print("Error saving tasks to CSV: $e");
    }
  }

  static Future<List<Task>> loadTasksFromCsv() async {
    try {
      final filePath = 'data/tasks_data.csv';
      final file = File(filePath);

      if (!await file.exists()) {
        return [];
      }

      final lines = await file.readAsLines();
      if (lines.isEmpty) return [];

      final tasks = <Task>[];
      for (var i = 1; i < lines.length; i++) {
        final values = lines[i].split(',');
        tasks.add(
          Task(
            id: values[0],
            title: values[1],
            description: values[2],
            dueDate: DateTime.parse(values[3]),
            completed: values[4].toLowerCase() == 'true',
            createdAt: DateTime.parse(values[5]),
            category: values[6],
          ),
        );
      }

      return tasks;
    } catch (e) {
      print("Error loading tasks from CSV: $e");
      return [];
    }
  }

  static Future<void> saveTaskToSharedPreferences(Task task) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar las tareas existentes
      final String? tasksJson = prefs.getString('tasks');
      List<Task> tasks = [];
      if (tasksJson != null) {
        final Map<String, dynamic> data = json.decode(tasksJson);
        tasks = (data['tasks'] as List).map((t) => Task.fromJson(t)).toList();
      }

      // Agregar la nueva tarea
      tasks.add(task);

      // Guardar la lista actualizada
      final jsonList = tasks.map((t) => t.toJson()).toList();
      await prefs.setString('tasks', json.encode({'tasks': jsonList}));
    } catch (e) {
      print("Error saving task to SharedPreferences: $e");
    }
  }

  static Future<List<Task>> loadTasksFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString('tasks');

      if (tasksJson == null) {
        return [];
      }

      final Map<String, dynamic> data = json.decode(tasksJson);
      return (data['tasks'] as List)
          .map((task) => Task.fromJson(task))
          .toList();
    } catch (e) {
      print("Error loading tasks from SharedPreferences: $e");
      return [];
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
}
