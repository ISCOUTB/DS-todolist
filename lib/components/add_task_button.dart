import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/components/categories_selector.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:uuid/uuid.dart';

class AddTaskButton extends StatelessWidget {
  const AddTaskButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.grey,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const AddTaskForm(),
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});

  @override
  AddTaskFormState createState() => AddTaskFormState();
}

class AddTaskFormState extends State<AddTaskForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _dueDate;
  bool _isCompleted = false;
  String? _selectedCategory;

  void addTask() {
    if (_formKey.currentState!.validate()) {
      final String uniqueId = const Uuid().v4();
      final newTask = Task(
        id: uniqueId,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        completed: _isCompleted,
        createdAt: DateTime.now(),
        category: _selectedCategory ?? "General",
      );

      try {
        context.read<TaskNotifier>().addTask(newTask);
        Navigator.pop(context);

        _titleController.clear();
        _descriptionController.clear();
        _dueDate = null;
        _isCompleted = false;
      } catch (e) {
        debugPrint('Error: $e');
      }
    } else {
      debugPrint('Formulario no válido');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(102, 170, 170, 170),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Añadir nueva tarea',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Título',
                hintStyle: TextStyle(
                  //colorColor.fromARGB(255, 64, 64, 64)anco
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un título';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Descripción',
                hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 15),
            ListTile(
              title: Text(
                _dueDate == null
                    ? 'Seleccionar fecha de vencimiento'
                    : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null && picked != _dueDate) {
                  setState(() {
                    _dueDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 15),
            CategoriesSelector(
              onCategorySelected: (selectedCategory) {
                _selectedCategory = selectedCategory;
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: addTask,
              child: Container(
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
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
    );
  }
}
