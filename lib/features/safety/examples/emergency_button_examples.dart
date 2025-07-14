import 'package:flutter/material.dart';
import '../widgets/emergency_button.dart';

/// مثال على كيفية إضافة زر الاستغاثة في شاشة رئيسية
/// يمكن دمج هذا الزر في أي شاشة في التطبيق
class MainScreenWithEmergencyButton extends StatelessWidget {
  const MainScreenWithEmergencyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشاشة الرئيسية'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // محتوى الشاشة العادي
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'محتوى الشاشة الرئيسية',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'يمكن وضع أي محتوى هنا',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // منطقة زر الاستغاثة
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    EmergencyButton(
                      size: 70,
                      showLabel: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// مثال آخر - زر الاستغاثة في Floating Action Button
class MainScreenWithFAB extends StatelessWidget {
  const MainScreenWithFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مثال FAB'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'محتوى الشاشة',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: const EmergencyButton(
        size: 60,
        showLabel: false,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// مثال - زر الاستغاثة في الزاوية العلوية
class MainScreenWithTopButton extends StatelessWidget {
  const MainScreenWithTopButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مثال الزاوية العلوية'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: EmergencyButton(
              size: 40,
              showLabel: false,
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'زر الاستغاثة في شريط التطبيق',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
