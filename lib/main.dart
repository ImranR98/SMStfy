import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:smstfy/components/custom_app_bar.dart';
import 'package:smstfy/components/settings_form.dart';
import 'package:smstfy/providers/settings_provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => SettingsProvider()),
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
      (await Permission.ignoreBatteryOptimizations.isGranted);
  requestPermissions() async {
    if (!await Permission.sms.isGranted) {
      await Permission.sms.request();
    }
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SmsReceiver receiver = new SmsReceiver();
    receiver.onSmsReceived?.listen((SmsMessage msg) {
      print(msg.body); // TODO: Post to Ntfy here and increment the counter.
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
