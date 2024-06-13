import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan_pro_app/WelcomeScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/logo.png",
              height: screenSize.height * 0.2,
              width: screenSize.width * 0.4,
            ),
            const SizedBox(height: 20),
            Container(
              height: screenSize.height * 0.15,
              child: Text('Scanner Pro',
                  style: GoogleFonts.inter(
                      color: Color(0xFF2F4FCD),
                      fontWeight: FontWeight.bold,
                      fontSize: screenSize.width * 0.05)),
            ),
          ],
        ),
      ),
    );
  }
}
