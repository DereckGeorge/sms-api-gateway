import 'package:flutter/material.dart';
import '../models/sms_log.dart';
import '../utils/date_formatter.dart';

class SmsLogItem extends StatelessWidget {
  final SmsLog log;
  final Function(SmsLog) onTap;

  const SmsLogItem({
    Key? key,
    required this.log,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(log.phoneNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.message.length > 50 
                ? '${log.message.substring(0, 50)}...' 
                : log.message
            ),
            Text('ID: ${log.id}', style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              log.status.startsWith('Error') 
                ? 'Error' 
                : log.status,
              style: TextStyle(
                color: log.status == 'Sent'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            Text(
              DateFormatter.formatDateTime(log.timestamp),
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          if (log.status.startsWith('Error')) {
            onTap(log);
          }
        },
      ),
    );
  }
} 