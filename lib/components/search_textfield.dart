import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_notifier.dart';

class SearchTextfield extends StatelessWidget {
  const SearchTextfield({super.key});

  List<Task> filtrarTareas(List<Task> tareas, String query) {
    final lowerQuery = query.toLowerCase();
    return tareas.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          task.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(69, 170, 170, 170),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white), // Letras blancas
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color.fromARGB(69, 170, 170, 170), // Fondo gris
          hintText: "Buscar tareas...",
          hintStyle: TextStyle(
            color: Color.fromARGB(179, 255, 255, 255),
          ), // Hint blanco tenue
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (value) {
          final todasLasTareas = context.read<TaskNotifier>().tasks;
          final filtradas = filtrarTareas(todasLasTareas, value);

          if (value.isEmpty) {
            // Si el campo de búsqueda está vacío, muestra todas las tareas
            context.read<TaskNotifier>().loadTasks();
          } else {
            // Filtra las tareas según el valor ingresado
            context.read<TaskNotifier>().loadFilteredTasks(filtradas);
          }
        },
      ),
    );
  }
}
