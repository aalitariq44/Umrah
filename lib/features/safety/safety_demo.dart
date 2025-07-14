import 'package:flutter/material.dart';
import 'screens/emergency_contacts_list_screen.dart';
import 'screens/edit_emergency_contacts_screen.dart';
import 'screens/emergency_demo_screen.dart';
import 'widgets/emergency_button.dart';

/// مثال على كيفية استخدام شاشات جهات الاتصال الطوارئ ونظام الاستغاثة
/// 
/// يمكن استدعاء هذه الشاشات من أي مكان في التطبيق:
/// 
/// للانتقال إلى شاشة نظام الاستغاثة الكامل:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const EmergencyDemoScreen(),
///   ),
/// );
/// ```
/// 
/// للانتقال إلى شاشة عرض جهات الاتصال:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const EmergencyContactsListScreen(),
///   ),
/// );
/// ```
/// 
/// لإضافة زر الاستغاثة في أي شاشة:
/// ```dart
/// EmergencyButton(
///   size: 80,
///   showLabel: true,
/// )
/// ```

class SafetyFeatureDemo extends StatelessWidget {
  const SafetyFeatureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ميزات الأمان'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // زر الاستغاثة السريع
            Card(
              elevation: 4,
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'استغاثة سريعة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const EmergencyButton(
                      size: 100,
                      showLabel: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط للاستغاثة الفورية',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.emergency,
                  color: Colors.red,
                  size: 32,
                ),
                title: const Text(
                  'نظام الاستغاثة الكامل',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('شاشة الاستغاثة مع العد التنازلي والمكالمات التلقائية'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyDemoScreen(),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 8),
            
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.contact_emergency,
                  color: Colors.blue,
                  size: 32,
                ),
                title: const Text(
                  'جهات الاتصال للطوارئ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('إدارة وعرض جهات الاتصال للطوارئ'),
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
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.add_ic_call,
                  color: Colors.green,
                  size: 32,
                ),
                title: const Text(
                  'إضافة جهات اتصال جديدة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('اختيار جهات اتصال من الهاتف'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditEmergencyContactsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
