import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../services/emergency_contacts_service.dart';
import 'edit_emergency_contacts_screen.dart';

class EmergencyContactsListScreen extends StatefulWidget {
  const EmergencyContactsListScreen({super.key});

  @override
  State<EmergencyContactsListScreen> createState() => _EmergencyContactsListScreenState();
}

class _EmergencyContactsListScreenState extends State<EmergencyContactsListScreen> {
  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final contacts = await EmergencyContactsService.getEmergencyContacts();
      setState(() {
        _emergencyContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeContact(EmergencyContact contact) async {
    try {
      await EmergencyContactsService.removeEmergencyContact(contact.id);
      await _loadEmergencyContacts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف ${contact.name} من جهات الاتصال الطوارئ'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف جهة الاتصال: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRemoveDialog(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف ${contact.name} من جهات الاتصال الطوارئ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeContact(contact);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جهات الاتصال للطوارئ'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditEmergencyContactsScreen(),
                ),
              );
              
              if (result != null) {
                await _loadEmergencyContacts();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _emergencyContacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contact_emergency_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد جهات اتصال للطوارئ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اضغط على + لإضافة جهات اتصال',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditEmergencyContactsScreen(),
                            ),
                          );
                          
                          if (result != null) {
                            await _loadEmergencyContacts();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة جهات اتصال'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue[50],
                      child: Text(
                        'لديك ${_emergencyContacts.length} جهة اتصال للطوارئ',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _emergencyContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _emergencyContacts[index];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                contact.name,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                contact.phoneNumber,
                                textDirection: TextDirection.ltr,
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.phone, size: 18),
                                        SizedBox(width: 8),
                                        Text('اتصال'),
                                      ],
                                    ),
                                    onTap: () {
                                      // يمكن إضافة وظيفة الاتصال هنا
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('حذف', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                    onTap: () {
                                      Future.delayed(const Duration(milliseconds: 100), () {
                                        _showRemoveDialog(contact);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _emergencyContacts.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditEmergencyContactsScreen(),
                  ),
                );
                
                if (result != null) {
                  await _loadEmergencyContacts();
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
