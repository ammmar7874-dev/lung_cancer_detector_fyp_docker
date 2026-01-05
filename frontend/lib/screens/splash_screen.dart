import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 Seconds Duration
    Future.delayed(const Duration(seconds: 3), () {
      Get.put(AuthController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light Background requested
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ripple/Glow Effect (Subtle)
          Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.05),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.5, 1.5),
                duration: 2000.ms,
                curve: Curves.easeInOut,
              ),

          // Second Ripple
          Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.08),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),

          // Main Large Logo
          Center(
                child: Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 220, // Significantly larger size
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
              )
              .animate()
              .scale(
                // Entrance
                duration: 800.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
              )
              .then(delay: 200.ms)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                // Breathing
                end: 1.08,
                duration: 1500.ms,
                curve: Curves.easeInOut,
              )
              .shimmer(
                // Shiny effect
                duration: 2000.ms,
                color: Colors.white.withOpacity(0.5),
                angle: 45,
              ),
        ],
      ),
    );
  }
}
