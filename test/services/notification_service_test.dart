// notification_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:to_do_list/services/notification_service.dart';
import 'package:to_do_list/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService', () {
    late NotificationService notificationService;
    late MockFlutterLocalNotificationsPlugin mockPlugin;

    setUp(() {
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      notificationService = NotificationService(plugin: mockPlugin);
      when(
        mockPlugin.show(any, any, any, any, payload: anyNamed('payload')),
      ).thenAnswer((_) async => true);
    });

    test('solo notifica una vez por tarea al día', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'desc',
        dueDate: tomorrow,
        completed: false,
        createdAt: today,
        category: 'Test',
      );

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(
        prefs.getBool('notified_1_${today.year}-${today.month}-${today.day}'),
        isNull,
      );

      await notificationService.showNotification([task]);
      verify(
        mockPlugin.show(any, any, any, any, payload: anyNamed('payload')),
      ).called(1);

      await prefs.setBool(
        'notified_1_${today.year}-${today.month}-${today.day}',
        true,
      );

      await notificationService.showNotification([task]);
      verifyNoMoreInteractions(mockPlugin);
    });

    test('initNotification inicializa el plugin solo una vez', () async {
      final mockPlugin = MockFlutterLocalNotificationsPlugin();
      when(mockPlugin.initialize(any)).thenAnswer((_) async => true);

      final service = NotificationService(plugin: mockPlugin);

      // Llama por primera vez: debe inicializar
      await service.initNotification();
      verify(mockPlugin.initialize(any)).called(1);

      // Llama por segunda vez: NO debe volver a inicializar
      await service.initNotification();
      verifyNoMoreInteractions(mockPlugin);

      // El getter debe ser true después de inicializar
      expect(service.isInitialized, isTrue);
    });
    // ...existing code...
  });
}
