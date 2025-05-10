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
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta la altura al contenido
          children: [
            ListTile(
              title: GestureDetector(
                onTap: () {
                  setState(() {
                    _isTitleExpanded = !_isTitleExpanded; // Alterna el estado
                  });
                },
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  firstChild: Text(
                    widget.task.title,
                    maxLines: 1, // Muestra solo 1 línea
                    overflow: TextOverflow.ellipsis, // Agrega "..."
                    style: TextStyle(
                      decoration:
                          widget.task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                  secondChild: Text(
                    widget.task.title,
                    style: TextStyle(
                      decoration:
                          widget.task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ), // Muestra todo el título
                  crossFadeState:
                      _isTitleExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.task.description.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded; // Alterna el estado
                        });
                      },
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        firstChild: Text(
                          widget.task.description,
                          maxLines: 3, // Muestra solo 3 líneas
                          overflow: TextOverflow.ellipsis, // Agrega "..."
                        ),
                        secondChild: Text(
                          widget.task.description,
                        ), // Muestra todo
                        crossFadeState:
                            _isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                      ),
                    ),
                  Text(
                    'Vence: ${widget.task.dueDate?.day}/${widget.task.dueDate?.month}/${widget.task.dueDate?.year}',
                    style: TextStyle(
                      color:
                          widget.task.dueDate != null &&
                                  widget.task.dueDate!.isBefore(
                                    DateTime.now(),
                                  ) &&
                                  !widget.task.completed
                              ? Colors.red
                              : null,
                    ),
                    maxLines: 1,
                  ),
                  if (widget.task.category.isNotEmpty)
                    Text(
                      'Categoria: ${widget.task.category}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EditTaskButton(task: widget.task),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: widget.onDelete,
                  ),
                  Checkbox(
                    value: widget.task.completed,
                    onChanged: widget.onToggleCompleted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
