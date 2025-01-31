// Exposes functions used to save/load app settings

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const alphanumerics =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length,
    (_) => alphanumerics.codeUnitAt(Random().nextInt(alphanumerics.length))));

class SettingsProvider with ChangeNotifier {
  SharedPreferences? prefs;

  // Not done in constructor as we want to be able to await it
  Future<void> initializeSettings() async {
    prefs ??= await SharedPreferences.getInstance();
    notifyListeners();
  }

  String get ntfyUrl {
    return prefs?.getString('ntfyUrl') ?? 'https://ntfy.sh';
  }

  set ntfyUrl(String ntfyUrl) {
    prefs?.setString('ntfyUrl', ntfyUrl);
    notifyListeners();
  }

  String get receiveTopicName {
    var res = prefs?.getString('receiveTopicName');
    if (res == null) {
      res = getRandomString(16);
      prefs?.setString('receiveTopicName', res);
    }
    return res;
  }

  set receiveTopicName(String receiveTopicName) {
    prefs?.setString('receiveTopicName', receiveTopicName);
    notifyListeners();
  }

  String get ntfyAuthData {
    return prefs?.getString('ntfyAuthData') ?? '';
  }

  set ntfyAuthData(String ntfyAuthData) {
    prefs?.setString('ntfyAuthData', ntfyAuthData);
    notifyListeners();
  }
}
