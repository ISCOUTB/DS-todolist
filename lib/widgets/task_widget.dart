import 'package:flutter/material.dart';
import 'package:to_do_list/widgets/list_item_widget.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:provider/provider.dart';
class TaskWidget extends StatelessWidget {
  const TaskWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskNotifier>().tasks;

    return Container(
      color: Colors.grey[200],
      child: tasks.isEmpty
          ? const Center(child: Text('No tasks available'))
          : ListView.builder(
              itemCount: tasks.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListItemWidget(
                  task: task,
                  onDelete: () => context.read<TaskNotifier>().eliminarTarea(task.id),
                  onToggleCompleted: (bool? value) {},
                );
              },
            ),
    );
  }
}