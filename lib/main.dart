import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'services/notification_service.dart';
void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();

await NotificationService.init();

  runApp(
    const SafeHerApp(),
  );
}

class SafeHerApp extends StatelessWidget {
  const SafeHerApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      title: 'SafeHer',

      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor:
            const Color(0xFFF7F8FC),

        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              const Color(
            0xFFFF6A88,
          ),
        ),
      ),

     home: const SplashScreen(),
    );
  }
}