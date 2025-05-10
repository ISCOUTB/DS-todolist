import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static const String _tasksKey = 'user_tasks';

  static Future<List<String>> loadCategories() async {
    final String response = await rootBundle.loadString('data/categories.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<String>();
  }

  static Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_tasksKey);

      if (jsonString == null || jsonString.isEmpty) {
        // Si no hay datos guardados, cargar los iniciales del JSON de assets
        return await _loadInitialTasksFromAssets();
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  // Cargar tareas iniciales desde assets (solo si no hay datos en SharedPreferences)
  static Future<List<Task>> _loadInitialTasksFromAssets() async {
    try {
      final String response = await rootBundle.loadString(
        'data/tasks_data.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      return (data['tasks'] as List)
          .map((task) => Task.fromJson(task))
          .toList();
    } catch (e) {
      print('Error loading initial tasks from assets: $e');
      return [];
    }
  }

  static Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = tasks.map((task) => task.toJson()).toList();
      return await prefs.setString(_tasksKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving tasks: $e');
      return false;
    }
  }
}
