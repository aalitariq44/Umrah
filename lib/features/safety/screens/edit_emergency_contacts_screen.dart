import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/emergency_contact.dart';
import '../services/emergency_contacts_service.dart';

class EditEmergencyContactsScreen extends StatefulWidget {
  const EditEmergencyContactsScreen({super.key});

  @override
  State<EditEmergencyContactsScreen> createState() => _EditEmergencyContactsScreenState();
}

class _EditEmergencyContactsScreenState extends State<EditEmergencyContactsScreen> {
  List<Contact> _selectedContacts = [];
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      // طلب إذن الوصول لجهات الاتصال
      if (await Permission.contacts.request().isGranted) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
        
        // تحميل جهات الاتصال المحفوظة مسبقاً
        final savedEmergencyContacts = await EmergencyContactsService.getEmergencyContacts();
        final savedContactIds = savedEmergencyContacts.map((c) => c.id).toSet();
        
        setState(() {
          _allContacts = contacts.where((contact) => 
            contact.phones.isNotEmpty && 
            contact.displayName.isNotEmpty
          ).toList();
          _filteredContacts = _allContacts;
          
          // تحديد جهات الاتصال المحفوظة مسبقاً
          _selectedContacts = _allContacts.where((contact) => 
            savedContactIds.contains(contact.id)
          ).toList();
          
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showPermissionDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('خطأ في تحميل جهات الاتصال: $e');
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        return contact.displayName.toLowerCase().contains(query) ||
               contact.phones.any((phone) => phone.number.contains(query));
      }).toList();
    });
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (_selectedContacts.any((c) => c.id == contact.id)) {
        _selectedContacts.removeWhere((c) => c.id == contact.id);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  bool _isContactSelected(Contact contact) {
    return _selectedContacts.any((c) => c.id == contact.id);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إذن مطلوب'),
        content: const Text('نحتاج إلى إذن للوصول إلى جهات الاتصال لتتمكن من اختيار جهات الاتصال للطوارئ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('الإعدادات'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEmergencyContacts() async {
    if (_selectedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار جهة اتصال واحدة على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // تحويل جهات الاتصال المختارة إلى نموذج EmergencyContact
      final emergencyContacts = _selectedContacts.map((contact) {
        final primaryPhone = contact.phones.isNotEmpty 
            ? contact.phones.first.number 
            : '';
        
        return EmergencyContact(
          id: contact.id,
          name: contact.displayName,
          phoneNumber: primaryPhone,
          photoPath: null, // يمكن حفظ الصورة لاحقاً إذا لزم الأمر
        );
      }).toList();
      
      // حفظ جهات الاتصال
      await EmergencyContactsService.saveEmergencyContacts(emergencyContacts);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ ${_selectedContacts.length} جهة اتصال للطوارئ'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, emergencyContacts);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('خطأ في حفظ جهات الاتصال: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جهات الاتصال للطوارئ'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedContacts.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedContacts.length}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل جهات الاتصال...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // شريط البحث
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'البحث في جهات الاتصال',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // عرض عدد جهات الاتصال المختارة
                  if (_selectedContacts.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        'تم اختيار ${_selectedContacts.length} جهة اتصال للطوارئ',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  if (_selectedContacts.isNotEmpty) const SizedBox(height: 16),
                  
                  // قائمة جهات الاتصال
                  Expanded(
                    child: _filteredContacts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.contacts_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _allContacts.isEmpty
                                      ? 'لا توجد جهات اتصال متاحة'
                                      : 'لم يتم العثور على جهات اتصال',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_allContacts.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _loadContacts,
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = _filteredContacts[index];
                              final isSelected = _isContactSelected(contact);
                              final primaryPhone = contact.phones.isNotEmpty 
                                  ? contact.phones.first.number 
                                  : '';
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected 
                                        ? Theme.of(context).primaryColor 
                                        : Colors.grey[300],
                                    backgroundImage: contact.photo != null 
                                        ? MemoryImage(contact.photo!) 
                                        : null,
                                    child: contact.photo == null
                                        ? Icon(
                                            Icons.person,
                                            color: isSelected ? Colors.white : Colors.grey[600],
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    contact.displayName,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    primaryPhone,
                                    textDirection: TextDirection.ltr,
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      _toggleContactSelection(contact);
                                    },
                                    activeColor: Theme.of(context).primaryColor,
                                  ),
                                  onTap: () {
                                    _toggleContactSelection(contact);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  
                  // الأزرار السفلية
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedContacts.isNotEmpty 
                              ? _saveEmergencyContacts 
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'حفظ جهات الاتصال',
                            style: TextStyle(fontSize: 16),
                          ),
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
