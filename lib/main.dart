// main.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony_plugin/telephony_plugin.dart';
import 'services/sms_service.dart';
import 'services/ai_service.dart';
import 'utils/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS AI Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool serviceEnabled = false;
  // Changed from List<LogEntry> to List<String> to match original code
  final List<String> logs = [];
  final SmsService _smsService = SmsService();
  final AiService _aiService = AiService();
  Timer? _pollingTimer;
  
  static const Duration _pollingInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    try {
      final permissionsGranted = await requestPermissions();

      if (permissionsGranted) {
        _smsService.initialize(
          onMessageReceived: _onMessageReceived,
          onError: _logError,
        );
        
        startMessagePolling();
        
        setState(() {
          serviceEnabled = true;
          addLog("SMS polling service started");
        });
      } else {
        setState(() {
          serviceEnabled = false;
          addLog("SMS permissions denied");
        });
      }
    } catch (e) {
      _logError("Initialization error: $e");
    }
  }

  Future<bool> requestPermissions() async {
    var smsStatus = await Permission.sms.request();
    if (!smsStatus.isGranted) {
      addLog("SMS permission is required for this app to function");
    }
    return smsStatus.isGranted;
  }

  void startMessagePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      if (serviceEnabled) {
        checkForNewMessages();
      }
    });
  }

  Future<void> checkForNewMessages() async {
    try {
      await _smsService.checkForNewMessages();
    } catch (e) {
      _logError("Error checking messages: $e");
    }
  }

  void _onMessageReceived(String body, String sender) {
    if (body.toLowerCase().startsWith("hey ai")) {
      addLog("Received AI request from $sender");
      processAiRequest(body, sender);
    }
  }

  Future<void> processAiRequest(String message, String phoneNumber) async {
  final query = message.substring(6).trim(); // Remove "hey ai" prefix

  try {
    final aiService = AiService();
    final aiResponse = await aiService.getAiResponse(query, phoneNumber);

    if (aiResponse != null) {
      // Send the AI response back via SMS
      await TelephonyPlugin.sendMessage(phoneNumber, aiResponse);
      print("AI response sent to $phoneNumber");
    } else {
      print("Failed to get AI response for $phoneNumber");
    }
  } catch (e) {
    print("Error processing AI request: $e");
    
    // Send an error message back to the user
    try {
      await TelephonyPlugin.sendMessage(
        phoneNumber, 
        "Sorry, I couldn't process your request at the moment. Please try again later."
      );
    } catch (_) {
      // Silently fail if error message can't be sent
    }
  }
}

  void addLog(String message) {
    setState(() {
      // Insert at the beginning for reverse chronological order
      logs.insert(0, "${DateTime.now().toString().substring(0, 19)}: $message");
      // Keep log size manageable
      if (logs.length > 100) logs.removeLast();
    });
  }

  void _logError(String message) {
    addLog("ERROR: $message");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS AI Assistant'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildLogHeader(),
            Expanded(
              child: _buildLogList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: serviceEnabled 
            ? () async {
                await checkForNewMessages();
                addLog("Manual message check performed");
              }
            : () async {
                await initPlatformState();
              },
        tooltip: serviceEnabled ? 'Check messages now' : 'Restart service',
        child: Icon(serviceEnabled ? Icons.refresh : Icons.play_arrow),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: serviceEnabled ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Service Status: ${serviceEnabled ? "Running" : "Not Running"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Activity Log:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: logs.isNotEmpty 
            ? () => setState(() => logs.clear())
            : null,
          child: const Text('Clear'),
        ),
      ],
    );
  }

  Widget _buildLogList() {
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          'No activity recorded yet',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            log,
            style: TextStyle(fontSize: 14),
          ),
        );
      },
    );
  }
}

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  LogEntry(this.message, this.level, this.timestamp);
}

enum LogLevel { info, warning, error, success }

class LogEntryWidget extends StatelessWidget {
  final LogEntry entry;

  const LogEntryWidget({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getLogIcon(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: _getLogColor(),
                  ),
                ),
                Text(
                  _formatTimestamp(entry.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLogIcon() {
    IconData iconData;
    Color color;
    
    switch (entry.level) {
      case LogLevel.info:
        iconData = Icons.info_outline;
        color = Colors.blue;
        break;
      case LogLevel.warning:
        iconData = Icons.warning_amber_outlined;
        color = Colors.orange;
        break;
      case LogLevel.error:
        iconData = Icons.error_outline;
        color = Colors.red;
        break;
      case LogLevel.success:
        iconData = Icons.check_circle_outline;
        color = Colors.green;
        break;
    }
    
    return Icon(iconData, size: 18, color: color);
  }

  Color _getLogColor() {
    switch (entry.level) {
      case LogLevel.info:
        return Colors.black87;
      case LogLevel.warning:
        return Colors.orange.shade800;
      case LogLevel.error:
        return Colors.red.shade800;
      case LogLevel.success:
        return Colors.green.shade800;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}";
  }
}