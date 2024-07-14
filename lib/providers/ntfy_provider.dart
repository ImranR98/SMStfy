// Exposes functions used to save/load app Ntfy

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';

class NtfyProvider with ChangeNotifier {
  Future<http.Response> sendSMSNotification(SmsMessage msg, String ntfyUrl,
      String receiveTopicName, String ntfyAuthData) async {
    var headers = <String, String>{
      'Title': msg.sender ?? 'Unknown Sender',
      'Tags': 'speech_balloon'
    };
    if (ntfyAuthData.isNotEmpty) {
      bool isToken = ntfyAuthData.startsWith('tk_');
      headers['Authorization'] =
          '${(isToken ? 'Bearer' : 'Basic')} ${isToken ? ntfyAuthData : base64.encode(utf8.encode(ntfyAuthData))}';
    }
    return http.post(
      Uri.parse('$ntfyUrl/$receiveTopicName'),
      headers: headers,
      body: msg.body,
    );
  }
}
