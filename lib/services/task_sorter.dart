import 'package:to_do_list/models/task.dart';

class TaskSorter {
  static Future<List<Task>> sortTasksByTitle(List<Task> tasks) async {
    tasks.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return tasks; // Devuelve la lista ordenada por título
  }

  static Future<List<Task>> sortTasksByDueDate(List<Task> tasks) async {
    tasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null)
        return 0; // Ambos son nulos, no hay orden
      if (a.dueDate == null) return 1; // a es nulo, b no, a va después
      if (b.dueDate == null) return -1; // b es nulo, a no, b va después
      return a.dueDate!.compareTo(
        b.dueDate!,
      ); // Ordena por fecha de vencimiento
    });
    return tasks; // Devuelve la lista ordenada por fecha de vencimiento
  }
}
