import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin
      notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {

    const AndroidInitializationSettings
        androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings
        settings =
        InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings,
    );
  }

  static Future<void> showSOSNotification() async {

   const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
  'sos_channel',
  'SOS Alerts',
  importance: Importance.max,
  priority: Priority.high,
  enableVibration: true,
  playSound: true,
);

    const NotificationDetails
        details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      1,
      "🚨 SafeHer",
      "Emergency SOS is active",
      details,
    );
  }

  static Future<void>
      cancelNotification() async {

    await notifications.cancel(
      1,
    );
  }
}