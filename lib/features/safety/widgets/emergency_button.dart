import 'package:flutter/material.dart';
import '../screens/emergency_alert_screen.dart';
import '../services/emergency_contacts_service.dart';

class EmergencyButton extends StatefulWidget {
  final double? size;
  final EdgeInsetsGeometry? margin;
  final bool showLabel;
  
  const EmergencyButton({
    super.key,
    this.size,
    this.margin,
    this.showLabel = true,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasEmergencyContacts = false;

  @override
  void initState() {
    super.initState();
    _checkEmergencyContacts();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
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
    );
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لا توجد جهات اتصال'),
        content: const Text(
          'لا توجد جهات اتصال للطوارئ محفوظة. يرجى إضافة جهات اتصال للطوارئ أولاً من إعدادات الأمان.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.size ?? 80.0;
    
    return Container(
      margin: widget.margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: GestureDetector(
                  onTap: _showConfirmationDialog,
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFFF6B6B),
                          Color(0xFFE53E3E),
                          Color(0xFFB91C1C),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: Colors.red.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emergency,
                      color: Colors.white,
                      size: buttonSize * 0.5,
                    ),
                  ),
                ),
              );
            },
          ),
          
          if (widget.showLabel) ...[
            const SizedBox(height: 8),
            Text(
              'استغاثة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _hasEmergencyContacts ? Colors.red[700] : Colors.grey,
              ),
            ),
            if (!_hasEmergencyContacts)
              Text(
                'لا توجد جهات اتصال',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ],
      ),
    );
  }
}
