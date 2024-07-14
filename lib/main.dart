import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
    if (!await Permission.sms.isGranted) {
      await Permission.sms.request();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissions();
    });
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
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text('Help'),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SMS gateway powered by ntfy (ntfy.sh).'),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                'When you receive an SMS, SMStfy will send the message data to a ntfy server and topic of your choice.'),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                'By default, the official ntfy server and a random topic name is used.'),
                            Divider(
                              height: 32,
                            ),
                            Text(
                              'Note:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text('The app must remain open to work.'),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                'The app does not keep a message history (this is left to the ntfy server).'),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                'Errors are reported through notifications, are not stored in the app, and may be partly cut off due to length limitations.'),
                            Text(
                                'Enable Android\'s \'Notification History\' feature to ensure you can access past error messages and read them in their entirety.'),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                'Sending SMS from a ntfy topic subscription is currently not supported.')
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Okay'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
              child: Text('?', style: Theme.of(context).textTheme.titleLarge)),
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
