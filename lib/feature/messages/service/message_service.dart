import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../services/api_client.dart';
import '../../../services/api_urls.dart';

class MessageService {
  final ApiClient _apiClient = ApiClient();

  /// Get messages by conversation ID (rideId) with pagination support
  Future<ApiResponse> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
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

      final response = await _apiClient.getRequest(
        ApiUrls.getMessages(conversationId, page: page, limit: limit),
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

  /// Get current user ID from shared preferences
  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userId');
    } catch (e) {
      return null;
    }
  }

  /// Get current user info including ID, name, and profile picture
  Future<Map<String, String?>> getCurrentUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'userId': prefs.getString('userId'),
        'userName': '${prefs.getString('firstName') ?? ''} ${prefs.getString('lastName') ?? ''}'.trim(),
        'profilePicture': prefs.getString('profilePicture'),
      };
    } catch (e) {
      return {
        'userId': null,
        'userName': null,
        'profilePicture': null,
      };
    }
  }
}
