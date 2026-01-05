import 'dart:io';

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../utils/constants.dart';
import '../services/pdf_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'all_doctors_screen.dart';
import 'dashboard_screen.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;
  final File image;

  const ResultScreen({
    super.key,
    required this.resultData,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    // Extracting data
    final String prediction = resultData['prediction'] ?? 'Unknown';
    final double confidence = (resultData['confidence'] ?? 0.0).toDouble();
    final Map<String, dynamic> probabilities =
        resultData['probabilities'] ?? {};

    // CASING HELPER: Try to find key regardless of case
    double getProb(String key) {
      if (probabilities.containsKey(key)) {
        return (probabilities[key] ?? 0.0).toDouble();
      }
      // Try finding case-insensitive match
      var match = probabilities.keys.firstWhere(
        (k) => k.toLowerCase() == key.toLowerCase(),
        orElse: () => "",
      );
      if (match.isNotEmpty) return (probabilities[match] ?? 0.0).toDouble();
      return 0.0;
    }

    final bool isMalignant = prediction.toLowerCase() == 'malignant';
    final Color statusColor = isMalignant
        ? AppColors.malignant
        : AppColors.normal;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Analysis Result",
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Analyzed Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),

            // Prediction Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    "PREDICTION",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  if (resultData['true_label'] != 'N/A') ...[
                    const SizedBox(height: 5),
                    Text(
                      "(Ground Truth: ${resultData['true_label']})",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    prediction.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Confidence: ${(confidence * 100).toStringAsFixed(2)}%",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Probabilities Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Detailed Analysis",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildProbabilityRow(
              context,
              "Healthy / Normal",
              getProb('Normal'),
              AppColors.normal,
            ),
            const SizedBox(height: 15),
            _buildProbabilityRow(
              context,
              "Benign (Non-Cancerous)",
              getProb('Benign'),
              AppColors.benign,
            ),
            const SizedBox(height: 15),
            _buildProbabilityRow(
              context,
              "Malignant (Cancerous)",
              getProb('Malignant'),
              AppColors.malignant,
            ),

            const SizedBox(height: 40),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "This is an AI-assisted tool. Please consult a doctor for a professional diagnosis.",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CONDITIONAL DOCTOR CONSULTATION CARD
            if (prediction.toLowerCase() != 'normal')
              GestureDetector(
                onTap: () => Get.to(() => const AllDoctorsScreen()),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Consult a Specialist",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Book an appointment with top lung specialists immediately.",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

            // Extra spacing for buttons
            const SizedBox(height: 180),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                heroTag: "btn1",
                onPressed: () async {
                  try {
                    await PdfService.generateReport(resultData, image);
                  } catch (e) {
                    Get.snackbar(
                      "Report Generation Failed",
                      "Could not create PDF. Please try again.",
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                backgroundColor: AppColors.primaryBlue,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  "Download Report",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                heroTag: "btn2",
                onPressed: () => Get.offAll(() => const DashboardScreen()),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.primaryBlue),
                ),
                elevation: 2,
                label: Text(
                  "Done",
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityRow(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              "${(value * 100).toStringAsFixed(2)}%",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 12.0,
          percent: value > 1.0
              ? 1.0
              : value, // Safely handle slightly >1 values if any
          backgroundColor: Theme.of(context).dividerColor,
          progressColor: color,
          barRadius: const Radius.circular(10),
          animation: true,
          animationDuration: 1000,
        ),
      ],
    );
  }
}
