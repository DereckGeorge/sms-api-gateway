package com.example.telephony_plugin

import android.content.Context
import android.content.Intent
import android.provider.Telephony
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.net.Uri
import android.content.pm.PackageManager

class TelephonyPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "telephony_plugin")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getMessages" -> {
                try {
                    val messages = getAllMessages()
                    result.success(messages)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            "sendMessage" -> {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")
                if (phoneNumber != null && message != null) {
                    val success = sendSMS(phoneNumber, message)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGS", "Phone number or message is null", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getAllMessages(): List<Map<String, Any>> {
        val messages = mutableListOf<Map<String, Any>>()
        val cursor = context.contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            null,
            null,
            null,
            null
        )
        
        cursor?.use {
            while (it.moveToNext()) {
                val message = mapOf(
                    "id" to it.getString(it.getColumnIndexOrThrow(Telephony.Sms._ID)),
                    "address" to it.getString(it.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)),
                    "body" to it.getString(it.getColumnIndexOrThrow(Telephony.Sms.BODY)),
                    "date" to it.getLong(it.getColumnIndexOrThrow(Telephony.Sms.DATE)),
                    "type" to it.getInt(it.getColumnIndexOrThrow(Telephony.Sms.TYPE))
                )
                messages.add(message)
            }
        }
        return messages
    }

    private fun sendSMS(phoneNumber: String, message: String): Boolean {
    // Check for permission first
    if (context.checkSelfPermission(android.Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
        android.util.Log.e("TelephonyPlugin", "Missing SEND_SMS permission")
        return false
    }
    
    return try {
        val smsManager = android.telephony.SmsManager.getDefault()
        
        if (message.length > 160) {
            val messageParts = smsManager.divideMessage(message)
            smsManager.sendMultipartTextMessage(phoneNumber, null, messageParts, null, null)
        } else {
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
        }
        
        true
    } catch (e: Exception) {
        android.util.Log.e("TelephonyPlugin", "Error sending SMS: ${e.message}")
        false
    }
}

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}