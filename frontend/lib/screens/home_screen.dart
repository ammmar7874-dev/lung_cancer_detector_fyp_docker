import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Added
import 'scan_screen.dart';
import 'lung_health_screen.dart';
import '../utils/constants.dart';

import '../controllers/auth_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/theme_controller.dart';
import 'history_screen.dart';
import 'tips_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart'; // Added
import '../models/doctor_model.dart';
import '../widgets/doctor_card.dart';
import 'doctor_booking_screen.dart';
import 'all_doctors_screen.dart'; // Added

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final HistoryController _historyController = Get.put(
    HistoryController(),
  ); // Ensure it's active

  @override
  void initState() {
    super.initState();
    _authController.fetchUserData();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    // Get theme controller to check mode
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      extendBody: true,
      body: Obx(() {
        final isDark = themeController.isDarkMode;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. ANIMATED FLOATING APP BAR
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
              expandedHeight: 125, // Reduced height as requested
              flexibleSpace: Container(
                padding: EdgeInsets.only(
                  top:
                      MediaQuery.of(context).padding.top +
                      5, // Reduced top padding slightly
                  bottom: 5, // Reduced bottom padding
                  left: 24,
                  right: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1A237E), const Color(0xFF0D47A1)]
                        : [AppColors.primaryBlue, const Color(0xFF26C6DA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.5)
                          : AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Avatar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              duration: const Duration(seconds: 2),
                            ),
                        GestureDetector(
                          onTap: () => Get.to(() => const ProfileScreen()),
                          child: Obx(() {
                            String localPath =
                                _authController.localProfileImagePath.value;
                            String? imageUrl = _authController
                                .userData
                                .value['profileImageUrl'];

                            ImageProvider? image;
                            if (localPath.isNotEmpty &&
                                File(localPath).existsSync()) {
                              image = FileImage(File(localPath));
                            } else if (imageUrl != null &&
                                imageUrl.isNotEmpty) {
                              image = NetworkImage(imageUrl);
                            }

                            return CircleAvatar(
                              radius: 26,
                              backgroundColor: isDark
                                  ? Colors.grey[800]
                                  : Colors.white,
                              backgroundImage: image,
                              child: image == null
                                  ? Image.network(
                                      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Greeting & Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getGreeting(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate().fadeIn().slideX(begin: -0.2),
                          Obx(
                            () => Text(
                              _authController.userData.value['name']
                                      ?.toString()
                                      .split(' ')[0] ??
                                  'User',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                        ],
                      ),
                    ),

                    // Chatbot Icon
                    GestureDetector(
                      onTap: () => Get.to(() => const ChatbotScreen()),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),
                  ],
                ),
              ),
            ),

            // 2. SCROLLABLE CONTENT
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // AI DOCTORS CAROUSEL SECTION
                  Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Carousel with adjusted dimensions: Height ~95% relative (approx 230), Width 100%
                      SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 250,
                            viewportFraction: 1.0,
                            enlargeCenterPage: false,
                            enableInfiniteScroll: false,
                            autoPlay: true,
                            clipBehavior: Clip.none,
                            padEnds: false,
                          ),
                          items: dummyDoctors.map((doctor) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 10.0,
                                  ),
                                  child: DoctorCard(
                                    doctor: doctor,
                                    onTap: () => Get.to(
                                      () => DoctorBookingScreen(doctor: doctor),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      // "View All" Button - Premium Animated Gradient Design
                      Positioned(
                        bottom: 40,
                        child: GestureDetector(
                          onTap: () => Get.to(() => const AllDoctorsScreen()),
                          child:
                              Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primaryBlue,
                                          Color(0xFF26C6DA),
                                        ], // Blue to Teal Gradient
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryBlue
                                              .withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      "View All Doctors",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  )
                                  .animate(
                                    onPlay: (controller) =>
                                        controller.repeat(reverse: false),
                                  )
                                  .shimmer(
                                    duration: 2500.ms,
                                    color: Colors.white.withOpacity(0.4),
                                    angle: 45,
                                  ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 10),

                  // GRID ROW
                  Row(
                    children: [
                      // LEFT: AI SCANNER
                      Expanded(
                        flex: 12,
                        child: GestureDetector(
                          onTap: () => Get.to(() => const ScanScreen()),
                          child: Container(
                            height: 260,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Theme.of(context).cardColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.black12,
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner_rounded,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    Icon(
                                      Icons.arrow_outward_rounded,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "AI Scan",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child:
                                        Hero(
                                          tag: 'scanner_hero',
                                          child: Image.asset(
                                            'assets/images/icon_3d_scanner.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ).animate().scale().rotate(
                                          begin: -0.05,
                                          end: 0.05,
                                          duration: 3000.ms,
                                          curve: Curves.easeInOut,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // RIGHT COLUMN
                      Expanded(
                        flex: 8,
                        child: SizedBox(
                          height: 260,
                          child: Column(
                            children: [
                              // HISTORY CARD
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      Get.to(() => const HistoryScreen()),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Theme.of(context).cardColor
                                          : const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black.withOpacity(0.3)
                                              : Colors.black12,
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.history_rounded,
                                          color: isDark
                                              ? Colors.redAccent.shade100
                                              : Colors.redAccent,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "History",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDark
                                                    ? Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color
                                                    : Colors.black,
                                              ),
                                            ),
                                            Obx(
                                              () => Text(
                                                "${_historyController.historyList.length} Scan data", // Dynamic Count
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? Colors
                                                            .redAccent
                                                            .shade100
                                                      : Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // TIPS CARD
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Get.to(() => const TipsScreen()),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Theme.of(context).cardColor
                                          : const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black.withOpacity(0.3)
                                              : Colors.black12,
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.lightbulb_outline_rounded,
                                          color: isDark
                                              ? Colors.greenAccent
                                              : Colors.green,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Tips",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDark
                                                    ? Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color
                                                    : Colors.black,
                                              ),
                                            ),
                                            Text(
                                              "Daily Advice",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.greenAccent
                                                    : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 25),

                  // LUNG HEALTH CARD (Moved to Bottom)
                  GestureDetector(
                    onTap: () => Get.to(() => const LungHealthScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Theme.of(context).cardColor
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black12,
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.blue.shade100,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.health_and_safety_outlined,
                                        size: 16,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Lung Health",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Check Your\nVital Capacity",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Take Test",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child:
                                Image.asset(
                                  'assets/images/Lung cancer.png',
                                  fit: BoxFit.contain,
                                ).animate().scale(
                                  duration: 2000.ms,
                                  curve: Curves.elasticOut,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }
}
