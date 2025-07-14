import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class CallPermissionManager {
  // طلب أذونات المكالمة الصوتية
  static Future<bool> requestVoiceCallPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.microphone,
    ].request();

    return permissions[Permission.microphone] == PermissionStatus.granted;
  }

  // طلب أذونات المكالمة المرئية
  static Future<bool> requestVideoCallPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return permissions[Permission.camera] == PermissionStatus.granted &&
           permissions[Permission.microphone] == PermissionStatus.granted;
  }

  // التحقق من أذونات المكالمة الصوتية
  static Future<bool> checkVoiceCallPermissions() async {
    final microphoneStatus = await Permission.microphone.status;
    return microphoneStatus == PermissionStatus.granted;
  }

  // التحقق من أذونات المكالمة المرئية
  static Future<bool> checkVideoCallPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    
    return cameraStatus == PermissionStatus.granted &&
           microphoneStatus == PermissionStatus.granted;
  }

  // عرض رسالة عند رفض الأذونات
  static void showPermissionDeniedDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الأذونات مطلوبة'),
        content: Text('يتطلب التطبيق إذن $permissionType لإجراء المكالمات'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('إعدادات'),
          ),
        ],
      ),
    );
  }
}
