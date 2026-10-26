import 'package:ride_sharing/services/api_client.dart';
import 'package:ride_sharing/services/api_urls.dart';

class PaymentMethodsService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse> listCards() => _apiClient.getRequest(ApiUrls.paymentMethods);

  /// Returns `setupIntentClientSecret`, `customerId` and `ephemeralKey` for
  /// the payment sheet, which then saves the card straight to Stripe.
  Future<ApiResponse> createSetupIntent() =>
      _apiClient.postRequest(ApiUrls.paymentMethodsSetupIntent, body: {});

  Future<ApiResponse> setDefault(String id) =>
      _apiClient.patchRequest(ApiUrls.paymentMethodDefault(id), body: {});

  Future<ApiResponse> removeCard(String id) =>
      _apiClient.deleteRequest(ApiUrls.paymentMethod(id));
}
