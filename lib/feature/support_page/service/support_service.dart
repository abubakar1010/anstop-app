import 'package:ride_sharing/services/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_client.dart';
import '../../../services/api_urls.dart';
import '../data/create_support_request_model.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class SupportService {
  final ApiClient _apiClient = ApiClient();

  /// Get all support messages for current user
  Future<ApiResponse> getMySupportMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken();

      if (accessToken == null || accessToken.isEmpty) {
        return ApiResponse(
          isSuccess: false,
          statusCode: 401,
          errorMessage: AppLocalization.tr.sessionExpiredMessage,
        );
      }

      final response = await _apiClient.getRequest(
        ApiUrls.mySupportMessages,
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

  /// Create a new support message
  Future<ApiResponse> createSupport(CreateSupportRequestModel request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken();

      if (accessToken == null || accessToken.isEmpty) {
        return ApiResponse(
          isSuccess: false,
          statusCode: 401,
          errorMessage: AppLocalization.tr.sessionExpiredMessage,
        );
      }

      final response = await _apiClient.postRequest(
        ApiUrls.createSupport,
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
}
