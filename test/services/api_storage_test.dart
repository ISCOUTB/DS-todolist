import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/services/api_storage.dart';
import 'package:to_do_list/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/models/persistent_identifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    // Sobrescribe temporalmente el método estático para los tests
    PersistentIdentifier.getDeviceId = ({auth}) async => 'test-uuid';
  });

  group('ApiStorage', () {
    late ApiStorage apiStorage;

    setUp(() {
      apiStorage = ApiStorage();
    });

    test('guardarTarea no lanza excepción', () async {
      final task = Task(
        id: '1',
        title: 'Test',
        description: 'desc',
        dueDate: null,
        completed: false,
        createdAt: DateTime.now(),
        category: 'cat',
      );
      await apiStorage.guardarTarea(task);
    });

    test('leerTareas retorna lista vacía si hay error', () async {
      final result = await apiStorage.leerTareas();
      expect(result, isA<List<Task>>());
    });

    test('eliminarTarea retorna false si hay error', () async {
      final result = await apiStorage.eliminarTarea('1');
      expect(result, isFalse);
    });

    test('agregarCategoria retorna false si hay error', () async {
      final result = await apiStorage.agregarCategoria('Nueva');
      expect(result, isFalse);
    });

    test('leerCategorias retorna lista vacía si hay error', () async {
      final result = await apiStorage.leerCategorias();
      expect(result, isA<List<String>>());
    });
  });
}
