import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/services/task_sorter.dart';

class SorterButton extends StatefulWidget {
  const SorterButton({Key? key}) : super(key: key);

  @override
  _SorterButtonState createState() => _SorterButtonState();
}

class _SorterButtonState extends State<SorterButton> {
  String _selectedOption = 'Ordenar por fecha';

  void _sortTasks(String option) async {
    final taskNotifier = Provider.of<TaskNotifier>(context, listen: false);

    if (option == 'Ordenar por título') {
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

    setState(() {
      _selectedOption = option;
    });
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
            const PopupMenuItem(
              value: 'Ordenar por fecha',
              child: Text('Ordenar por fecha'),
            ),
            const PopupMenuItem(
              value: 'Ordenar por título',
              child: Text('Ordenar por título'),
            ),
          ],
    );
  }
}
