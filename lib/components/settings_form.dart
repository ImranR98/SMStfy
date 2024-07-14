import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:smstfy/providers/ntfy_provider.dart';
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
  bool formEnabled = false;

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = context.watch<SettingsProvider>();
    NtfyProvider ntfyProvider = context.watch<NtfyProvider>();
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
                  mainAxisSize: MainAxisSize.min,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        TextButton(
                          onPressed: () async {
                            try {
                              await ntfyProvider.sendSMSNotification(
                                  SmsMessage('SMStfy', 'Test message'),
                                  settingsProvider.ntfyUrl,
                                  settingsProvider.receiveTopicName,
                                  settingsProvider.ntfyUsername,
                                  settingsProvider.ntfyPassword);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Test Successful')),
                              );
                            } catch (e) {
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: Text(e.toString()),
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
                            }
                          },
                          child: Text(
                            'Test',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ));
  }
}
