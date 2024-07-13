import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:smstfy/providers/settings_provider.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final TextEditingController ntfyUrlController = TextEditingController();
  final TextEditingController ntfyUsernameController = TextEditingController();
  final TextEditingController ntfyPasswordController = TextEditingController();
  final TextEditingController receiveTopicNameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = context.watch<SettingsProvider>();
    final service = FlutterBackgroundService();
    if (settingsProvider.prefs == null) {
      settingsProvider.initializeSettings();
    }
    ntfyUrlController.text = settingsProvider.ntfyUrl;
    receiveTopicNameController.text = settingsProvider.receiveTopicName;
    final _formKey = GlobalKey<FormState>();

    return Padding(
        padding: const EdgeInsets.all(16),
        child: settingsProvider.prefs == null
            ? const SizedBox()
            : Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: ntfyUrlController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        var url = Uri.tryParse(value ?? '');
                        if (url == null ||
                            !url.isAbsolute ||
                            url.host.isEmpty) {
                          return 'Invalid URL';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ntfy URL',
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: TextFormField(
                          controller: ntfyUsernameController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ntfy username',
                          ),
                        )),
                        const SizedBox(
                          width: 16,
                        ),
                        Flexible(
                            child: TextFormField(
                          controller: ntfyPasswordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ntfy password',
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: receiveTopicNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Enter a ntfy topic name to receive messages on';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ntfy topic name',
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              settingsProvider.ntfyUrl =
                                  ntfyUrlController.value.text;
                              settingsProvider.receiveTopicName =
                                  receiveTopicNameController.value.text;
                              settingsProvider.ntfyUsername =
                                  ntfyUsernameController.value.text;
                              settingsProvider.ntfyPassword =
                                  ntfyPasswordController.value.text;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saved')),
                              );
                            }
                          },
                          child: const Text('Save Settings'),
                        ),
                        FutureBuilder(
                            future: service.isRunning(),
                            builder: (ctx, snapshot) {
                              return TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: HSLColor.fromColor(
                                              (snapshot.data ?? false)
                                                  ? Colors.red
                                                  : Colors.green)
                                          .withLightness(
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? 0.8
                                                  : 0.3)
                                          .toColor()),
                                  onPressed: () async {
                                    (snapshot.data ?? false)
                                        ? service.invoke('stopService')
                                        : await service.startService();
                                    setState(() {});
                                  },
                                  child: Text(
                                      '${(snapshot.data ?? false) ? 'Stop' : 'Start'} SMStfy'));
                            })
                      ],
                    )
                  ],
                ),
              ));
  }
}
