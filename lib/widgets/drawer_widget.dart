import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final storage = context.read<TaskNotifier>().storage;
    _categoriesFuture = storage.leerCategorias();
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
          return const Center(child: Text('Error loading categories'));
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
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: AutoSizeText(
                  'Agregar Categoría',
                  minFontSize: 18,
                  maxFontSize: 25,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  // la lógica para agregar una nueva categoría
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'Agregar Categoría', //Widget cateiora inicio
                          style: TextStyle(color: Colors.white),
                        ),
                        content: TextField(
                          onSubmitted: (value) async {
                            final storage =
                                Provider.of<TaskNotifier>(
                                  context,
                                  listen: false,
                                ).storage;
                            await storage.agregarCategoria(value);
                            if (context.mounted) {
                              _loadCategories(); // Recargar categorías después de agregar
                              Navigator.of(context).pop();
                            } // <--- chequeo de seguridad
                          },
                          decoration: const InputDecoration(
                            hintText: 'Nombre de la categoría',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }

  Widget buildHeader(double fontSize) => GestureDetector(
    onTap: () {
      // Aquí puedes agregar la lógica para manejar el toque en el encabezado
      context
          .read<TaskNotifier>()
          .loadTasks(); // Recargar tareas al tocar el encabezado
    },
    child: DrawerHeader(
      decoration: const BoxDecoration(
        color: Color.fromARGB(
          102,
          170,
          170,
          170,
        ), // Color de fondo del encabezado de "Categorias"
      ),
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
      debugPrint('Selected category: $categoryName');
      final storage = Provider.of<TaskNotifier>(context, listen: false).storage;
      final filteredTasks = await storage.leerCategoriasFiltradas(categoryName);

      if (!mounted) return; // <--- chequeo de seguridad

      debugPrint('Filtered tasks: $filteredTasks');
      context.read<TaskNotifier>().loadFilteredTasks(filteredTasks);
    },
    onLongPress: () {
      // Aquí puedes agregar la lógica para eliminar la categoría
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Eliminar Categoría'),
            content: Text(
              '¿Estás seguro de que deseas eliminar $categoryName?',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await context.read<TaskNotifier>().eliminarCategoria(
                    categoryName,
                  );
                  if (context.mounted) {
                    _loadCategories(); // Recargar categorías después de eliminar
                    Navigator.of(context).pop();
                  } // <--- chequeo de seguridad
                },
                child: const Text('Eliminar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
    },
  );
}
