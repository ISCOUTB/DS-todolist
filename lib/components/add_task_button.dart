import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/components/categories_selector.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:uuid/uuid.dart';

class AddTaskButton extends StatefulWidget {
  const AddTaskButton({super.key});

  @override
  _AddTaskButtonState createState() => _AddTaskButtonState();
}

class _AddTaskButtonState extends State<AddTaskButton> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _dueDate;
  bool _isCompleted = false;
  String? _selectedCategory; // Categoría seleccionada

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
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
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Añadir nueva tarea',
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
                            onCategorySelected: (selectedCategory) {
                              _selectedCategory = selectedCategory;
                            },
                          ),

                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: addTask,
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
                                  "Añadir tarea",
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
                );
              },
            );
          },
        );
      },
    );
  }

  void addTask() {
    if (_formKey.currentState!.validate()) {
      final String uniqueId = Uuid().v4(); // Genera un UUID único
      final newTask = Task(
        id: uniqueId,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        completed: _isCompleted,
        createdAt: DateTime.now(),
        category:
            _selectedCategory ??
            "General", // Usa la categoría seleccionada o "General" por defecto
      );

      try {
        context.read<TaskNotifier>().addTask(newTask);
        debugPrint('Task added successfully');
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
