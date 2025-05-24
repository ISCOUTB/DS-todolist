import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/components/categories_selector.dart';
import 'package:to_do_list/services/storage_switch.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/models/storage_strategy.dart';

// Fake StorageStrategy for testing
class FakeStorage implements StorageStrategy {
  final List<String> _categories = ['General', 'Trabajo', 'Personal'];

  @override
  Future<List<String>> leerCategorias() async => _categories;

  @override
  Future<bool> agregarCategoria(String categoriaNombre) async {
    _categories.add(categoriaNombre);
    return true;
  }

  // Métodos no usados en este test:
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'CategoriesSelector muestra categorías y permite añadir una nueva',
    (WidgetTester tester) async {
      String? selectedCategory;
      final notifier = TaskNotifier();
      notifier.storage = StorageSwitch(FakeStorage());

      await tester.pumpWidget(
        ChangeNotifierProvider<TaskNotifier>.value(
          value: notifier,
          child: MaterialApp(
            home: Scaffold(
              body: CategoriesSelector(
                onCategorySelected: (cat) {
                  selectedCategory = cat;
                },
              ),
            ),
          ),
        ),
      );
      // Espera a que las categorías se carguen y el widget se reconstruya
      await tester.pumpAndSettle();

      // Abre el DropdownButton
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Verifica que las categorías iniciales estén en el Dropdown
      expect(find.text('General'), findsWidgets);
      expect(find.text('Trabajo'), findsWidgets);
      expect(find.text('Personal'), findsWidgets);

      // Selecciona una categoría existente
      await tester.tap(find.text('Trabajo').last);
      await tester.pumpAndSettle();
      expect(selectedCategory, 'Trabajo');

      // Abre el diálogo para añadir nueva categoría
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Añadir nueva categoría').last);
      await tester.pumpAndSettle();

      // Escribe el nombre de la nueva categoría y pulsa "Añadir"
      await tester.enterText(find.byType(TextField), 'NuevaCat');
      await tester.tap(find.text('Añadir'));
      await tester.pumpAndSettle();

      // Abre el DropdownButton para ver la nueva categoría
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Verifica que la nueva categoría fue seleccionada y notificada
      expect(selectedCategory, 'NuevaCat');
      expect(find.text('NuevaCat'), findsWidgets);
    },
  );
}
