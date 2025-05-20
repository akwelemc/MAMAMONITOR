import 'package:flutter/material.dart';
import 'dart:math' as math;

class Splash2Page extends StatefulWidget {
  @override
  _Splash2PageState createState() => _Splash2PageState();
}

class _Splash2PageState extends State<Splash2Page> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // This controls the rotation speed
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // After 5 seconds, move to the next screen
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash_logo.jpg', height: 250),
            SizedBox(height: 20),
            Text("MAMA MONITOR", style: TextStyle(fontSize: 22, letterSpacing: 2)),
            Text("ENHANCING PRENATAL CARE", style: TextStyle(fontSize: 14)),
            SizedBox(height: 40),
            
            // The rotating loader image
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: Image.asset(
                    'assets/images/loading_icon.png', // <-- Your rotating dot icon
                    height: 60,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
