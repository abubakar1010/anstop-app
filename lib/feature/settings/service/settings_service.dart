import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../services/api_client.dart';
import '../../../services/api_urls.dart';
import '../data/change_password_request_model.dart';
import '../data/legal_document_model.dart';

class SettingsService {
  final ApiClient _apiClient = ApiClient();

  /// Change password API call
  Future<ApiResponse> changePassword(ChangePasswordRequestModel request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        return ApiResponse(
          isSuccess: false,
          statusCode: 401,
          errorMessage: AppLocalization.tr.sessionExpiredMessage,
        );
      }

      final response = await _apiClient.postRequest(
        ApiUrls.changePassword,
        body: request.toJson(),
        accessToken: accessToken,
      );

      return response;
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  /// Delete account — requires token
  Future<ApiResponse> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        return ApiResponse(
          isSuccess: false,
          statusCode: 401,
          errorMessage: AppLocalization.tr.sessionExpiredMessage,
        );
      }

      final response = await _apiClient.deleteRequest(
        ApiUrls.deleteAccount,
        accessToken: accessToken,
      );

      return response;
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  /// Get legal document by type (PRIVACY_POLICY, TERMS_AND_CONDITIONS, ABOUT_US)
  /// Public endpoint — no token required
  Future<ApiResponse> getLegalDocument(LegalDocumentType type) async {
    try {
      final response = await _apiClient.getRequest(
        ApiUrls.getLegalDocument(type.value),
      );
      return response;
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }
}
