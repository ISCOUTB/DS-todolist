import 'dart:math';
import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/data_manager.dart';

class AddTaskButton extends StatefulWidget {
  const AddTaskButton({super.key});

  @override
  State<AddTaskButton> createState() => _AddTaskButtonState();
}

class _AddTaskButtonState extends State<AddTaskButton> {

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController category = TextEditingController();
  bool completed = false; // Variable para almacenar el estado de la tarea
  DateTime? dueDate; // Variable para almacenar la fecha de vencimiento seleccionada


  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        // Acción al presionar el botón de agregar
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Agregar Tarea',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Aquí puedes agregar el formulario para agregar una tarea
                    TextField(
                      decoration: const InputDecoration(labelText: 'Título'),
                      controller: title,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      controller: description,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      controller: category,
                    ),
                    ListTile(
                      title: Text(
                        dueDate == null
                            ? 'Seleciona fecha de vencimiento'
                            : '${dueDate?.day}/${dueDate?.month}/${dueDate?.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        // Acción al seleccionar la fecha
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != dueDate) {
                          setState(() {
                            dueDate = picked; // Actualiza la fecha seleccionada
                          });
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final newTask = Task(
                          id: Random().toString(), // Genera un ID aleatorio
                          title: title.text,
                          description: description.text,
                          dueDate: dueDate,
                          completed: completed,
                          createdAt: DateTime.now(),
                          category: category.text,
                        );

                        DataManager.guardarDatosJSON(
                          newTask,
                        ); // Agrega la tarea a la lista

                        title.clear(); // Limpia el campo de título
                        description.clear(); // Limpia el campo de descripción
                        category.clear(); // Limpia el campo de categoría
                        dueDate = null; // Reinicia la fecha de vencimiento
                        completed = false; // Reinicia el estado de completada

                        Navigator.of(context).pop(); // Cierra el diálogo
                      },
                      child: const Text('Agregar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  }

    