import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authController.fetchUserData();
    ever(authController.userData, (data) {
      if (data.isNotEmpty) {
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "My Profile",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 60), // Spacing for AppBar
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              width: 3,
                            ),
                          ),
                          child: Obx(() {
                            String localPath =
                                authController.localProfileImagePath.value;
                            String? networkUrl = authController
                                .userData
                                .value['profileImageUrl'];

                            ImageProvider? image;
                            if (localPath.isNotEmpty) {
                              image = FileImage(File(localPath));
                            } else if (networkUrl != null &&
                                networkUrl.isNotEmpty) {
                              image = NetworkImage(networkUrl);
                            }

                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primaryBlue
                                  .withOpacity(0.05),
                              backgroundImage: image,
                              child: image == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 50,
                                      color: AppColors.primaryBlue,
                                    )
                                  : null,
                            );
                          }),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => authController.pickProfileImage(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().scale(),

                    const SizedBox(height: 16),
                    Obx(
                      () => Text(
                        authController.userData.value['email'] ?? '',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildTextField(
                      Icons.person_outline_rounded,
                      "Full Name",
                      controller: nameController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      Icons.phone_outlined,
                      "Phone Number",
                      controller: phoneController,
                    ),

                    const SizedBox(height: 30),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: authController.isLoading.value
                              ? null
                              : () {
                                  authController.updateProfile(
                                    nameController.text.trim(),
                                    phoneController.text.trim(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: AppColors.primaryBlue
                                .withValues(alpha: 0.5),
                          ),
                          child: authController.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    TextEditingController? controller,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      cursorColor: AppColors.primaryBlue,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.poppins(
          color:
              Theme.of(context).inputDecorationTheme.labelStyle?.color ??
              Theme.of(context).hintColor,
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true,
        fillColor:
            Theme.of(context).inputDecorationTheme.fillColor ??
            (isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey[50]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.grey.withValues(alpha: 0.2)
                : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }
}
