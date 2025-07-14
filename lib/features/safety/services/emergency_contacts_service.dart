import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

class EmergencyContactsService {
  static const String _keyEmergencyContacts = 'emergency_contacts';
  
  /// حفظ جهات الاتصال الطوارئ
  static Future<void> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = contacts.map((contact) => contact.toJson()).toList();
    await prefs.setString(_keyEmergencyContacts, json.encode(contactsJson));
  }
  
  /// استرجاع جهات الاتصال الطوارئ
  static Future<List<EmergencyContact>> getEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsString = prefs.getString(_keyEmergencyContacts);
    
    if (contactsString == null) {
      return [];
    }
    
    try {
      final contactsJson = json.decode(contactsString) as List;
      return contactsJson
          .map((json) => EmergencyContact.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  /// إضافة جهة اتصال طوارئ جديدة
  static Future<void> addEmergencyContact(EmergencyContact contact) async {
    final contacts = await getEmergencyContacts();
    
    // تجنب الإضافة المكررة
    if (!contacts.any((c) => c.id == contact.id)) {
      contacts.add(contact);
      await saveEmergencyContacts(contacts);
    }
  }
  
  /// إزالة جهة اتصال طوارئ
  static Future<void> removeEmergencyContact(String contactId) async {
    final contacts = await getEmergencyContacts();
    contacts.removeWhere((contact) => contact.id == contactId);
    await saveEmergencyContacts(contacts);
  }
  
  /// مسح جميع جهات الاتصال الطوارئ
  static Future<void> clearAllEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmergencyContacts);
  }
  
  /// التحقق من وجود جهة اتصال في قائمة الطوارئ
  static Future<bool> isEmergencyContact(String contactId) async {
    final contacts = await getEmergencyContacts();
    return contacts.any((contact) => contact.id == contactId);
  }
}
