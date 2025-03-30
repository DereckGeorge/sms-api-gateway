import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String status;
  final bool isConnected;
  final bool isRunning;
  final String apiKey;
  final String backendUrl;
  final VoidCallback onStartService;
  final VoidCallback onStopService;

  const StatusCard({
    Key? key,
    required this.status,
    required this.isConnected,
    required this.isRunning,
    required this.apiKey,
    required this.backendUrl,
    required this.onStartService,
    required this.onStopService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Service Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(status),
            SizedBox(height: 8),
            Text('API Key: ${apiKey.isNotEmpty ? "Configured" : "Not Set"}'),
            Text('Backend URL: ${backendUrl.isNotEmpty ? backendUrl : "Not Set"}'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: (isRunning || !isConnected) ? null : onStartService,
                  child: Text('Start Service'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: isRunning ? onStopService : null,
                  child: Text('Stop Service'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 