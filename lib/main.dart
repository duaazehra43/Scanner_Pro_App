import 'package:flutter/material.dart';
import 'package:scan_pro_app/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBYy4egAwHfAEe-bB2g03NSK-2rKSzRfsw",
          appId: "1:620713673389:android:80b8dd8d71649e56d77c24",
          messagingSenderId: "620713673389",
          projectId: "scanner-pro-d3fc5",
          storageBucket: "scanner-pro-d3fc5.appspot.com"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
