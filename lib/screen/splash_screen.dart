import 'package:ralpal/screen/get_started_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top left decoration
          Positioned(
            top: -5,
            left: 5,
            child: Image.asset('assets/images/strike.png', width: 100),
          ),
          // Bottom right decoration
          Positioned(
            bottom: 0,
            right: -20,
            child: Image.asset(
              'assets/images/splsh_screen_logo.png',
              width: 160,
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 120),
                const SizedBox(height: 20),
                const Text(
                  'Color Scanner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B50FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
