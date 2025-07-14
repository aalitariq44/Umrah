# ميزة جهات الاتصال للطوارئ ونظام الاستغاثة

## الوصف
تتيح هذه الميزة للمستخدمين إدارة جهات الاتصال للطوارئ واستخدام نظام استغاثة تلقائي فعال من خلال:
- اختيار جهات الاتصال من دفتر العناوين الحقيقي في الهاتف
- حفظ جهات الاتصال المختارة محلياً
- عرض وإدارة قائمة جهات الاتصال المحفوظة
- **نظام استغاثة تلقائي مع عد تنازلي 10 ثوانٍ**
- **اتصال تلقائي بجميع جهات الطوارئ**
- **إمكانية إلغاء الاستغاثة قبل بدء المكالمات**

## الملفات المضافة

### 1. النماذج (Models)
- `lib/features/safety/models/emergency_contact.dart`: نموذج جهة اتصال الطوارئ

### 2. الخدمات (Services)
- `lib/features/safety/services/emergency_contacts_service.dart`: خدمة إدارة جهات الاتصال
- `lib/features/safety/services/emergency_call_service.dart`: خدمة تنفيذ المكالمات الطارئة

### 3. الشاشات (Screens)
- `lib/features/safety/screens/edit_emergency_contacts_screen.dart`: شاشة اختيار وإضافة جهات الاتصال
- `lib/features/safety/screens/emergency_contacts_list_screen.dart`: شاشة عرض وإدارة جهات الاتصال
- `lib/features/safety/screens/emergency_alert_screen.dart`: شاشة الاستغاثة مع العد التنازلي
- `lib/features/safety/screens/emergency_demo_screen.dart`: شاشة تجريبية لنظام الاستغاثة

### 4. الواجهات (Widgets)
- `lib/features/safety/widgets/emergency_button.dart`: زر الاستغاثة القابل للإضافة في أي شاشة

### 5. أمثلة الاستخدام
- `lib/features/safety/safety_demo.dart`: مثال شامل على الاستخدام
- `lib/features/safety/examples/emergency_button_examples.dart`: أمثلة مختلفة لاستخدام زر الاستغاثة

## المكتبات المستخدمة

تم إضافة المكتبات التالية إلى `pubspec.yaml`:
- `flutter_contacts: ^1.1.7+1`: للوصول إلى جهات الاتصال في الهاتف
- `shared_preferences: ^2.2.2`: لحفظ البيانات محلياً
- `url_launcher: ^6.3.0`: لتنفيذ المكالمات الهاتفية (موجودة مسبقاً)
- `permission_handler: 11.4.0`: لطلب الأذونات (موجودة مسبقاً)

## الميزات الرئيسية

### 1. اختيار جهات الاتصال
- **الوصول الآمن**: طلب إذن المستخدم للوصول إلى جهات الاتصال
- **البحث**: إمكانية البحث في جهات الاتصال بالاسم أو رقم الهاتف
- **الاختيار المتعدد**: إمكانية اختيار عدة جهات اتصال
- **المعاينة الفورية**: عرض عدد جهات الاتصال المختارة

### 2. نظام الاستغاثة الذكي ⚡
- **عد تنازلي**: 10 ثوانٍ للمراجعة وإمكانية الإلغاء
- **اتصال تلقائي**: اتصال تلقائي بجميع جهات الطوارئ المحفوظة
- **فاصل زمني**: 5 ثوانٍ بين كل مكالمة لضمان الوضوح
- **رسائل تأكيد**: عرض نتائج كل مكالمة (نجحت أم فشلت)
- **واجهة مميزة**: تصميم مرئي واضح مع تأثيرات حركية

### 3. حفظ وإدارة البيانات
- **الحفظ المحلي**: حفظ جهات الاتصال باستخدام SharedPreferences
- **التحديث التلقائي**: تحميل جهات الاتصال المحفوظة عند فتح الشاشة
- **منع التكرار**: تجنب إضافة جهات اتصال مكررة

### 4. واجهة المستخدم
- **تصميم متجاوب**: واجهة تتكيف مع حالات مختلفة (تحميل، فارغة، أخطاء)
- **دعم اللغة العربية**: جميع النصوص باللغة العربية مع دعم RTL
- **رسائل تأكيد**: إشعارات واضحة للمستخدم عن حالة العمليات
- **زر قابل للتخصيص**: يمكن إضافته في أي مكان بأحجام مختلفة

## كيفية الاستخدام

### 1. إضافة زر الاستغاثة في أي شاشة
```dart
// زر كبير مع تسمية
EmergencyButton(
  size: 100,
  showLabel: true,
)

// زر صغير بدون تسمية (للـ FAB)
EmergencyButton(
  size: 60,
  showLabel: false,
)

// زر صغير في شريط التطبيق
EmergencyButton(
  size: 40,
  showLabel: false,
)
```

### 2. الانتقال إلى شاشة نظام الاستغاثة الكامل
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EmergencyDemoScreen(),
  ),
);
```

### 3. إدارة جهات الاتصال
```dart
// شاشة عرض جهات الاتصال
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EmergencyContactsListScreen(),
  ),
);

// شاشة إضافة جهات اتصال جديدة
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EditEmergencyContactsScreen(),
  ),
);
```

### 4. استخدام الخدمات مباشرة
```dart
// تنفيذ استغاثة برمجياً
try {
  final results = await EmergencyCallService.executeEmergencyCalls();
  // معالجة النتائج
} catch (e) {
  // معالجة الأخطاء
}

// الحصول على العد التنازلي
EmergencyCallService.startEmergencyCountdown().listen((seconds) {
  print('باقي $seconds ثانية');
});
```

## آلية عمل نظام الاستغاثة

### 1. عند الضغط على زر الاستغاثة:
1. **تأكيد الاستغاثة**: حوار تأكيد للتأكد من الرغبة في الاستغاثة
2. **فحص جهات الاتصال**: التأكد من وجود جهات اتصال محفوظة
3. **عد تنازلي**: 10 ثوانٍ مع إمكانية الإلغاء
4. **تنفيذ المكالمات**: اتصال تلقائي بجميع جهات الطوارئ
5. **تقرير النتائج**: عرض نتائج كل مكالمة

### 2. المكالمات التلقائية:
- **ترتيب تسلسلي**: مكالمة واحدة في كل مرة
- **فاصل زمني**: 5 ثوانٍ بين المكالمات
- **تنظيف الأرقام**: إزالة الرموز والمسافات تلقائياً
- **معالجة الأخطاء**: تسجيل المكالمات الناجحة والفاشلة

## الأذونات المطلوبة

تأكد من إضافة الأذونات التالية في:

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.CALL_PHONE" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSContactsUsageDescription</key>
<string>نحتاج إلى الوصول لجهات الاتصال لإضافة جهات اتصال الطوارئ</string>
```

## أمثلة التطبيق

### 1. في الشاشة الرئيسية
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // المحتوى العادي
      body: YourContent(),
      
      // زر الاستغاثة في الزاوية
      floatingActionButton: EmergencyButton(size: 60),
    );
  }
}
```

### 2. في شريط التطبيق
```dart
AppBar(
  title: Text('التطبيق'),
  actions: [
    EmergencyButton(size: 40, showLabel: false),
  ],
)
```

### 3. في منطقة ثابتة
```dart
Container(
  padding: EdgeInsets.all(16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      EmergencyButton(size: 80, showLabel: true),
    ],
  ),
)
```

## التحسينات المستقبلية

يمكن إضافة الميزات التالية:
1. **إرسال الرسائل النصية**: رسائل تلقائية مع الموقع
2. **تسجيل صوتي**: تسجيل رسالة صوتية تلقائية
3. **إرسال الموقع**: مشاركة الموقع الجغرافي تلقائياً
4. **الإشعارات**: تنبيهات لجهات الاتصال عن الاستغاثة
5. **سجل الاستغاثات**: حفظ تاريخ كل استغاثة
6. **أنواع الطوارئ**: تصنيف حسب نوع الطوارئ
7. **التكامل مع الخدمات**: ربط بخدمات الطوارئ الرسمية

## الاختبار

للاختبار:
1. تشغيل التطبيق على جهاز حقيقي (للوصول إلى جهات الاتصال والاتصال)
2. التأكد من وجود جهات اتصال في الهاتف
3. إضافة جهات اتصال للطوارئ
4. اختبار نظام الاستغاثة (تأكد من إبلاغ جهات الاتصال أنه اختبار)
5. اختبار إلغاء الاستغاثة خلال العد التنازلي

⚠️ **تحذير مهم**: استخدم هذا النظام في حالات الطوارئ الحقيقية فقط، وتأكد من إبلاغ جهات الاتصال عند إجراء اختبارات.
