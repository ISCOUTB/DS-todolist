import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationPlugin;
  bool _isInitialized = false;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : notificationPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'daily_channel_id',
          'Daily Notifications',
          channelDescription: 'Daily notifications channel',
          importance: Importance.max,
          priority: Priority.high,
        );

    return const NotificationDetails(android: androidPlatformChannelSpecifics);
  }

  Future<void> showNotification(tasks) async {
    if (tasks.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    for (var task in tasks) {
      if (task.dueDate == null) continue;
      if (task.completed) continue;

      final dueDate = task.dueDate!;
      final difference =
          dueDate
              .difference(DateTime(today.year, today.month, today.day))
              .inDays;

      // Notifica si la tarea vence mañana o antes (pero aún no ha pasado)
      if (difference <= 1 && difference >= 0) {
        final notifiedKey = 'notified_${task.id}_$todayStr';
        final alreadyNotified = prefs.getBool(notifiedKey) ?? false;

        if (!alreadyNotified) {
          int id = int.tryParse(task.id) ?? task.hashCode;
          await notificationPlugin.show(
            id,
            'Tarea Por Vencer',
            'La tarea "${task.title}" vence el ${dueDate.day}/${dueDate.month}/${dueDate.year}',
            notificationDetails(),
            payload: null,
          );
          await prefs.setBool(notifiedKey, true);
        }
      }
    }
  }
}
