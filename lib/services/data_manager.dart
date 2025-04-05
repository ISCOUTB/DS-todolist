import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:to_do_list/models/task.dart';

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
}
