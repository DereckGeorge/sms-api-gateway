import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final String apiKey;
  final String backendUrl;
  final int pollingInterval;
  final Function(String, String, int) onSave;

  const SettingsDialog({
    Key? key,
    required this.apiKey,
    required this.backendUrl,
    required this.pollingInterval,
    required this.onSave,
  }) : super(key: key);

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late String tempApiKey;
  late String tempBackendUrl;
  late int tempPollingInterval;

  @override
  void initState() {
    super.initState();
    tempApiKey = widget.apiKey;
    tempBackendUrl = widget.backendUrl;
    tempPollingInterval = widget.pollingInterval;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Service Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'Enter your secret API key',
            ),
            onChanged: (value) {
              tempApiKey = value;
            },
            controller: TextEditingController(text: widget.apiKey),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Backend URL',
              hintText: 'https://yourdomain.com/sms-api',
            ),
            onChanged: (value) {
              tempBackendUrl = value;
            },
            controller: TextEditingController(text: widget.backendUrl),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Polling Interval (seconds)',
              hintText: 'Enter polling interval',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              tempPollingInterval = int.tryParse(value) ?? 10;
            },
            controller: TextEditingController(text: widget.pollingInterval.toString()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(tempApiKey, tempBackendUrl, tempPollingInterval);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
} 