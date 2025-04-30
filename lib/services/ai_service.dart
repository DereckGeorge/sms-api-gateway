// services/ai_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiService {
  // Updated API configuration
  static const String _apiBaseUrl = 'http://195.179.230.204:5000';
  static const String _apiEndpoint = '/api/ai/chat';
  static const int _timeout = 30; // seconds
  static const String _defaultModel = 'google/gemini-2.5-pro-exp-03-25:free';
  
  /// Sends a request to the AI service and returns the response
  Future<String?> getAiResponse(String query, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_apiEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': query,
          'model': _defaultModel,
          'enable_tools': true,
        }),
      ).timeout(const Duration(seconds: _timeout));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['response'];
      } else {
        throw HttpException(
          "API request failed with status code: ${response.statusCode}",
          response.statusCode
        );
      }
    } catch (e) {
      // Rethrow to be handled by caller
      rethrow;
    }
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  
  HttpException(this.message, this.statusCode);
  
  @override
  String toString() => message;
}