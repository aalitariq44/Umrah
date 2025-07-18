import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:myplace/core/config/zego_config.dart';
import 'package:myplace/data/models/user_model.dart' as model;

class VoiceCallScreen extends StatelessWidget {
  final String callId;
  final model.User currentUser;
  final model.User targetUser;
  final bool isIncomingCall;

  const VoiceCallScreen({
    super.key,
    required this.callId,
    required this.currentUser,
    required this.targetUser,
    this.isIncomingCall = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
        callID: callId,
        userID: currentUser.uid,
        userName: currentUser.name.isNotEmpty ? currentUser.name : 'User',
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      ),
    );
  }
}
