import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myplace/features/call/services/call_manager.dart';
import 'package:myplace/features/call/widgets/incoming_call_dialog.dart';
import 'package:myplace/data/models/user_model.dart' as model;

class CallNotificationHandler extends StatefulWidget {
  final Widget child;

  const CallNotificationHandler({super.key, required this.child});

  @override
  State<CallNotificationHandler> createState() => _CallNotificationHandlerState();
}

class _CallNotificationHandlerState extends State<CallNotificationHandler> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _listenForIncomingCalls();
  }

  void _listenForIncomingCalls() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      CallManager.getIncomingCalls(currentUser.uid).listen((snapshot) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          _showIncomingCallDialog(data);
          
          // حذف الإشعار بعد عرضه
          doc.reference.delete();
        }
      });
    }
  }

  void _showIncomingCallDialog(Map<String, dynamic> callData) async {
    // الحصول على معلومات المتصل
    final callerDoc = await _firestore
        .collection('calls')
        .doc(callData['callId'])
        .get();
    
    if (callerDoc.exists) {
      final callInfo = callerDoc.data() as Map<String, dynamic>;
      final callerUserDoc = await _firestore
          .collection('users')
          .doc(callInfo['callerId'])
          .get();
      
      if (callerUserDoc.exists && mounted) {
        final callerUser = model.User.fromSnap(callerUserDoc);
        final currentUser = model.User(
          uid: _auth.currentUser!.uid,
          email: _auth.currentUser!.email ?? '',
          name: _auth.currentUser!.displayName ?? 'أنا',
          phone: '',
        );
        
        final callType = callData['callType'] == 'voice' 
            ? CallType.voice 
            : CallType.video;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => IncomingCallDialog(
            callId: callData['callId'],
            callerName: callData['callerName'],
            callType: callType,
            currentUser: currentUser,
            callerUser: callerUser,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
