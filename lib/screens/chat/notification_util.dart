import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as LocalNotifications;

class NotificationUtil {
  static LocalNotifications.FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      LocalNotifications.FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const LocalNotifications.AndroidInitializationSettings
        initializationSettingsAndroid =
        LocalNotifications.AndroidInitializationSettings('android');
    const LocalNotifications.InitializationSettings initializationSettings =
        LocalNotifications.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null, // Disable iOS notifications for simplicity
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static Future<void> showNotification(String? title, dynamic body) async {
    String notificationBody;
    if (body is String) {
      notificationBody = body;
    } else if (body is Map<String, dynamic>) {
      // Extract the "body" field from the map
      dynamic bodyField = body['body'];

      // Check if the "body" field is a String
      if (bodyField is String) {
        notificationBody = bodyField;
      } else {
        // Handle other types accordingly or provide a default value
        notificationBody = 'Default Value';
      }
    } else {
      // Handle other types accordingly or provide a default value
      notificationBody = 'Default Value';
    }
    const LocalNotifications.AndroidNotificationDetails
        androidPlatformChannelSpecifics =
        LocalNotifications.AndroidNotificationDetails(
      '"chat_messages"', // replace with your channel ID
      '"Chat Messages"', // replace with your channel name
      importance: LocalNotifications.Importance.max,
      priority: LocalNotifications.Priority.high,
    );
    const LocalNotifications.NotificationDetails platformChannelSpecifics =
        LocalNotifications.NotificationDetails(
            android: androidPlatformChannelSpecifics, iOS: null);

    await flutterLocalNotificationsPlugin.show(
      0, // notification ID
      title ?? '', // title
      notificationBody, // body
      platformChannelSpecifics,
      payload: 'chat_message', // optional payload
    );
  }
}
