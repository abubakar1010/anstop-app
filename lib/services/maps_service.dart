import 'api_client.dart';
import 'api_urls.dart';
import 'locale_service.dart';

class MapsService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> directions(double originLat, double originLng,
      double destinationLat, double destinationLng) async {
    final response = await _api.getRequest(ApiUrls.mapsDirections, queryParams: {
      'originLat': originLat, 'originLng': originLng,
      'destinationLat': destinationLat, 'destinationLng': destinationLng,
    });
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return Map<String, dynamic>.from(response.responseData['data'] as Map);
  }

  Future<List<Map<String, dynamic>>> autocomplete(String input) async {
    final response = await _api.getRequest(ApiUrls.mapsAutocomplete, queryParams: {
      'input': input, 'language': LocaleService.languageCode,
    });
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return (response.responseData['data'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<Map<String, dynamic>> placeDetails(String placeId) async {
    final response = await _api.getRequest(
        '${ApiUrls.mapsPlaceDetails}/${Uri.encodeComponent(placeId)}');
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return Map<String, dynamic>.from(response.responseData['data'] as Map);
  }
}
