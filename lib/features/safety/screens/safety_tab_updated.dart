import 'package:flutter/material.dart';
import 'package:myplace/features/auth/controller/auth_controller.dart';
import 'package:myplace/features/safety/screens/edit_emergency_contacts_screen.dart';
import 'package:myplace/features/safety/screens/emergency_alert_screen.dart';
import 'package:myplace/features/safety/services/emergency_contacts_service.dart';
import 'package:provider/provider.dart';

class SafetyTab extends StatefulWidget {
  const SafetyTab({super.key});

  @override
  State<SafetyTab> createState() => _SafetyTabState();
}

class _SafetyTabState extends State<SafetyTab> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasEmergencyContacts = false;

  @override
  void initState() {
    super.initState();
    _checkEmergencyContacts();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  Future<void> _checkEmergencyContacts() async {
    try {
      final contacts = await EmergencyContactsService.getEmergencyContacts();
      setState(() {
        _hasEmergencyContacts = contacts.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _hasEmergencyContacts = false;
      });
    }
  }

  void _showEmergencyAlert() {
    if (!_hasEmergencyContacts) {
      _showNoContactsDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmergencyAlertScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) {
      // إعادة فحص جهات الاتصال عند العودة
      _checkEmergencyContacts();
    });
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لا توجد جهات اتصال'),
        content: const Text(
          'لا توجد جهات اتصال للطوارئ محفوظة. يرجى إضافة جهات اتصال للطوارئ أولاً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditEmergencyContactsScreen(),
                ),
              ).then((_) {
                _checkEmergencyContacts();
              });
            },
            child: const Text('إضافة جهات اتصال'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الاستغاثة'),
        content: const Text(
          'هل أنت متأكد من أنك تريد إرسال استغاثة؟ سيتم الاتصال بجهات الطوارئ خلال 10 ثوانٍ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEmergencyAlert();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('نعم، أرسل الاستغاثة'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final user = authController.user;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'أهلاً بعودتك 👋',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          user?.name ?? 'مستخدم جديد',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // زر الاستغاثة المحدث
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: SizedBox(
                        width: 250,
                        height: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _hasEmergencyContacts 
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                boxShadow: [
                                  if (_hasEmergencyContacts)
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _hasEmergencyContacts 
                                  ? _showConfirmationDialog 
                                  : _showNoContactsDialog,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _hasEmergencyContacts 
                                      ? Colors.red 
                                      : Colors.grey,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_hasEmergencyContacts 
                                          ? Colors.red 
                                          : Colors.grey).withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _hasEmergencyContacts 
                                          ? Icons.emergency 
                                          : Icons.warning,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _hasEmergencyContacts 
                                          ? 'زر الاستغاثة' 
                                          : 'لا توجد جهات اتصال',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (!_hasEmergencyContacts) ...[
                                      const SizedBox(height: 5),
                                      const Text(
                                        'اضغط لإضافة جهات اتصال',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(),
                
                // زر تحرير جهات الاتصال
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditEmergencyContactsScreen(),
                      ),
                    ).then((_) {
                      // إعادة فحص جهات الاتصال عند العودة
                      _checkEmergencyContacts();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('تحرير جهات الاتصال للطوارئ'),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
