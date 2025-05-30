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
      // Contenedor para el ListTile de las tareas
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:
            widget.task.completed
                ? const Color.fromARGB(69, 170, 170, 170).withAlpha(
                  25,
                ) // Fondo verde suave si está completada
                : const Color.fromARGB(69, 170, 170, 170), // Fondo normal si no
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              255,
              100,
              100,
              100,
            ).withAlpha((0.2 * 255).toInt()),
            blurRadius: 8, // Difuminado
            offset: const Offset(2, 4), // Desplazamiento horizontal y vertical
          ),
        ],
      ),
      child: ListTile(
        title: GestureDetector(
          onTap: () {
            setState(() {
              _isTitleExpanded = !_isTitleExpanded;
            });
          },
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: Text(
              widget.task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    widget.task.completed
                        ? const Color.fromARGB(255, 76, 175, 80)
                        : const Color.fromARGB(255, 255, 255, 255),
                decoration:
                    widget.task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                fontWeight:
                    widget.task.completed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            secondChild: Text(
              widget.task.title,
              style: TextStyle(
                color:
                    widget.task.completed
                        ? const Color.fromARGB(255, 76, 175, 80)
                        : const Color.fromARGB(255, 255, 255, 255),
                decoration:
                    widget.task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                fontWeight:
                    widget.task.completed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
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
                    _isExpanded = !_isExpanded;
                  });
                },
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  firstChild: Text(
                    widget.task.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: Text(widget.task.description),
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
                            widget.task.dueDate!.isBefore(DateTime.now()) &&
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
    );
  }
}
