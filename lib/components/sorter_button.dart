import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/services/task_sorter.dart';

class SorterButton extends StatefulWidget {
  const SorterButton({super.key});

  @override
  SorterButtonState createState() => SorterButtonState();
}

const String _sortByDate = 'Ordenar por fecha';
const String _sortByTitle = 'Ordenar por título';

class SorterButtonState extends State<SorterButton> {
  void _sortTasks(String option) async {
    final taskNotifier = Provider.of<TaskNotifier>(context, listen: false);

    if (option == _sortByTitle) {
      // Ordena por título
      final sortedTasksByTitle = await TaskSorter.sortTasksByTitle(
        taskNotifier.tasks,
      );
      await taskNotifier.loadFilteredTasks(sortedTasksByTitle);
    } else {
      final sortedTasksByDueDate = await TaskSorter.sortTasksByDueDate(
        taskNotifier.tasks,
      );
      await taskNotifier.loadFilteredTasks(sortedTasksByDueDate);
      // Ordena por fecha (por defecto)
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list), // Solo muestra el ícono
      onSelected: (value) {
        _sortTasks(value);
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(value: _sortByDate, child: Text(_sortByDate)),
            const PopupMenuItem(value: _sortByTitle, child: Text(_sortByTitle)),
          ],
    );
  }
}
