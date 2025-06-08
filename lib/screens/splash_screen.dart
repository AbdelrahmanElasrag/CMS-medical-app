import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cms/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      // Fade transition to WelcomeScreen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade in and out animation
            const begin = 0.0;
            const end = 1.0;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeIn));
            var fadeAnimation = animation.drive(tween);

            return FadeTransition(opacity: fadeAnimation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          const Image(
            image: AssetImage('assets/images/Tons.jpeg'), // your background image
            fit: BoxFit.cover,
          ),

          // Foreground Content
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Image(
                    image: AssetImage('assets/images/newlogo.png'),
                    height: 120,
                  ),
                  SizedBox(height: 20),
                  Text(
                    ' ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0f5145),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 13),
                  Text(
                    'We Care With Creative Way',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0f5145),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}