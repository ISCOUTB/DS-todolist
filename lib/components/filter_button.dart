import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/widgets/task_sorter.dart';

class FilterButton extends StatefulWidget {
  const FilterButton({Key? key}) : super(key: key);

  @override
  _FilterButtonState createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  String _selectedOption = 'Ordenar por fecha';

  void _sortTasks(String option) async {
    final taskNotifier = Provider.of<TaskNotifier>(context, listen: false);

    if (_selectedOption == 'Ordenar por título') {
      final sortedTasks = await TaskSorter.sortTasksByTitle(taskNotifier.tasks);
      await taskNotifier.loadFilteredTasks(sortedTasks);
    } else {
      await taskNotifier.loadFilteredTasks(
        await TaskSorter.sortTasksByDueDate(taskNotifier.tasks),
      ); // Ordena por fecha (por defecto)
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
