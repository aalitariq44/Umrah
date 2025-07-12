import 'package:flutter/material.dart';
import 'package:myplace/features/chat/screens/add_group_members_screen.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء مجموعة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مجموعة الاسم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'أدخل اسم المجموعة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'الأعضاء',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddGroupMembersScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('أضف أعضاء إلى المجموعة'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.orange[100],
                foregroundColor: Colors.black,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Action to create group
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('إنشاء المجموعة'),
            ),
          ],
        ),
      ),
    );
  }
}
