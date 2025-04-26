import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/data_manager.dart';
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
  final List<String> _categories = [];
  DateTime? _dueDate;
  bool _isCompleted = false;
  String? _selectedCategory; // Categoría seleccionada

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Carga las categorías al iniciar el widget
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DataManager.loadCategories();
      setState(() {
        _categories.addAll(categories);
      });
    } catch (e) {
      debugPrint('Error al cargar categorías: $e');
    }
  }

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
                            maxLines: 3,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Categoria",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                hint: Text("Seleccionar categoría"),
                                items: [
                                  ..._categories.map((category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }),
                                  DropdownMenuItem<String>(
                                    value: "add_new",
                                    child: Row(
                                      children: const [
                                        Icon(Icons.add, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text("Añadir nueva categoría"),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == "add_new") {
                                    _showAddCategoryDialog(context);
                                  } else {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  }
                                },
                              ),
                            ],
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

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Añadir nueva categoría"),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(
              labelText: "Nombre de la categoría",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  setState(() {
                    _categories.add(newCategory);
                    _selectedCategory = newCategory;
                  });
                }
                Navigator.pop(context); // Cierra el diálogo
              },
              child: Text("Añadir"),
            ),
          ],
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
