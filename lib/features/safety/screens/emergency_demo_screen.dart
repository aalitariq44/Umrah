import 'package:flutter/material.dart';
import '../widgets/emergency_button.dart';
import '../screens/emergency_contacts_list_screen.dart';

class EmergencyDemoScreen extends StatelessWidget {
  const EmergencyDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام الاستغاثة'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyContactsListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شرح النظام
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'نظام الاستغاثة السريع',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'عند الضغط على زر الاستغاثة:\n'
                      '• سيبدأ عد تنازلي لمدة 10 ثوانٍ\n'
                      '• يمكنك إلغاء الاستغاثة خلال هذا الوقت\n'
                      '• بعد انتهاء الوقت سيتم الاتصال تلقائياً\n'
                      '• سيتم الاتصال بجميع جهات الطوارئ المحفوظة\n'
                      '• فاصل زمني 5 ثوانٍ بين كل مكالمة',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // زر الاستغاثة الرئيسي
            const EmergencyButton(
              size: 120,
              showLabel: true,
            ),
            
            const SizedBox(height: 40),
            
            // إعدادات سريعة
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.contacts, color: Colors.blue),
                    title: const Text('إدارة جهات الطوارئ'),
                    subtitle: const Text('إضافة أو تعديل جهات الاتصال'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmergencyContactsListScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.play_circle_outline, color: Colors.orange),
                    title: const Text('اختبار النظام'),
                    subtitle: const Text('اختبار الاستغاثة (بدون اتصال فعلي)'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showTestDialog(context);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // تحذير مهم
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تحذير: استخدم هذا النظام في حالات الطوارئ الحقيقية فقط',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
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

  void _showTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختبار النظام'),
        content: const Text(
          'هذه الميزة قيد التطوير. حالياً يمكنك اختبار النظام الحقيقي بالضغط على زر الاستغاثة أعلاه.\n\n'
          'تأكد من إضافة جهات اتصال للطوارئ أولاً.',
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
}
