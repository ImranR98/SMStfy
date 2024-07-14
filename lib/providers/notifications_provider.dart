// Exposes functions that can be used to send notifications to the user
// Contains a set of pre-defined ObtainiumNotification objects that should be used throughout the app

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotification {
  late int id;
  late String title;
  late String message;
  late String channelCode;
  late String channelName;
  late String channelDescription;
  Importance importance;
  int? progPercent;
  bool onlyAlertOnce;

  AppNotification(this.id, this.title, this.message, this.channelCode,
      this.channelName, this.channelDescription, this.importance,
      {this.onlyAlertOnce = false, this.progPercent});
}

class NotificationsProvider {
  FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  bool isInitialized = false;

  Map<Importance, Priority> importanceToPriority = {
    Importance.defaultImportance: Priority.defaultPriority,
    Importance.high: Priority.high,
    Importance.low: Priority.low,
    Importance.max: Priority.max,
    Importance.min: Priority.min,
    Importance.none: Priority.min,
    Importance.unspecified: Priority.defaultPriority
  };

  Future<void> initialize() async {
    isInitialized = await notifications.initialize(const InitializationSettings(
            android: AndroidInitializationSettings('ic_notification'))) ??
        false;
  }

  Future<void> cancel(int id) async {
    if (!isInitialized) {
      await initialize();
    }
    await notifications.cancel(id);
  }

  Future<void> notifyRaw(
      int id,
      String title,
      String message,
      String channelCode,
      String channelName,
      String channelDescription,
      Importance importance,
      {bool cancelExisting = false,
      int? progPercent,
      bool onlyAlertOnce = false}) async {
    if (cancelExisting) {
      await cancel(id);
    }
    if (!isInitialized) {
      await initialize();
    }
    await notifications.show(
        id,
        title,
        message,
        NotificationDetails(
            android: AndroidNotificationDetails(channelCode, channelName,
                channelDescription: channelDescription,
                importance: importance,
                priority: importanceToPriority[importance]!,
                groupKey: 'dev.imranr.obtainium.$channelCode',
                progress: progPercent ?? 0,
                maxProgress: 100,
                showProgress: progPercent != null,
                onlyAlertOnce: onlyAlertOnce,
                indeterminate: progPercent != null && progPercent < 0)));
  }

  Future<void> notify(AppNotification notif, {bool cancelExisting = false}) =>
      notifyRaw(notif.id, notif.title, notif.message, notif.channelCode,
          notif.channelName, notif.channelDescription, notif.importance,
          cancelExisting: cancelExisting,
          onlyAlertOnce: notif.onlyAlertOnce,
          progPercent: notif.progPercent);
}
