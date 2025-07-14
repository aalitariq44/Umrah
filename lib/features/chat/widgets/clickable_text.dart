import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const ClickableText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> spans = [];
    final phoneRegex = RegExp(r'(\+?\d{1,4}[\s-]?)?(\(?\d{1,4}\)?[\s-]?)?\d{1,4}[\s-]?\d{1,4}[\s-]?\d{1,9}');
    
    int lastEnd = 0;
    
    for (final match in phoneRegex.allMatches(text)) {
      // إضافة النص العادي قبل رقم الهاتف
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: style,
        ));
      }
      
      // إضافة رقم الهاتف كرابط قابل للنقر
      final phoneNumber = match.group(0)!;
      if (_isValidPhoneNumber(phoneNumber)) {
        spans.add(TextSpan(
          text: phoneNumber,
          style: (style ?? const TextStyle()).copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _makePhoneCall(phoneNumber),
        ));
      } else {
        spans.add(TextSpan(
          text: phoneNumber,
          style: style,
        ));
      }
      
      lastEnd = match.end;
    }
    
    // إضافة باقي النص
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: style,
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }
  
  bool _isValidPhoneNumber(String phone) {
    // إزالة المسافات والرموز
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // التحقق من أن الرقم يحتوي على ما بين 7-15 رقم
    return cleanPhone.length >= 7 && cleanPhone.length <= 15;
  }
  
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final url = Uri.parse('tel:$cleanPhone');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint('خطأ في فتح تطبيق الهاتف: $e');
    }
  }
}
