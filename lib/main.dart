import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:smstfy/components/custom_app_bar.dart';
import 'package:smstfy/components/settings_form.dart';
import 'package:smstfy/providers/settings_provider.dart';
import 'package:smstfy/providers/sms_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeService();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => SettingsProvider()),
    ],
    child: const SMStfy(),
  ));
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'smstfy_foreground',
    'SMStfy Foreground Service',
    description:
        'This notification appears when the SMStfy foreground service is running.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_bg_service_small'),
    ),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'smstfy_foreground',
      initialNotificationTitle: 'Foreground Service',
      initialNotificationContent: 'SMStfy is running.',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  SettingsProvider settingsProvider = SettingsProvider();
  await settingsProvider.initializeSettings();

  SmsReceiver.startListening((message) {
    print(message);
  });
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
                  slivers: const <Widget>[
                    CustomAppBar(title: 'SMStfy'),
                    SliverToBoxAdapter(child: SettingsForm())
                  ])),
        ));
  }
}

void showSnackBar(BuildContext ctx, String message) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
