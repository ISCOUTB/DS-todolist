import 'package:hive/hive.dart';

part 'task.g.dart'; // Archivo generado automáticamente

@HiveType(typeId: 0) // Asigna un ID único para esta clase
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime? dueDate;

  @HiveField(4)
  bool completed;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.completed,
    required this.createdAt,
    required this.category,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }
}
