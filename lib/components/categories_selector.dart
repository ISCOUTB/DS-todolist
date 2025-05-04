import 'package:flutter/material.dart';
import 'package:to_do_list/services/data_manager.dart';

class CategoriesSelector extends StatefulWidget {
  final Function(String?) onCategorySelected; // Callback para notificar cambios
  final String? selectedCategory; // Categoría seleccionada
  CategoriesSelector({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  State<CategoriesSelector> createState() => _CategoriesSelectorState();
}

class _CategoriesSelectorState extends State<CategoriesSelector> {
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.selectedCategory != null &&
        _categories.contains(widget.selectedCategory!)) {
      _selectedCategory = widget.selectedCategory;
    } else {
      _selectedCategory =
          null; // Inicializa con null si no hay categoría seleccionada
    }
  }

  void _loadCategories() async {
    try {
      final categories = await DataManager.leerCategorias();
      setState(() {
        _categories = categories.toSet().toList(); // Elimina duplicados
      });
    } catch (e) {
      debugPrint('Error al cargar las categorías: $e');
    }
  }

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Categoria",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              widget.onCategorySelected(value); // Notifica el cambio
            }
          },
        ),
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Añadir nueva categoría"),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: "Nombre de la categoría",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  await DataManager.agregarCategoria(newCategory);
                  _loadCategories(); // Recargar categorías
                  setState(() {
                    _selectedCategory = newCategory;
                  });
                  widget.onCategorySelected(
                    newCategory,
                  ); // Notifica al widget padre
                }
                Navigator.pop(context); // Cierra el diálogo
              },
              child: const Text("Añadir"),
            ),
          ],
        );
      },
    );
  }
}
