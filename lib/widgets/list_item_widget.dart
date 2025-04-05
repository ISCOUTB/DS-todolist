import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';

class ListItemWidget extends StatelessWidget {
  final Task task;

  const ListItemWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Container(
        height: 100,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) Text(task.description),
              Text(
                'Vence: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                style: TextStyle(
                  color:
                      task.dueDate.isBefore(DateTime.now()) && !task.completed
                          ? Colors.red
                          : null,
                ),
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
              IconButton(icon: Icon(Icons.edit), onPressed: () => {}),
              IconButton(icon: Icon(Icons.delete), onPressed: () => {}),
              Checkbox(value: task.completed, onChanged: (bool? value) {}),
            ],
          ),
        ),
      ),
    );
  }
}
