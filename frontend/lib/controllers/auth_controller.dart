import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../screens/auth/login_screen.dart';
import '../screens/dashboard_screen.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Observable user
  late Rx<User?> firebaseUser;

  // Loading state
  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    // Optional: Check SharedPreferences if you want complex session rules,
    // but Firebase Auth state is usually sufficient.
    user == null
        ? Get.offAll(() => const LoginScreen())
        : Get.offAll(() => const DashboardScreen());
  }

  // --- Registration ---
  Future<void> registerUser(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save additional user info to Firestore
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      // Save local session (optional, but requested)
      await _saveUserSession(userCredential.user!);

      Get.snackbar(
        "Success",
        "Account created successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error",
        e.message ?? "Registration failed",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Login ---
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveUserSession(userCredential.user!);

      Get.snackbar(
        "Success",
        "Logged in successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Login Failed",
        e.message ?? "Unknown error",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Logout ---
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      await _clearSession();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Logout failed: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // --- Forgot Password ---
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "Success",
        "Password reset email sent to $email",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error",
        e.message ?? "Failed to send reset email",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- Profile Management ---
  final userData = Rx<Map<String, dynamic>>({});

  void fetchUserData() async {
    if (_auth.currentUser != null) {
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      if (doc.exists) {
        userData.value = doc.data() as Map<String, dynamic>;
      }
    }
  }

  Future<void> updateProfile(String name, String phone) async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser!.uid;

      await _db.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
      });

      // Update local observable
      userData.update((val) {
        val?['name'] = name;
        val?['phone'] = phone;
      });

      Get.snackbar(
        "Success",
        "Profile updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update profile",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- Profile Image (Local Only) ---
  final localProfileImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalProfileImage();
  }

  void _loadLocalProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString('local_profile_image');
    if (path != null && File(path).existsSync()) {
      localProfileImagePath.value = path;
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        isLoading.value = true;
        // Save locally
        localProfileImagePath.value = image.path;

        // Persist path
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_profile_image', image.path);

        Get.snackbar(
          "Success",
          "Profile picture updated locally!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- Persistence Helper Methods ---
  Future<void> _saveUserSession(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.uid);
    await prefs.setString('userEmail', user.email ?? '');
  }

  Future<void> _clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
