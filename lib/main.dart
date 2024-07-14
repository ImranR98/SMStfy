import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:smstfy/components/custom_app_bar.dart';
import 'package:smstfy/components/settings_form.dart';
import 'package:smstfy/providers/notifications_provider.dart';
import 'package:smstfy/providers/ntfy_provider.dart';
import 'package:smstfy/providers/settings_provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ChangeNotifierProvider(create: (context) => NtfyProvider()),
    ],
    child: const SMStfy(),
  ));
}

class SMStfy extends StatelessWidget {
  const SMStfy({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      useMaterial3: true,
    );
    ThemeData darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue, brightness: Brightness.dark),
      useMaterial3: true,
    );
    return MaterialApp(
        title: 'SMStfy',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: '/',
        routes: {'/': (context) => const MainPage()});
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class NavigationPageItem {
  late String title;
  late IconData icon;
  late Widget widget;

  NavigationPageItem(this.title, this.icon, this.widget);
}

class _MainPageState extends State<MainPage> {
  late final ScrollController scrollController = ScrollController();

  Future<bool> checkPermissions() async =>
      (await Permission.sms.isGranted) &&
      (await Permission.ignoreBatteryOptimizations.isGranted) &&
      (await Permission.notification.isGranted);
  requestPermissions() async {
    if (!await Permission.sms.isGranted) {
      await Permission.sms.request();
    }
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SettingsProvider settingsProvider = SettingsProvider();
    NtfyProvider ntfyProvider = NtfyProvider();
    NotificationsProvider notificationsProvider = NotificationsProvider();
    SmsReceiver receiver = SmsReceiver();
    settingsProvider.initializeSettings().whenComplete(() {
      receiver.onSmsReceived?.listen((SmsMessage msg) async {
        try {
          await ntfyProvider.sendSMSNotification(msg, settingsProvider.ntfyUrl,
              settingsProvider.receiveTopicName, settingsProvider.ntfyAuthData);
        } catch (e) {
          notificationsProvider.notify(AppNotification(
              1,
              'Error Posting SMS',
              e.toString(),
              'ntfy_post_error',
              'SMS Posting Error',
              'These notifications tell you when an SMS could not be forwarded to the ntfy server.',
              Importance.defaultImportance));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Scaffold(
          body: Scrollbar(
              interactive: true,
              controller: scrollController,
              child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  slivers: <Widget>[
                    const CustomAppBar(title: 'SMStfy'),
                    SliverToBoxAdapter(
                        child: Column(
                      children: [
                        const SettingsForm(),
                        FutureBuilder(
                            future: checkPermissions(),
                            builder: (ctx, snapshot) {
                              return (snapshot.data ?? false)
                                  ? SizedBox.shrink()
                                  : ElevatedButton(
                                      onPressed: () {
                                        requestPermissions();
                                      },
                                      child: const Text(
                                          'Grant Required Permissions'));
                            })
                      ],
                    ))
                  ])),
        ));
  }
}

void showSnackBar(BuildContext ctx, String message) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
