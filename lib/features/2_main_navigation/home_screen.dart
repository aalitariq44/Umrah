import 'package:flutter/material.dart';
import 'package:myplace/features/location/screens/location_screen.dart';
import 'package:myplace/features/safety/screens/edit_emergency_contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      _buildHomeScreen(),
      const Text('الرسائل'), // Placeholder for Chat Screen
      const LocationScreen(),
      const Text('الأمان'), // Placeholder for Safety Screen
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'الحساب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'الرسائل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'اللوكيشن',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_outlined),
            activeIcon: Icon(Icons.security),
            label: 'الأمان',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildHomeScreen() {
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
                  Container(
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
