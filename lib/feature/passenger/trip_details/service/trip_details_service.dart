import 'package:ride_sharing/services/session_controller.dart';
import 'package:ride_sharing/services/api_client.dart';
import 'package:ride_sharing/services/api_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class TripDetailsService {
  final ApiClient _apiClient = ApiClient();

  /// Get ride/trip details by ride ID
  Future<ApiResponse> getTripDetails(String rideId) async {
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

      // Make the API request
      final response = await _apiClient.getRequest(
        ApiUrls.getRideDetails(rideId),
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

  /// Save access token to shared preferences (if not already saved)
  Future<void> saveAccessToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', token);
    } catch (e) {
      // Error saving access token
    }
  }

  /// Get access token from shared preferences
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await SessionController.to.accessToken();
    } catch (e) {
      // Error getting access token
      return null;
    }
  }
}
