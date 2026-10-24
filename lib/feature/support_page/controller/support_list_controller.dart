import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
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
        final raw = response.responseData;
        final supportResponse = SupportListResponse.fromJson(
          raw is Map<String, dynamic> ? raw : <String, dynamic>{},
        );
        if (supportResponse.success) {
          supportMessages.value = supportResponse.results;
          currentPage.value = supportResponse.page;
          totalPages.value = supportResponse.totalPages;
          totalResults.value = supportResponse.totalResults;
        } else {
          errorMessage.value = AppLocalization.tr.supportLoadFailedMessage;
        }
      } else {
        errorMessage.value = AppLocalization.tr.supportLoadFailedMessage;
        _showErrorSnackbar();
      }
    } catch (e) {
      debugPrint('support_list_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      _showErrorSnackbar();
    } finally {
      isLoading.value = false;
    }
  }

  /// fetchSupportMessages() runs from onInit(), i.e. before the route's
  /// Overlay exists, so showing a snackbar right away throws
  /// "No Overlay widget found". Defer it to after the frame is built.
  void _showErrorSnackbar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) return;
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    });
  }

  Future<void> refreshMessages() async {
    await fetchSupportMessages();
  }
}
