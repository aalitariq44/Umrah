# نظام المكالمات باستخدام ZegoCloud

## الميزات المُضافة:

### 1. **المكالمات الصوتية والمرئية**
- مكالمات صوتية عالية الجودة
- مكالمات مرئية مع دعم تبديل الكاميرا
- أزرار التحكم: كتم الصوت، تبديل السماعة، إنهاء المكالمة

### 2. **إدارة المكالمات**
- إرسال دعوات المكالمات
- استقبال إشعارات المكالمات الواردة
- قبول أو رفض المكالمات
- حفظ تاريخ المكالمات في Firebase

### 3. **الأذونات المطلوبة**
- إذن الميكروفون للمكالمات الصوتية
- إذن الكاميرا والميكروفون للمكالمات المرئية
- أذونات إضافية في Android (تم إضافتها تلقائياً)

## الملفات المُضافة:

### 📁 **Core Config**
- `lib/core/config/zego_config.dart` - إعدادات ZegoCloud

### 📁 **Call Screens**
- `lib/features/call/screens/voice_call_screen.dart` - شاشة المكالمة الصوتية
- `lib/features/call/screens/video_call_screen.dart` - شاشة المكالمة المرئية

### 📁 **Call Services**
- `lib/features/call/services/call_manager.dart` - مدير المكالمات
- `lib/features/call/services/call_permission_manager.dart` - مدير الأذونات

### 📁 **Call Widgets**
- `lib/features/call/widgets/incoming_call_dialog.dart` - حوار المكالمة الواردة
- `lib/features/call/widgets/call_notification_handler.dart` - معالج إشعارات المكالمات

## كيفية الاستخدام:

### 1. **بدء مكالمة من شاشة الدردشة:**
```dart
// مكالمة صوتية
await CallManager.initiateCall(
  context: context,
  targetUser: friendUser,
  currentUser: currentUser,
  callType: CallType.voice,
);

// مكالمة مرئية
await CallManager.initiateCall(
  context: context,
  targetUser: friendUser,
  currentUser: currentUser,
  callType: CallType.video,
);
```

### 2. **استقبال المكالمات:**
- يتم استقبال المكالمات تلقائياً عبر `CallNotificationHandler`
- يظهر حوار للمستخدم مع خيارات القبول أو الرفض

### 3. **إدارة الأذونات:**
- يتم فحص الأذونات تلقائياً قبل بدء المكالمة
- إذا لم تكن متوفرة، يطلب التطبيق الأذونات من المستخدم

## التكوين المطلوب:

### 1. **ZegoCloud:**
- AppID: `803510352`
- AppSign: `6bbbe67d64385c746cc6853b0b7e56b23142991a9d056fd8072538cc2a4eb711`

### 2. **الحزم المُضافة:**
```yaml
dependencies:
  zego_uikit_prebuilt_call: ^4.14.5
```

### 3. **الأذونات في Android:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.DISABLE_KEYGUARD" />
<uses-permission android:name="android.permission.TURN_SCREEN_ON" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

## الخطوات التالية:

1. **تشغيل `flutter pub get`** لتحميل المكتبة الجديدة
2. **اختبار المكالمات** على جهازين مختلفين
3. **تخصيص واجهة المكالمات** حسب التصميم المطلوب
4. **إضافة ميزات إضافية** مثل:
   - رسائل نصية أثناء المكالمة
   - مشاركة الشاشة
   - المكالمات الجماعية

## ملاحظات مهمة:

⚠️ **هذا الإعداد يتطلب:**
- حساب ZegoCloud نشط
- اتصال إنترنت مستقر
- جهازين مختلفين للاختبار (لا يمكن اختبار المكالمات على نفس الجهاز)

✅ **تم إنجاز:**
- إعداد البنية الأساسية للمكالمات
- إضافة واجهات المكالمات الصوتية والمرئية
- نظام إدارة الأذونات
- معالجة المكالمات الواردة
- حفظ تاريخ المكالمات في Firebase
