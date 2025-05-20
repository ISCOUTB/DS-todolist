import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/models/storage_strategy.dart';
import 'package:to_do_list/widgets/drawer_widget.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/services/storage_switch.dart';
import 'package:to_do_list/models/task.dart';

class MockStorage extends StorageSwitch {
  MockStorage() : super(_MockStrategy() as StorageStrategy);

  @override
  Future<List<String>> leerCategorias() async => ['Trabajo', 'Personal'];
  @override
  Future<bool> agregarCategoria(String nombre) async => true;
  @override
  Future<List<Task>> leerCategoriasFiltradas(String nombre) async => [];
}

class _MockStrategy implements StorageStrategy {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTaskNotifier extends ChangeNotifier implements TaskNotifier {
  @override
  StorageSwitch get storage => MockStorage();

  @override
  Future<void> loadTasks() async {}

  @override
  Future<void> loadFilteredTasks(List filteredtasks) async {}

  @override
  Future<void> eliminarCategoria(String categoriaNombre) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<TaskNotifier>(
        create: (_) => MockTaskNotifier(),
        child: Builder(
          builder:
              (context) => Scaffold(
                drawer: const Drawer(child: DrawerWidget()),
                appBar: AppBar(title: const Text('Test')),
                body: const Center(child: Text('Body')),
              ),
        ),
      ),
    );
  }

  group('DrawerWidget', () {
    testWidgets('Muestra categorías correctamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      ScaffoldState state = tester.firstState(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('Categorías'), findsOneWidget);
      expect(find.text('Trabajo'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
    });

    testWidgets('Muestra botón para agregar categoría', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      ScaffoldState state = tester.firstState(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('Agregar Categoría'), findsOneWidget);
    });

    group('Diálogos', () {
      testWidgets('Al hacer tap en Agregar Categoría muestra diálogo', (
        tester,
      ) async {
        await tester.pumpWidget(createWidgetUnderTest());
        ScaffoldState state = tester.firstState(find.byType(Scaffold));
        state.openDrawer();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Agregar Categoría'));
        await tester.pumpAndSettle();
        expect(
          find.text('Agregar Categoría'),
          findsNWidgets(2),
        ); // Título y botón
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets(
        'Al hacer long press en una categoría muestra diálogo de eliminar',
        (tester) async {
          await tester.pumpWidget(createWidgetUnderTest());
          ScaffoldState state = tester.firstState(find.byType(Scaffold));
          state.openDrawer();
          await tester.pumpAndSettle();
          final categoryTile = find.text('Trabajo');
          await tester.longPress(categoryTile);
          await tester.pumpAndSettle();
          expect(find.text('Eliminar Categoría'), findsOneWidget);
          expect(
            find.text('¿Estás seguro de que deseas eliminar Trabajo?'),
            findsOneWidget,
          );
        },
      );
    });
  });
}
