import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../data/legal_document_model.dart';
import '../service/settings_service.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

class LegalPagesController extends GetxController {
  final _logger = Logger();
  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<LegalDocumentModel?> legalDocument = Rx<LegalDocumentModel?>(null);
  final Rx<LegalDocumentType> documentType = LegalDocumentType.termsAndConditions.obs;

  // ==================== Services ====================
  final SettingsService _settingsService = SettingsService();

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    _logger.i('LegalPagesController init — arguments: $args');
    if (args != null && args is Map) {
      final type = args['type'];
      if (type != null && type is LegalDocumentType) {
        documentType.value = type;
        _logger.i('Document type set to: ${type.value}');
      } else {
        _logger.w('No valid LegalDocumentType found in arguments — defaulting to termsAndConditions');
      }
    } else {
      _logger.w('Arguments are null or not a Map — defaulting to termsAndConditions');
    }
    fetchLegalDocument();
  }

  // ==================== Business Logic ====================
  Future<void> fetchLegalDocument() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      _logger.i('Fetching legal document — type: ${documentType.value.value}');

      final response = await _settingsService.getLegalDocument(documentType.value);

      _logger.i('Response — statusCode: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.isSuccess) {
        final legalResponse = LegalDocumentResponse.fromJson(response.responseData);
        _logger.i('Parsed response — success: ${legalResponse.success}, hasData: ${legalResponse.data != null}');

        if (legalResponse.success && legalResponse.data != null) {
          legalDocument.value = legalResponse.data;
          _logger.i('Document loaded — title: ${legalResponse.data!.title}, descriptionLength: ${legalResponse.data!.description.length}');
        } else {
          errorMessage.value = legalResponse.message.isNotEmpty
              ? legalResponse.message
              : AppLocalization.tr.genericErrorMessage;
          _logger.w('Document load failed — message: ${errorMessage.value}');
        }
      } else {
        errorMessage.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : AppLocalization.tr.genericErrorMessage;
        _logger.e('API error — statusCode: ${response.statusCode}, error: ${errorMessage.value}');
        AppSnackbar.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('legal_pages_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      _logger.e('Exception during fetch', error: e, stackTrace: stackTrace);
      AppSnackbar.snackbar(
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

  // ==================== Getters ====================
  String get title => legalDocument.value?.title ?? _getDefaultTitle();
  String get description => legalDocument.value?.description ?? '';

  String _getDefaultTitle() {
    switch (documentType.value) {
      case LegalDocumentType.privacyPolicy:
        return AppLocalization.tr.privacyPolicyTitle;
      case LegalDocumentType.termsAndConditions:
        return AppLocalization.tr.termsOfServiceTitle;
      case LegalDocumentType.aboutUs:
        return AppLocalization.tr.aboutUsTitle;
    }
  }
}
