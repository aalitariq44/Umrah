import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';
import 'emergency_contacts_service.dart';

class EmergencyCallService {
  static const int _countdownDuration = 10; // ثوانٍ
  static const int _delayBetweenCalls = 5; // ثوانٍ بين المكالمات
  
  /// بدء عملية الاستغاثة مع العد التنازلي
  static Stream<int> startEmergencyCountdown() async* {
    for (int i = _countdownDuration; i > 0; i--) {
      yield i;
      await Future.delayed(const Duration(seconds: 1));
    }
    yield 0;
  }
  
  /// تنفيذ المكالمات الطارئة
  static Future<List<EmergencyCallResult>> executeEmergencyCalls() async {
    final contacts = await EmergencyContactsService.getEmergencyContacts();
    final results = <EmergencyCallResult>[];
    
    if (contacts.isEmpty) {
      throw EmergencyException('لا توجد جهات اتصال للطوارئ محفوظة');
    }
    
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      final result = await _makeEmergencyCall(contact, i + 1);
      results.add(result);
      
      // انتظار بين المكالمات (باستثناء المكالمة الأخيرة)
      if (i < contacts.length - 1) {
        await Future.delayed(const Duration(seconds: _delayBetweenCalls));
      }
    }
    
    return results;
  }
  
  /// تنفيذ مكالمة واحدة
  static Future<EmergencyCallResult> _makeEmergencyCall(
    EmergencyContact contact, 
    int callNumber
  ) async {
    try {
      final phoneNumber = _cleanPhoneNumber(contact.phoneNumber);
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return EmergencyCallResult(
          contact: contact,
          callNumber: callNumber,
          success: true,
          timestamp: DateTime.now(),
        );
      } else {
        throw 'لا يمكن فتح تطبيق الهاتف';
      }
    } catch (e) {
      return EmergencyCallResult(
        contact: contact,
        callNumber: callNumber,
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// تنظيف رقم الهاتف (إزالة الرموز والمسافات)
  static String _cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }
  
  /// إرسال رسالة نصية طارئة (اختياري)
  static Future<bool> sendEmergencySMS(
    EmergencyContact contact, 
    String message
  ) async {
    try {
      final phoneNumber = _cleanPhoneNumber(contact.phoneNumber);
      final uri = Uri(
        scheme: 'sms', 
        path: phoneNumber,
        queryParameters: {'body': message},
      );
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// الحصول على رسالة استغاثة افتراضية
  static String getDefaultEmergencyMessage() {
    final now = DateTime.now();
    return 'استغاثة طوارئ! أحتاج المساعدة الفورية. '
           'الوقت: ${now.hour}:${now.minute.toString().padLeft(2, '0')} '
           'التاريخ: ${now.day}/${now.month}/${now.year}';
  }
}

/// نتيجة مكالمة الاستغاثة
class EmergencyCallResult {
  final EmergencyContact contact;
  final int callNumber;
  final bool success;
  final String? error;
  final DateTime timestamp;
  
  EmergencyCallResult({
    required this.contact,
    required this.callNumber,
    required this.success,
    this.error,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return success 
        ? 'مكالمة ${callNumber}: تم الاتصال بـ ${contact.name}'
        : 'مكالمة ${callNumber}: فشل الاتصال بـ ${contact.name} - $error';
  }
}

/// استثناء خاص بعمليات الاستغاثة
class EmergencyException implements Exception {
  final String message;
  
  EmergencyException(this.message);
  
  @override
  String toString() => 'EmergencyException: $message';
}
