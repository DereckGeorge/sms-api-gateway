import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'apiKey': prefs.getString('apiKey') ?? "",
      'backendUrl': prefs.getString('backendUrl') ?? "",
      'pollingInterval': prefs.getInt('pollingInterval') ?? 10,
    };
  }

  Future<void> saveSettings({
    required String apiKey,
    required String backendUrl,
    required int pollingInterval,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', apiKey);
    await prefs.setString('backendUrl', backendUrl);
    await prefs.setInt('pollingInterval', pollingInterval);
  }
} 