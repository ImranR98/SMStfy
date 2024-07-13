import 'package:flutter/services.dart';

class SMSProvider {
  static const MethodChannel _channel = MethodChannel('sms_receiver');

  static void startListening(Function(Map<String, dynamic>) onSmsReceived) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceived') {
        onSmsReceived(Map<String, dynamic>.from(call.arguments));
      }
    });
  }
}
