import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  final bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationPlugin.initialize(initSettings);
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

  Future<void> showNotification(int id, String title, String body) async {
    await notificationPlugin.show(id, title, body, notificationDetails());
  }
}
