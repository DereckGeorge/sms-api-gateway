import 'dart:async';
import 'package:flutter/services.dart';

class TelephonyPlugin {
  static const MethodChannel _channel = MethodChannel('telephony_plugin');
  
  // Get all SMS messages
  static Future<List<Map<String, dynamic>>> getMessages() async {
    try {
      final List<dynamic> messages = await _channel.invokeMethod('getMessages');
      return messages.map((m) => Map<String, dynamic>.from(m)).toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }
  
  // Send SMS
  static Future<bool> sendMessage(String phoneNumber, String message) async {
    try {
      final bool result = await _channel.invokeMethod('sendMessage', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      return result;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  getPlatformVersion() {}
}