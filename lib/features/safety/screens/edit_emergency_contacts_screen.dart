import 'package:flutter/material.dart';

class EditEmergencyContactsScreen extends StatelessWidget {
  const EditEmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جهات الاتصال للطوارئ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              // Navigate back or to another screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'البحث',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 4, // Example count
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      // backgroundImage: NetworkImage('...'), // Add image later
                    ),
                    title: Text('ايمان ايمن ${index + 1}'),
                    subtitle: const Text('(+44) 50 9285 3022'),
                    trailing: Checkbox(
                      value: false,
                      onChanged: (bool? value) {
                        // Handle checkbox state change
                      },
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle cancel
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle add
                    },
                    child: const Text('إضافة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
