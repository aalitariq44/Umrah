import 'package:flutter/material.dart';

class AddGroupMembersScreen extends StatefulWidget {
  const AddGroupMembersScreen({super.key});

  @override
  State<AddGroupMembersScreen> createState() => _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends State<AddGroupMembersScreen> {
  final List<bool> _selected = List.generate(4, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة أعضاء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  value: _selected[index],
                  onChanged: (bool? value) {
                    setState(() {
                      _selected[index] = value!;
                    });
                  },
                  secondary: const CircleAvatar(
                      // backgroundImage: ...
                      ),
                  title: Text('ايمان ايمن ${index + 1}'),
                  subtitle: const Text('(+44) 50 9285 3022'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                      // Add selected members
                      Navigator.of(context).pop();
                    },
                    child: const Text('إضافة'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
