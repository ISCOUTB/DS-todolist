import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/widgets/list_item_widget.dart';
import 'package:to_do_list/services/data_manager.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({super.key});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    DataManager.leerDatosJSON().then((loadedTasks) {
      setState(() {
        _tasks = loadedTasks;
      });
    });
  }

  void addTask(Task task) {
    setState(() {
      _tasks.add(task); // Agrega la nueva tarea a la lista
    });
  }

  void deleteTask(Task task) {
    setState(() {
      _tasks.remove(task); // Remove the task from the list
    });
    //DataManager.saveTaskToSharedPreferences(_tasks); // Save updated list
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: _tasks.isEmpty
          ? const Center(child: Text('No tasks available'))
          : ListView.builder(
              itemCount: _tasks.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListItemWidget(
                  task: task,
                  onDelete: () => deleteTask(task), // Pass delete callback
                );
              },
            ),
    );
  }
}