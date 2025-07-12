import 'dart:async';
import 'package:flutter/material.dart';

class SOSTimerDialog extends StatefulWidget {
  const SOSTimerDialog({super.key});

  @override
  State<SOSTimerDialog> createState() => _SOSTimerDialogState();
}

class _SOSTimerDialogState extends State<SOSTimerDialog> {
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        // Action to be performed after countdown
        Navigator.of(context).pop(); // Close the dialog
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: const Text(
        'تشغيل الاستغاثة!',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'سيتم إبلاغ جهات الاتصال الخاصة بالطوارئ بوجود حالة طارئة خلال $_countdown ثوانٍ',
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('إلغاء'),
          onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop();
          },
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
