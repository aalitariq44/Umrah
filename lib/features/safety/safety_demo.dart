import 'package:flutter/material.dart';
import 'screens/emergency_contacts_list_screen.dart';
import 'screens/edit_emergency_contacts_screen.dart';

/// مثال على كيفية استخدام شاشات جهات الاتصال الطوارئ
/// 
/// يمكن استدعاء هذه الشاشات من أي مكان في التطبيق:
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
/// للانتقال مباشرة إلى شاشة إضافة/تعديل جهات الاتصال:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const EditEmergencyContactsScreen(),
///   ),
/// );
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
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.contact_emergency,
                  color: Colors.red,
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
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.add_ic_call,
                  color: Colors.blue,
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
