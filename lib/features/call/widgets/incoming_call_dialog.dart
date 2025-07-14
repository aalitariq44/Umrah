import 'package:flutter/material.dart';
import 'package:myplace/data/models/user_model.dart' as model;
import 'package:myplace/features/call/services/call_manager.dart';

class IncomingCallDialog extends StatelessWidget {
  final String callId;
  final String callerName;
  final CallType callType;
  final model.User currentUser;
  final model.User callerUser;

  const IncomingCallDialog({
    super.key,
    required this.callId,
    required this.callerName,
    required this.callType,
    required this.currentUser,
    required this.callerUser,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // صورة المتصل
            CircleAvatar(
              radius: 50,
              backgroundImage: callerUser.photoUrl.isNotEmpty
                  ? NetworkImage(callerUser.photoUrl)
                  : null,
              child: callerUser.photoUrl.isEmpty
                  ? Text(
                      callerName.isNotEmpty ? callerName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // اسم المتصل
            Text(
              callerName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // نوع المكالمة
            Text(
              callType == CallType.voice ? 'مكالمة صوتية واردة' : 'مكالمة مرئية واردة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // أزرار قبول ورفض
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // زر الرفض
                InkWell(
                  onTap: () {
                    CallManager.rejectCall(callId);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                // زر القبول
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    CallManager.acceptCall(
                      context: context,
                      callId: callId,
                      currentUser: currentUser,
                      callerUser: callerUser,
                      callType: callType,
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      callType == CallType.voice ? Icons.call : Icons.videocam,
                      color: Colors.white,
                      size: 30,
                    ),
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
