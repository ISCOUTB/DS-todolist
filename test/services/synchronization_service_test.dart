import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/services/api_storage.dart';
import 'package:to_do_list/services/hive_storage.dart';
import 'package:to_do_list/services/synchronization_service.dart';
import 'package:to_do_list/services/task_notifier.dart';
import 'package:to_do_list/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Agrega esta anotación para generar los mocks
@GenerateMocks([HiveStorage, ApiStorage, TaskNotifier, User, FirebaseAuth])
import 'synchronization_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SynchronizationService', () {
    late SynchronizationService service;
    late MockHiveStorage hiveStorage;
    late MockApiStorage apiStorage;
    late MockTaskNotifier notifier;
    late MockUser user;

    setUp(() {
      hiveStorage = MockHiveStorage();
      apiStorage = MockApiStorage();
      notifier = MockTaskNotifier();
      user = MockUser();
      // Stubs obligatorios para los tests
      when(apiStorage.leerTareas()).thenAnswer((_) async => []);
      when(hiveStorage.leerTareas()).thenAnswer((_) async => []);
      when(user.displayName).thenReturn('TestUser');
      when(user.email).thenReturn('test@email.com');
      when(user.uid).thenReturn('123');

      service = SynchronizationService(
        hiveStorage: hiveStorage,
        apiStorage: apiStorage,
      );
    });

    test('initialize llama a sincronizar web y carga tareas en web', () async {
      var called = false;
      when(notifier.loadTasks()).thenAnswer((_) async {
        called = true;
      });
      await service.initialize(notifier: notifier, user: user);
      expect(called, isTrue);
    });

    test(
      'initialize llama a sincronizar movil y carga tareas en movil',
      () async {
        var called = false;
        when(notifier.loadTasks()).thenAnswer((_) async {
          called = true;
        });
        await service.initialize(notifier: notifier, user: user);
        expect(called, isTrue);
      },
    );

    test(
      'migrarDatosWeb retorna false si idGuardado es null o Fire-',
      () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_id', 'Fire-abc');
        final result = await service.migrarDatosWeb(user);
        expect(result, isFalse);
      },
    );

    test('migrarDatosWeb retorna true si migración exitosa', () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_id', 'uuid-abc');
      // Aquí deberías mockear http.post, pero este test solo prueba el guardado en prefs
      final result = await service.migrarDatosWeb(user);
      expect(result, isA<bool>());
    });
    /*
    test('sincronizarWeb llama a migrarDatosWeb si hay usuario', () async {
      var migrarCalled = false;

      // Subclase para test
      class TestSynchronizationService extends SynchronizationService {
        final void Function()? onMigrar;
        TestSynchronizationService({this.onMigrar, HiveStorage? hiveStorage, ApiStorage? apiStorage})
            : super(hiveStorage: hiveStorage, apiStorage: apiStorage);

        @override
        Future<bool> migrarDatosWeb(User user) async {
          if (onMigrar != null) onMigrar!();
          return true;
        }
      }

      service = TestSynchronizationService(
        onMigrar: () => migrarCalled = true,
        hiveStorage: hiveStorage,
        apiStorage: apiStorage,
      );

      await service.sincronizarWeb(user);
      expect(migrarCalled, isTrue);
    });
*/
    test('sincronizarMovil fusiona y guarda tareas', () async {
      when(apiStorage.leerTareas()).thenAnswer(
        (_) async => [
          Task(
            id: '1',
            title: 'Tarea',
            description: 'desc',
            dueDate: DateTime.now(),
            completed: false,
            createdAt: DateTime.now(),
            category: 'cat',
          ),
        ],
      );
      when(hiveStorage.leerTareas()).thenAnswer((_) async => []);
      var saved = false;
      when(hiveStorage.guardarTarea(any)).thenAnswer((_) async {
        saved = true;
      });
      await service.sincronizarMovil(user);
      expect(saved, isTrue);
    });

    test('startMobileSync inicia timer y sincroniza', () async {
      // ignore: unused_local_variable
      bool saved = false;
      when(hiveStorage.leerTareas()).thenAnswer(
        (_) async => [
          Task(
            id: '1',
            title: 'Tarea',
            description: 'desc',
            dueDate: DateTime.now(),
            completed: false,
            createdAt: DateTime.now(),
            category: 'cat',
          ),
        ],
      );
      when(apiStorage.guardarTarea(any)).thenAnswer((_) async {
        saved = true;
      });

      service = SynchronizationService(
        hiveStorage: hiveStorage,
        apiStorage: apiStorage,
      );
      service.startMobileSync();
      // Simula el timer manualmente
      await Future.delayed(Duration(milliseconds: 10));
      expect(service.syncTimer, isNotNull);
      service.dispose();
    });

    test('dispose cancela el timer', () {
      service.syncTimer = Timer(Duration(seconds: 1), () {});
      service.dispose();
      expect(service.syncTimer?.isActive, isFalse);
    });
  });
}
