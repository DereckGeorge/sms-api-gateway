import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sms_log.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/sms_service.dart';
import '../services/storage_service.dart';
import '../widgets/error_dialog.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/sms_log_item.dart';
import '../widgets/status_card.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // Services
  final SmsService _smsService = SmsService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final StorageService _storageService = StorageService();
  late ApiService _apiService;

  // State variables
  bool _isRunning = false;
  String _status = "Service stopped";
  String _apiKey = "";
  String _backendUrl = "";
  int _pollingInterval = 10; // seconds
  Timer? _timer;
  List<SmsLog> _smsLogs = [];
  bool _isConnected = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _checkPermission();
    await _loadSettings();
    await _checkConnectivity();
    
    // Listen for connectivity changes
    _connectivityService.onConnectivityChanged.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
      
      if (_isConnected && _isRunning) {
        _startPolling();
      } else if (!_isConnected && _timer != null) {
        _timer?.cancel();
        setState(() {
          _status = "Waiting for network connection...";
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground
      if (_isRunning && _isConnected && _timer == null) {
        _startPolling();
      }
    } else if (state == AppLifecycleState.paused) {
      // App went to background
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _checkConnectivity() async {
    _isConnected = await _connectivityService.checkConnectivity();
    setState(() {});
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.loadSettings();
    setState(() {
      _apiKey = settings['apiKey'];
      _backendUrl = settings['backendUrl'];
      _pollingInterval = settings['pollingInterval'];
    });
    
    // Initialize API service with loaded settings
    _apiService = ApiService(apiKey: _apiKey, backendUrl: _backendUrl);
  }

  Future<void> _saveSettings(String apiKey, String backendUrl, int pollingInterval) async {
    await _storageService.saveSettings(
      apiKey: apiKey, 
      backendUrl: backendUrl, 
      pollingInterval: pollingInterval
    );
    
    setState(() {
      _apiKey = apiKey;
      _backendUrl = backendUrl;
      _pollingInterval = pollingInterval;
    });
    
    // Update API service with new settings
    _apiService = ApiService(apiKey: _apiKey, backendUrl: _backendUrl);
    
    // Restart polling if running
    if (_isRunning) {
      _stopPolling();
      _startPolling();
    }
  }

  Future<void> _checkPermission() async {
    final bool permissionsGranted = await _smsService.checkPermission();
    if (!permissionsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SMS permissions are required to send messages'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startPolling() {
    if (_apiKey.isEmpty || _backendUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please set API key and Backend URL in settings'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cancel any existing timer
    _timer?.cancel();
    
    // Start new timer
    _timer = Timer.periodic(Duration(seconds: _pollingInterval), (timer) {
      _fetchPendingSms();
    });
    
    setState(() {
      _isRunning = true;
      _status = "Service running - polling every $_pollingInterval seconds";
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SMS gateway service started'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Immediately fetch messages
    _fetchPendingSms();
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
    
    setState(() {
      _isRunning = false;
      _status = "Service stopped";
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SMS gateway service stopped'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _fetchPendingSms() async {
    if (!_isConnected) {
      setState(() {
        _status = "Waiting for network connection...";
      });
      return;
    }
    
    setState(() {
      _status = "Checking for pending SMS messages...";
    });
    
    try {
      final pendingSms = await _apiService.fetchPendingSms();
      
      if (pendingSms.isEmpty) {
        setState(() {
          _status = "No pending messages found. Next check in $_pollingInterval seconds.";
        });
        return;
      }
      
      setState(() {
        _status = "Processing ${pendingSms.length} message(s)...";
      });
      
      int successCount = 0;
      for (var smsData in pendingSms) {
        final String id = smsData['id'].toString();
        final String phoneNumber = smsData['phone_number'];
        final String message = smsData['message'];
        
        bool success = await _processSms(id, phoneNumber, message);
        if (success) successCount++;
      }
      
      setState(() {
        _status = "Processed ${pendingSms.length} message(s), $successCount sent successfully. Next check in $_pollingInterval seconds.";
      });
    } catch (e) {
      setState(() {
        _status = "Error fetching messages: ${e.toString()}";
      });
    }
  }

  Future<bool> _processSms(String id, String phoneNumber, String message) async {
    try {
      bool success = await _smsService.sendSms(id, phoneNumber, message);
      
      // Create a log entry
      final SmsLog log = SmsLog(
        id: id,
        phoneNumber: phoneNumber,
        message: message,
        timestamp: DateTime.now(),
        status: success ? 'Sent' : 'Failed',
      );
      
      setState(() {
        _smsLogs.add(log);
      });
      
      // Report back to the server
      await _apiService.updateSmsStatus(id, success);
      
      return success;
    } catch (e) {
      // Log the error
      final SmsLog log = SmsLog(
        id: id,
        phoneNumber: phoneNumber,
        message: message,
        timestamp: DateTime.now(),
        status: 'Error: ${e.toString()}',
      );
      
      setState(() {
        _smsLogs.add(log);
      });
      
      // Report back to the server
      await _apiService.updateSmsStatus(id, false, errorMessage: e.toString());
      
      return false;
    }
  }

  void _showErrorDetails(SmsLog log) {
    showDialog(
      context: context,
      builder: (context) {
        return ErrorDialog(
          log: log,
          onRetry: () {
            _processSms(log.id, log.phoneNumber, log.message);
          },
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SettingsDialog(
          apiKey: _apiKey,
          backendUrl: _backendUrl,
          pollingInterval: _pollingInterval,
          onSave: _saveSettings,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StatusCard(
              status: _status,
              isConnected: _isConnected,
              isRunning: _isRunning,
              apiKey: _apiKey,
              backendUrl: _backendUrl,
              onStartService: _startPolling,
              onStopService: _stopPolling,
            ),
            SizedBox(height: 16),
            Text(
              'SMS Log:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _smsLogs.isEmpty
                ? Center(child: Text('No SMS messages sent yet'))
                : ListView.builder(
                    itemCount: _smsLogs.length,
                    itemBuilder: (context, index) {
                      final log = _smsLogs[_smsLogs.length - 1 - index];
                      return SmsLogItem(
                        log: log,
                        onTap: _showErrorDetails,
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 