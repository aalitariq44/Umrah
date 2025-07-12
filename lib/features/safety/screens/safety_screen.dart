import 'package:flutter/material.dart';
import 'package:myplace/features/safety/screens/edit_emergency_contacts_screen.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditEmergencyContactsScreen(),
              ),
            );
          },
          child: const Text('تحرير جهات الاتصال للطوارئ'),
        ),
      ),
    );
  }
}
