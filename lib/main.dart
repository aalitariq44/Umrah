import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myplace/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'package:myplace/features/auth/controller/auth_controller.dart';
import 'package:myplace/features/chat/controller/chat_controller.dart';
import 'package:myplace/features/auth/screens/login_screen.dart';
import 'package:myplace/features/main_navigation/home_screen.dart';
import 'package:myplace/features/call/widgets/call_notification_handler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myplace/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
      ],
      child: MaterialApp(
        title: 'تطبيق مكاني',
        theme: AppTheme.lightTheme,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', ''),
          Locale('en', ''),
        ],
        locale: const Locale('ar', ''),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // User is logged in, now check if user data is loaded
          return FutureBuilder(
            future: Provider.of<AuthController>(context, listen: false)
                .loadCurrentUser(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              // After loading, AuthController will have the user details.
              // The HomeScreen can now safely access it.
              return const CallNotificationHandler(
                child: HomeScreen(initialIndex: 3),
              );
            },
          );
        }
        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
