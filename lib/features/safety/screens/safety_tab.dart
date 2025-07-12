import 'package:flutter/material.dart';
import 'package:myplace/features/safety/screens/edit_emergency_contacts_screen.dart';
import 'package:myplace/features/safety/screens/sos_dialog.dart';

class SafetyTab extends StatelessWidget {
  const SafetyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً بعودتك 👋',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Text(
                      'أحمد ابراهيم',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 30,
                  // backgroundImage: AssetImage('assets/profile.png'), // Add your profile image here
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
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
                      color: Colors.red.withOpacity(0.2),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const SOSTimerDialog();
                        },
                      );
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.crisis_alert,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'زر الاستغاثة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditEmergencyContactsScreen(),
                  ),
                );
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
  }
}
