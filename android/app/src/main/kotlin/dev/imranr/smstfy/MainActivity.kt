package dev.imranr.smstfy

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_receiver"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startListening") {
                SmsReceiver.channel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
