import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan_pro_app/HomeScreen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Container(
              height: 350,
              width: 150,
              child: Image.asset("assets/images/home_logo.png"),
            ),
            Text(
              "Scan Everywhere",
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Scan documents everywhere\neverytime from your pocket",
              style: GoogleFonts.inter(
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 150,
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                child: Text(
                  "Next",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF2F4FCD)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
