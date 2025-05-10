import 'package:flutter/material.dart';
import 'package:to_do_list/components/edit_task_button.dart';
import 'package:to_do_list/models/task.dart';

class ListItemWidget extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggleCompleted;

  const ListItemWidget({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleCompleted,
  });

  @override
  State<ListItemWidget> createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {
  bool _isExpanded = false; // Estado para la descripción expandida
  bool _isTitleExpanded = false; // Estado para el título expandido

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
                task.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
          ),
          maxLines: 1,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            Text(
              'Vence: ${task.dueDate?.day}/${task.dueDate?.month}/${task.dueDate?.year}',
              style: TextStyle(
                color:
                    task.dueDate!.isBefore(DateTime.now()) && !task.completed
                        ? Colors.red
                        : null,
              ),
              maxLines: 1,
            ),
            if (task.category.isNotEmpty)
              Text(
                'Categoria: ${task.category}',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EditTaskButton(task: task),
            IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
            Checkbox(value: task.completed, onChanged: onToggleCompleted),
          ],
        ),
      ),
    );
  }
}
//   @override