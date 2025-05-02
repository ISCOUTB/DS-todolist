import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/components/categories_selector.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_notifier.dart';

class EditTaskButton extends StatefulWidget {
  final Task task;
  const EditTaskButton({super.key, required this.task});

  @override
  State<EditTaskButton> createState() => _EditTaskButtonState();
}

class _EditTaskButtonState extends State<EditTaskButton> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _category;
  DateTime? _dueDate;
  DateTime? _createdAt;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task.title;
    _descriptionController.text = widget.task.description;
    _dueDate = widget.task.dueDate;
    _isCompleted = widget.task.completed;
    _createdAt = widget.task.createdAt;
    _category = widget.task.category;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        // Acción al presionar el botón de agregar
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Editar tarea',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Título',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa un título';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Descripción',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 15),
                            ListTile(
                              title: Text(
                                _dueDate == null
                                    ? 'Seleccionar fecha de vencimiento'
                                    : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
                              ),
                              trailing: Icon(Icons.calendar_today),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );

                                if (picked != null && picked != _dueDate) {
                                  setModalState(() {
                                    _dueDate = picked;
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 15),
                            CategoriesSelector(
                              selectedCategory: _category,
                              onCategorySelected: (onCategorySelected) {
                                _category = onCategorySelected;
                              },
                            ),
                            SizedBox(height: 20),

                            GestureDetector(
                              onTap: editTask,
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    "Editar tarea",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void editTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        id: widget.task.id, // Mantiene el mismo ID
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        completed: _isCompleted,
        createdAt:
            _createdAt ?? DateTime.now(), // Mantiene la fecha de creación
        category: _category ?? "General",
      );

      try {
        context.read<TaskNotifier>().editarTarea(newTask);
        debugPrint('Edit successfully');
        Navigator.pop(context); // Cierra el modal

        _titleController.clear(); // Limpia el campo de título
        _descriptionController.clear(); // Limpia el campo de descripción
        _dueDate = null; // Reinicia la fecha de vencimiento
        _isCompleted = false; // Reinicia el estado de completada
      } catch (e) {
        debugPrint('Error: $e');
      }
    } else {
      debugPrint('Formulario no válido');
    }
  }
}
