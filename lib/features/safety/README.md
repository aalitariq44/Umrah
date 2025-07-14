# ميزة جهات الاتصال للطوارئ

## الوصف
تتيح هذه الميزة للمستخدمين إدارة جهات الاتصال للطوارئ بشكل فعال من خلال:
- اختيار جهات الاتصال من دفتر العناوين الحقيقي في الهاتف
- حفظ جهات الاتصال المختارة محلياً
- عرض وإدارة قائمة جهات الاتصال المحفوظة

## الملفات المضافة

### 1. النماذج (Models)
- `lib/features/safety/models/emergency_contact.dart`: نموذج جهة اتصال الطوارئ

### 2. الخدمات (Services)
- `lib/features/safety/services/emergency_contacts_service.dart`: خدمة إدارة جهات الاتصال

### 3. الشاشات (Screens)
- `lib/features/safety/screens/edit_emergency_contacts_screen.dart`: شاشة اختيار وإضافة جهات الاتصال
- `lib/features/safety/screens/emergency_contacts_list_screen.dart`: شاشة عرض وإدارة جهات الاتصال

### 4. مثال الاستخدام
- `lib/features/safety/safety_demo.dart`: مثال على كيفية استخدام الميزة

## المكتبات المستخدمة

تم إضافة المكتبات التالية إلى `pubspec.yaml`:
- `flutter_contacts: ^1.1.7+1`: للوصول إلى جهات الاتصال في الهاتف
- `shared_preferences: ^2.2.2`: لحفظ البيانات محلياً
- `permission_handler: 11.4.0`: لطلب الأذونات (موجودة مسبقاً)

## الميزات الرئيسية

### 1. اختيار جهات الاتصال
- **الوصول الآمن**: طلب إذن المستخدم للوصول إلى جهات الاتصال
- **البحث**: إمكانية البحث في جهات الاتصال بالاسم أو رقم الهاتف
- **الاختيار المتعدد**: إمكانية اختيار عدة جهات اتصال
- **المعاينة الفورية**: عرض عدد جهات الاتصال المختارة

### 2. حفظ وإدارة البيانات
- **الحفظ المحلي**: حفظ جهات الاتصال باستخدام SharedPreferences
- **التحديث التلقائي**: تحميل جهات الاتصال المحفوظة عند فتح الشاشة
- **منع التكرار**: تجنب إضافة جهات اتصال مكررة

### 3. واجهة المستخدم
- **تصميم متجاوب**: واجهة تتكيف مع حالات مختلفة (تحميل، فارغة، أخطاء)
- **دعم اللغة العربية**: جميع النصوص باللغة العربية مع دعم RTL
- **رسائل تأكيد**: إشعارات واضحة للمستخدم عن حالة العمليات

## كيفية الاستخدام

### 1. الانتقال إلى شاشة جهات الاتصال
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EmergencyContactsListScreen(),
  ),
);
```

### 2. إضافة جهات اتصال جديدة
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EditEmergencyContactsScreen(),
  ),
);
```

### 3. استخدام الخدمة مباشرة
```dart
// الحصول على جهات الاتصال المحفوظة
final contacts = await EmergencyContactsService.getEmergencyContacts();

// إضافة جهة اتصال جديدة
await EmergencyContactsService.addEmergencyContact(emergencyContact);

// حذف جهة اتصال
await EmergencyContactsService.removeEmergencyContact(contactId);
```

## الأذونات المطلوبة

تأكد من إضافة الأذونات التالية في:

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSContactsUsageDescription</key>
<string>نحتاج إلى الوصول لجهات الاتصال لإضافة جهات اتصال الطوارئ</string>
```

## التحسينات المستقبلية

يمكن إضافة الميزات التالية:
1. **الاتصال السريع**: إمكانية الاتصال المباشر من قائمة الطوارئ
2. **إرسال الرسائل**: إرسال رسائل تلقائية في حالات الطوارئ
3. **المزامنة السحابية**: حفظ جهات الاتصال في قاعدة البيانات السحابية
4. **التصنيف**: تصنيف جهات الاتصال حسب نوع الطوارئ
5. **الإشعارات**: تنبيهات تذكيرية لتحديث جهات الاتصال

## الاختبار

للاختبار:
1. تشغيل التطبيق على جهاز حقيقي (للوصول إلى جهات الاتصال)
2. التأكد من وجود جهات اتصال في الهاتف
3. اختبار جميع وظائف الإضافة والحذف والبحث
