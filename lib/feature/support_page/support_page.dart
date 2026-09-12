import 'package:flutter/material.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // Updated: unique name to prevent library-wide conflicts
  String _selectedKey = "v1";

  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Updated: renamed to avoid collisions
    final List<Map<String, String>> _supportComplaints = [
      {"key": "v1", "label": AppLocalization.tr.supportVehicleNotClean},
      {"key": "v2", "label": AppLocalization.tr.supportVehicleTooSmall},
      {"key": "d1", "label": AppLocalization.tr.supportDriverRude},
      {"key": "d2", "label": AppLocalization.tr.supportDriverExtraMoney},
      {"key": "d3", "label": AppLocalization.tr.supportDriverLongRoute},
      {"key": "v3", "label": AppLocalization.tr.supportVehicleACNotWorking},
      {"key": "o1", "label": AppLocalization.tr.supportOtherIssue},
    ];

    final width = 375.0; // as requested

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFE),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= APP BAR =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.menu, size: 28, color: Colors.black),

                      Text(
                        AppLocalization.tr.supportTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),

                      // Placeholder for Logo
                      IconWidget(
                        height: 40.h,
                        width: 40.h,
                        fontSize: 14.sp,
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                 IconWidget(),
                const SizedBox(height: 12),
                Center(child: Text(AppLocalization.tr.supportMessage1)),
                Center(child: Text(AppLocalization.tr.supportMessage2)),
                // ================= DROP DOWN =================
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD3D3D3), width: 1),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedKey,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 26),

                        // Display label instead of key
                        selectedItemBuilder: (context) {
                          return _supportComplaints.map((item) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item["label"]!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1E1E1E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList();
                        },

                        items: _supportComplaints.map((item) {
                          return DropdownMenuItem(
                            value: item["key"],
                            child: Text(
                              item["label"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedKey = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ================= DESCRIPTION FIELD =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD3D3D3)),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: AppLocalization.tr.writeComplaintHint,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ================= SUBMIT BUTTON =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: _showSubmitDialog,
                    child: Container(
                      width: width,
                      height: 51,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor, // picked from your UI
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalization.tr.sendToAdminButton,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================= CUSTOM DIALOG =========================
  void _showSubmitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // as you instructed
          ),
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 70, color: AppColors.primaryColor),

                const SizedBox(height: 14),

                Text(
                  AppLocalization.tr.submittedSuccessfullyTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  AppLocalization.tr.complaintSubmittedMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalization.tr.backToHomeButton,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    AppLocalization.tr.cancelButton,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
