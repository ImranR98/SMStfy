import 'package:flutter/services.dart';

class SmsReceiver {
  static const MethodChannel _channel = MethodChannel('sms_receiver');

  static void startListening(Function(String) onSmsReceived) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceived') {
        onSmsReceived(call.arguments);
      }
    });
    _channel.invokeMethod('startListening');
  }
}
