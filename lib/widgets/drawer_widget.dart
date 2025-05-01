import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/services/data_manager.dart';
import 'package:to_do_list/services/task_notifier.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoriesFuture = DataManager.leerCategorias();
    setState(() {}); // Asegura que el widget se reconstruya
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width * 0.025;

    return FutureBuilder<List<String>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar categorías'));
        } else {
          final categories = snapshot.data ?? [];
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    return index == 0
                        ? buildHeader(fontSize)
                        : buildMenuItem(categories[index - 1], fontSize);
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget buildHeader(double fontSize) => GestureDetector(
    onTap: () {
      context.read<TaskNotifier>().loadTasks(); // Cargar todas las tareas
    },
    child: DrawerHeader(
      decoration: BoxDecoration(color: Colors.grey),
      child: Container(
        alignment: AlignmentDirectional.bottomStart,
        child: AutoSizeText(
          'Categorías',
          minFontSize: 22,
          maxFontSize: 30,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );

  Widget buildMenuItem(String categoryName, double fontSize) => ListTile(
    leading: const Icon(Icons.category),
    title: AutoSizeText(
      categoryName, // Mostrar el nombre de la categoría
      minFontSize: 18,
      maxFontSize: 25,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
    ),
    onTap: () async {
      print('Selected category: $categoryName');
      final filteredTasks = await DataManager.leerCategoriasFiltradas(
        categoryName,
      );

      print('Filtered tasks: $filteredTasks');

      // ignore: use_build_context_synchronously
      context.read<TaskNotifier>().loadFilteredTasks(filteredTasks);
    },
  );
}
