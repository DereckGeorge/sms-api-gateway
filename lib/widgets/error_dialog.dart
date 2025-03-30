import 'package:flutter/material.dart';
import '../models/sms_log.dart';
import '../utils/date_formatter.dart';

class ErrorDialog extends StatelessWidget {
  final SmsLog log;
  final VoidCallback onRetry;

  const ErrorDialog({
    Key? key,
    required this.log,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Error Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: ${log.id}'),
            SizedBox(height: 8),
            Text('Phone: ${log.phoneNumber}'),
            SizedBox(height: 8),
            Text('Time: ${DateFormatter.formatDateTime(log.timestamp)}'),
            SizedBox(height: 8),
            Text('Error:'),
            SizedBox(height: 4),
            Text(log.status),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
          child: Text('Retry'),
        ),
      ],
    );
  }
} 