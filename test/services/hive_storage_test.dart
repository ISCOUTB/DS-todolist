import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/hive_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_platform_interface/src/method_channel_path_provider.dart';

class MockPathProvider extends PathProviderPlatform {
  @override
  Future<String> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Registra el mock para path_provider
    PathProviderPlatform.instance = MockPathProvider();

    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>('tasks');
  });

  group('HiveStorage', () {
    late HiveStorage hiveStorage;

    setUp(() {
      hiveStorage = HiveStorage();
    });

    tearDown(() async {
      await Hive.box<Task>('tasks').clear();
    });

    test('Debería guardar una tarea en Hive', () async {
      final task = Task(
        id: '1',
        title: 'Comprar comida',
        description: 'Ir al supermercado',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      );

      await hiveStorage.guardarTarea(task);

      final box = Hive.box<Task>('tasks');
      expect(box.get('1')?.title, 'Comprar comida');
    });

    test('Debería eliminar una tarea de Hive', () async {
      final task = Task(
        id: '1',
        title: 'Comprar comida',
        description: 'Ir al supermercado',
        dueDate: DateTime.now(),
        completed: false,
        createdAt: DateTime.now(),
        category: 'Personal',
      );

      await hiveStorage.guardarTarea(task);
      await hiveStorage.eliminarTarea('1');

      final box = Hive.box<Task>('tasks');
      expect(box.get('1'), null);
    });
  });
}
