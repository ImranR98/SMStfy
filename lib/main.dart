import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:smstfy/components/custom_app_bar.dart';
import 'package:smstfy/components/settings_form.dart';
import 'package:smstfy/providers/fg_task_provider.dart';
import 'package:smstfy/providers/settings_provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ChangeNotifierProvider(create: (context) => FgTaskProvider()),
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

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
        child: Scaffold(
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
            )));
  }
}

void showSnackBar(BuildContext ctx, String message) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
