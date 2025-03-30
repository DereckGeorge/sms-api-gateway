class SmsLog {
  final String id;
  final String phoneNumber;
  final String message;
  final DateTime timestamp;
  final String status;

  SmsLog({
    required this.id,
    required this.phoneNumber,
    required this.message,
    required this.timestamp,
    required this.status,
  });
} 