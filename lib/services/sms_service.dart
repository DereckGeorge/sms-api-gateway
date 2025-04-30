// services/sms_service.dart
import 'package:telephony_plugin/telephony_plugin.dart';

class SmsService {
  // Callback functions
  Function(String body, String sender)? onMessageReceived;
  Function(String error)? onError;
  
  // Track processed messages to avoid duplicates
  final Set<String> _processedMessageIds = {};
  
  // Message filter - messages that start with this will be processed
  static const String _messagePrefix = "hey ai";

  void initialize({
    required Function(String body, String sender) onMessageReceived,
    required Function(String error) onError,
  }) {
    this.onMessageReceived = onMessageReceived;
    this.onError = onError;
  }

  Future<void> checkForNewMessages() async {
    if (onMessageReceived == null) {
      return;
    }
    
    try {
      List<Map<String, dynamic>> messages = await TelephonyPlugin.getMessages();
      
      for (var message in messages) {
        // Skip if we've already processed this message
        String messageId = message['id']?.toString() ?? '';
        if (messageId.isEmpty || _processedMessageIds.contains(messageId)) {
          continue;
        }
        
        // Process message if it starts with our trigger prefix
        String body = message['body']?.toString() ?? '';
        String sender = message['address']?.toString() ?? '';
        
        if (body.isNotEmpty && 
            sender.isNotEmpty && 
            body.toLowerCase().startsWith(_messagePrefix)) {
          onMessageReceived!(body, sender);
        }
        
        // Mark as processed
        _processedMessageIds.add(messageId);
      }
    } catch (e) {
      if (onError != null) {
        onError!("Error checking for messages: $e");
      }
    }
  }

  Future<bool> sendSmsResponse(String phoneNumber, String message) async {
    try {
      bool success = await TelephonyPlugin.sendMessage(phoneNumber, message);
      return success;
    } catch (e) {
      if (onError != null) {
        onError!("Error sending SMS: $e");
      }
      return false;
    }
  }
}