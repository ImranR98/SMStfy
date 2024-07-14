// Exposes functions used to save/load app Ntfy

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';

class NtfyProvider with ChangeNotifier {
  sendSMSNotification(SmsMessage msg, String ntfyUrl, String receiveTopicName,
      String ntfyUsername, String ntfyPassword) async {
    var headers = <String, String>{
      'Title': msg.sender ?? 'Unknown Sender',
      'Tags': 'speech_balloon'
    };
    if (ntfyUsername.isNotEmpty && ntfyPassword.isNotEmpty) {
      headers['Authorization'] =
          'Basic ${base64.encode(utf8.encode('$ntfyUsername:$ntfyPassword'))}';
    }
    return http.post(
      Uri.parse('$ntfyUrl/$receiveTopicName'),
      headers: headers,
      body: msg.body,
    );
  }
}
