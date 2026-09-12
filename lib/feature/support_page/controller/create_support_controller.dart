import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/create_support_request_model.dart';
import '../service/support_service.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class CreateSupportController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final formKey = GlobalKey<FormState>();

  // ==================== Services ====================
  final SupportService _supportService = SupportService();

  // ==================== Lifecycle ====================
  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }

  // ==================== Validation ====================
  String? validateSubject(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.subjectRequiredError;
    }
    return null;
  }

  String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.messageRequiredError;
    }
    return null;
  }

  // ==================== Business Logic ====================
  Future<void> submitSupport() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final request = CreateSupportRequestModel(
        subject: subjectController.text.trim(),
        message: messageController.text.trim(),
      );

      final response = await _supportService.createSupport(request);

      if (response.isSuccess) {
        _showSuccessDialog();
      } else {
        errorMessage.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to submit support request';
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('create_support_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.genericErrorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
              const Icon(Icons.check_circle, size: 70, color: Color(0xFF2FA65E)),
              const SizedBox(height: 14),
              Text(
                AppLocalization.tr.submittedSuccessfullyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalization.tr.complaintSubmittedMessage2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to support list
                },
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FA65E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalization.tr.backToSupportButton,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
