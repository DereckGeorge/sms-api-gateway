import 'package:telephony/telephony.dart';
import '../models/sms_log.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;

  Future<bool> checkPermission() async {
    final bool? permissionsGranted = await telephony.requestSmsPermissions;
    return permissionsGranted == true;
  }

  Future<bool> sendSms(String id, String phoneNumber, String message) async {
    try {
      await telephony.sendSms(
        to: phoneNumber,
        message: message,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }
} 