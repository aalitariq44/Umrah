import 'dart:async';
import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../services/emergency_call_service.dart';
import '../services/emergency_contacts_service.dart';

class EmergencyAlertScreen extends StatefulWidget {
  const EmergencyAlertScreen({super.key});

  @override
  State<EmergencyAlertScreen> createState() => _EmergencyAlertScreenState();
}

class _EmergencyAlertScreenState extends State<EmergencyAlertScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late StreamSubscription<int> _countdownSubscription;
  
  int _countdownSeconds = 10;
  bool _isActive = true;
  bool _isCalling = false;
  List<EmergencyContact> _emergencyContacts = [];
  List<EmergencyCallResult> _callResults = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
    _startCountdown();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final contacts = await EmergencyContactsService.getEmergencyContacts();
      setState(() {
        _emergencyContacts = contacts;
      });
      
      if (contacts.isEmpty) {
        _showNoContactsDialog();
      }
    } catch (e) {
      _showErrorDialog('خطأ في تحميل جهات الاتصال: $e');
    }
  }

  void _startCountdown() {
    _countdownSubscription = EmergencyCallService.startEmergencyCountdown().listen(
      (seconds) {
        if (!_isActive) return;
        
        setState(() {
          _countdownSeconds = seconds;
        });
        
        if (seconds == 0) {
          _startEmergencyCalls();
        }
      },
      onError: (error) {
        _showErrorDialog('خطأ في العد التنازلي: $error');
      },
    );
  }

  void _cancelEmergency() {
    setState(() {
      _isActive = false;
    });
    _countdownSubscription.cancel();
    _pulseController.stop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إلغاء الاستغاثة'),
        backgroundColor: Colors.orange,
      ),
    );
    
    Navigator.pop(context);
  }

  Future<void> _startEmergencyCalls() async {
    if (_emergencyContacts.isEmpty) {
      _showNoContactsDialog();
      return;
    }

    setState(() {
      _isCalling = true;
    });

    try {
      final results = await EmergencyCallService.executeEmergencyCalls();
      
      setState(() {
        _callResults = results;
      });
      
      _showCallsCompletedDialog();
    } catch (e) {
      _showErrorDialog('خطأ في تنفيذ المكالمات: $e');
    }
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('لا توجد جهات اتصال'),
        content: const Text('لا توجد جهات اتصال للطوارئ محفوظة. يرجى إضافة جهات اتصال أولاً.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showCallsCompletedDialog() {
    final successfulCalls = _callResults.where((r) => r.success).length;
    final failedCalls = _callResults.length - successfulCalls;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تمت الاستغاثة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تم الاتصال بـ $successfulCalls من ${_callResults.length} جهة اتصال'),
            if (failedCalls > 0) ...[
              const SizedBox(height: 8),
              Text(
                'فشل الاتصال بـ $failedCalls جهة اتصال',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
            const SizedBox(height: 16),
            const Text('تفاصيل المكالمات:'),
            const SizedBox(height: 8),
            ..._callResults.map((result) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    result.success ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: result.success ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.contact.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownSubscription.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة الاستغاثة
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emergency,
                        size: 80,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // العنوان
              const Text(
                'استغاثة طوارئ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              if (!_isCalling) ...[
                // العد التنازلي
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_countdownSeconds',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'سيتم الاتصال بجهات الطوارئ خلال $_countdownSeconds ثانية',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'عدد جهات الاتصال: ${_emergencyContacts.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                // حالة الاتصال
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'جاري الاتصال بجهات الطوارئ...',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 60),
              
              // زر الإلغاء
              if (!_isCalling)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _cancelEmergency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'إلغاء الاستغاثة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
