import 'package:flutter/material.dart';
import 'package:myplace/data/models/user_model.dart' as model;

class SimpleCallScreen extends StatefulWidget {
  final String callId;
  final model.User currentUser;
  final model.User targetUser;
  final bool isVideoCall;
  final bool isIncomingCall;

  const SimpleCallScreen({
    super.key,
    required this.callId,
    required this.currentUser,
    required this.targetUser,
    required this.isVideoCall,
    this.isIncomingCall = false,
  });

  @override
  State<SimpleCallScreen> createState() => _SimpleCallScreenState();
}

class _SimpleCallScreenState extends State<SimpleCallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOn = true;
  bool _isCallConnected = false;

  @override
  void initState() {
    super.initState();
    // محاكاة اتصال المكالمة بعد 3 ثوان
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCallConnected = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // شريط علوي مع اسم المستخدم
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        widget.targetUser.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isCallConnected 
                            ? (widget.isVideoCall ? 'مكالمة فيديو جارية' : 'مكالمة صوتية جارية')
                            : 'جاري الاتصال...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 50), // للتوازن
                ],
              ),
            ),

            // منطقة الفيديو أو الصورة الشخصية
            Expanded(
              child: Container(
                width: double.infinity,
                child: widget.isVideoCall && _isCameraOn
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.withOpacity(0.3),
                              Colors.purple.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'فيديو المكالمة\n(محاكاة)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: widget.targetUser.photoUrl.isNotEmpty
                                ? NetworkImage(widget.targetUser.photoUrl)
                                : null,
                            child: widget.targetUser.photoUrl.isEmpty
                                ? Text(
                                    widget.targetUser.name.isNotEmpty 
                                        ? widget.targetUser.name[0].toUpperCase() 
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.targetUser.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // أزرار التحكم
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // زر كتم الصوت
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    isActive: !_isMuted,
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                    },
                  ),

                  // زر السماعة (للمكالمات الصوتية)
                  if (!widget.isVideoCall)
                    _buildControlButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.hearing,
                      isActive: _isSpeakerOn,
                      onPressed: () {
                        setState(() {
                          _isSpeakerOn = !_isSpeakerOn;
                        });
                      },
                    ),

                  // زر الكاميرا (للمكالمات المرئية)
                  if (widget.isVideoCall)
                    _buildControlButton(
                      icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                      isActive: _isCameraOn,
                      onPressed: () {
                        setState(() {
                          _isCameraOn = !_isCameraOn;
                        });
                      },
                    ),

                  // زر تبديل الكاميرا (للمكالمات المرئية)
                  if (widget.isVideoCall)
                    _buildControlButton(
                      icon: Icons.flip_camera_ios,
                      isActive: true,
                      onPressed: () {
                        // محاكاة تبديل الكاميرا
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تبديل الكاميرا')),
                        );
                      },
                    ),

                  // زر إنهاء المكالمة
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.white, size: 35),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onPressed,
      ),
    );
  }
}
