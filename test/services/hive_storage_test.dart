import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/hive_storage.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());

  group('HiveStorage', () {
    late HiveStorage hiveStorage;

    setUp(() async {
      hiveStorage = HiveStorage();
      await Hive.openBox<Task>('tasks');
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
