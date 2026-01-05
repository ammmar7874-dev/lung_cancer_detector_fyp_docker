import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth/login_screen.dart'; // Navigate to Login instead of Dashboard
import '../utils/constants.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView implementation (simplified for brevity, can be expanded)
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Use the generated 3D asset here
                Image.asset(
                  'assets/images/onboarding_diagnosis.png',
                  height: 300,
                ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                const SizedBox(height: 40),
                const Text(
                  "Advanced AI Detection",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Detect lung cancer early with 99.9% accuracy using our state-of-the-art deep learning model.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Login first
                        Get.off(() => const LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 10,
                        shadowColor: AppColors.primaryBlue.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      child: const Text(
                        "GET STARTED",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).moveY(begin: 20, end: 0),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
