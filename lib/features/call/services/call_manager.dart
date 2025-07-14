import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:myplace/data/models/user_model.dart' as model;
import 'package:myplace/features/call/screens/voice_call_screen.dart';
import 'package:myplace/features/call/screens/video_call_screen.dart';
import 'package:myplace/features/call/services/call_permission_manager.dart';

enum CallType { voice, video }

class CallManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Uuid _uuid = Uuid();

  // بدء مكالمة جديدة
  static Future<void> initiateCall({
    required BuildContext context,
    required model.User targetUser,
    required model.User currentUser,
    required CallType callType,
  }) async {
    try {
      // فحص الأذونات أولاً
      bool hasPermissions = false;
      if (callType == CallType.voice) {
        hasPermissions = await CallPermissionManager.checkVoiceCallPermissions();
        if (!hasPermissions) {
          hasPermissions = await CallPermissionManager.requestVoiceCallPermissions();
        }
        if (!hasPermissions) {
          CallPermissionManager.showPermissionDeniedDialog(context, 'الميكروفون');
          return;
        }
      } else {
        hasPermissions = await CallPermissionManager.checkVideoCallPermissions();
        if (!hasPermissions) {
          hasPermissions = await CallPermissionManager.requestVideoCallPermissions();
        }
        if (!hasPermissions) {
          CallPermissionManager.showPermissionDeniedDialog(context, 'الكاميرا والميكروفون');
          return;
        }
      }

      // إنشاء معرف فريد للمكالمة
      final callId = _uuid.v4();
      
      // حفظ معلومات المكالمة في Firebase
      await _firestore.collection('calls').doc(callId).set({
        'callId': callId,
        'callerId': currentUser.uid,
        'callerName': currentUser.name,
        'targetId': targetUser.uid,
        'targetName': targetUser.name,
        'type': callType.name,
        'status': 'calling',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // إرسال إشعار المكالمة
      await _sendCallNotification(
        callId: callId,
        targetUserId: targetUser.uid,
        callerName: currentUser.name,
        callType: callType,
      );

      // الانتقال إلى شاشة المكالمة
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => callType == CallType.voice
                ? VoiceCallScreen(
                    callId: callId,
                    currentUser: currentUser,
                    targetUser: targetUser,
                  )
                : VideoCallScreen(
                    callId: callId,
                    currentUser: currentUser,
                    targetUser: targetUser,
                  ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initiating call: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في بدء المكالمة')),
        );
      }
    }
  }

  // إرسال إشعار المكالمة
  static Future<void> _sendCallNotification({
    required String callId,
    required String targetUserId,
    required String callerName,
    required CallType callType,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('call_notifications')
          .doc(callId)
          .set({
        'callId': callId,
        'callerName': callerName,
        'callType': callType.name,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'incoming',
      });
    } catch (e) {
      debugPrint('Error sending call notification: $e');
    }
  }

  // قبول المكالمة
  static Future<void> acceptCall({
    required BuildContext context,
    required String callId,
    required model.User currentUser,
    required model.User callerUser,
    required CallType callType,
  }) async {
    try {
      // تحديث حالة المكالمة
      await _firestore.collection('calls').doc(callId).update({
        'status': 'accepted',
      });

      // الانتقال إلى شاشة المكالمة
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => callType == CallType.voice
                ? VoiceCallScreen(
                    callId: callId,
                    currentUser: currentUser,
                    targetUser: callerUser,
                    isIncomingCall: true,
                  )
                : VideoCallScreen(
                    callId: callId,
                    currentUser: currentUser,
                    targetUser: callerUser,
                    isIncomingCall: true,
                  ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error accepting call: $e');
    }
  }

  // رفض المكالمة
  static Future<void> rejectCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'rejected',
      });
    } catch (e) {
      debugPrint('Error rejecting call: $e');
    }
  }

  // إنهاء المكالمة
  static Future<void> endCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'ended',
        'endTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error ending call: $e');
    }
  }

  // الاستماع لإشعارات المكالمات الواردة
  static Stream<QuerySnapshot> getIncomingCalls(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('call_notifications')
        .where('status', isEqualTo: 'incoming')
        .snapshots();
  }
}
