import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey;
  final String backendUrl;

  ApiService({required this.apiKey, required this.backendUrl});

  Future<List<Map<String, dynamic>>> fetchPendingSms() async {
    try {
      final Uri uri = Uri.parse('$backendUrl/pending-sms');
      final response = await http.get(
        uri,
        headers: {
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch SMS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: ${e.toString()}');
    }
  }

  Future<void> updateSmsStatus(String id, bool success, {String? errorMessage}) async {
    try {
      final Uri uri = Uri.parse('$backendUrl/update-sms-status');
      await http.post(
        uri,
        headers: {
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': id,
          'success': success,
          'timestamp': DateTime.now().toIso8601String(),
          'error': errorMessage,
        }),
      );
    } catch (e) {
      print('Failed to update SMS status: ${e.toString()}');
    }
  }
} 