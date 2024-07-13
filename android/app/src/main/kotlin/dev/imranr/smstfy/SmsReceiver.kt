package dev.imranr.smstfy

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.SmsMessage
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class SmsReceiver : BroadcastReceiver() {
    companion object {
        var channel: MethodChannel? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle = intent.extras
            if (bundle != null) {
                val pdus = bundle["pdus"] as Array<*>
                val messages = pdus.map { pdu ->
                    SmsMessage.createFromPdu(pdu as ByteArray)
                }
                val smsBody = messages.joinToString(separator = "") { it.messageBody }
                val sender = messages[0].originatingAddress
                val timestampMillis = messages[0].timestampMillis

                Log.d("SmsReceiver", "Received SMS from: $sender, Message: $smsBody, Timestamp: $timestampMillis")

                // Create an object with all the message info
                val messageInfo = mapOf(
                    "sender" to sender,
                    "body" to smsBody,
                    "timestamp" to timestampMillis
                )

                // Send the SMS data to the Flutter side
                channel?.invokeMethod("onSmsReceived", messageInfo)
            }
        }
    }
}