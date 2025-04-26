class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  late final bool completed;
  final DateTime createdAt;
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
      dueDate: DateTime.parse(json['dueDate']),
      completed: json['completed'],
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