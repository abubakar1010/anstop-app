import 'package:ride_sharing/services/api_client.dart';
import 'package:ride_sharing/services/api_urls.dart';

class MyRideService {
  final ApiClient _apiClient = ApiClient();

  /// Without [status], returns every ride the user took part in, as rider
  /// or as driver.
  Future<ApiResponse> getMyRides({
    String? status,
    required String accessToken,
  }) async {
    return await _apiClient.getRequest(
      ApiUrls.myRides,
      accessToken: accessToken,
      queryParams: {
        if (status != null) 'status': status,
      },
    );
  }
}
