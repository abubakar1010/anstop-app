import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/support_message_model.dart';
import '../service/support_service.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class SupportListController extends GetxController {
  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<SupportMessageModel> supportMessages = <SupportMessageModel>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalResults = 0.obs;

  // ==================== Services ====================
  final SupportService _supportService = SupportService();

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    fetchSupportMessages();
  }

  // ==================== Business Logic ====================
  Future<void> fetchSupportMessages() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _supportService.getMySupportMessages();

      if (response.isSuccess) {
        final supportResponse = SupportListResponse.fromJson(response.responseData);
        if (supportResponse.success) {
          supportMessages.value = supportResponse.results;
          currentPage.value = supportResponse.page;
          totalPages.value = supportResponse.totalPages;
          totalResults.value = supportResponse.totalResults;
        } else {
          errorMessage.value = supportResponse.message.isNotEmpty
              ? supportResponse.message
              : 'Failed to load support messages';
        }
      } else {
        errorMessage.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to load support messages';
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('support_list_controller: $e');
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

  Future<void> refreshMessages() async {
    await fetchSupportMessages();
  }
}
