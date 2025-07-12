import 'package:flutter/material.dart';
import 'package:myplace/features/onboarding/screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق مكاني',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo', // Example font, you might need to add it to pubspec.yaml
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: OnBoardingScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
