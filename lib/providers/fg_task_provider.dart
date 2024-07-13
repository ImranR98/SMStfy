import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:smstfy/providers/settings_provider.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SMStfyFGTaskHandler());
}

class SMStfyFGTaskHandler extends TaskHandler {
  SmsReceiver receiver = SmsReceiver();
  SettingsProvider settingsProvider = SettingsProvider();

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    await settingsProvider.initializeSettings();
    receiver.onSmsReceived?.listen((SmsMessage msg) {
      print(msg.body);
      FlutterForegroundTask.updateService(
        notificationTitle: 'Received SMS',
        notificationText: 'From ${msg.sender}',
      );
      sendPort?.send(msg);
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {}
}

class FgTaskProvider with ChangeNotifier {
  ReceivePort? receivePort; // Subscribe to get data sent by the task
  sendToTask(String key, Object value) => FlutterForegroundTask.saveData(
      key: key, value: value); // Send data to the task

  Future<bool> get isRunning => FlutterForegroundTask.isRunningService;

  Future<bool> hasRequiredPermissions() async {
    return (await Permission.sms.isGranted) &&
        (await Permission.sms.isGranted) &&
        (await FlutterForegroundTask.isIgnoringBatteryOptimizations) &&
        await FlutterForegroundTask.checkNotificationPermission() ==
            NotificationPermission.granted;
  }

  Future<bool> requestAllRequiredPermissions() async {
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    if (!await Permission.sms.isGranted) {
      await Permission.sms.request();
    }
    if (!await Permission.contacts.isGranted) {
      await Permission.contacts.request();
    }
    return hasRequiredPermissions();
  }

  void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'SMStfy foreground service notification',
        channelDescription:
            'This notification appears when the SMStfy foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> startForegroundTask() async {
    bool result = false;
    await requestAllRequiredPermissions();
    final ReceivePort? rcvPort = FlutterForegroundTask.receivePort;
    result = registerReceivePort(rcvPort);
    if (await FlutterForegroundTask.isRunningService) {
      result = await FlutterForegroundTask.restartService();
    } else {
      result = await FlutterForegroundTask.startService(
        notificationTitle: 'SMStfy foreground service is running',
        notificationText: '',
        callback: startCallback,
      );
    }
    notifyListeners();
    return result;
  }

  Future<bool> stopForegroundTask() async {
    bool result = await FlutterForegroundTask.stopService();
    notifyListeners();
    return result;
  }

  bool registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }
    closeReceivePort();
    receivePort = newReceivePort;

    return receivePort != null;
  }

  void closeReceivePort() {
    receivePort?.close();
    receivePort = null;
  }

  FgTaskProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initForegroundTask();
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        registerReceivePort(newReceivePort);
      }
      if (await hasRequiredPermissions()) {
        startForegroundTask();
      }
    });
  }

  @override
  void dispose() {
    closeReceivePort();
    super.dispose();
  }
}
