import 'package:ride_sharing/feature/wallet/data/transaction_model.dart';
import 'package:ride_sharing/services/api_client.dart';
import 'package:ride_sharing/services/api_urls.dart';



class WalletService {
  final ApiClient _apiClient = ApiClient();

  /// Asks the server for a wallet top-up PaymentIntent. The response carries
  /// `clientSecret` for the payment sheet; the server credits the wallet itself
  /// once Stripe confirms the payment.
  Future<ApiResponse> createDepositIntent({
    required String accessToken,
    required double amount,
  }) async {
    try {
      final response = await _apiClient.postRequest(
        ApiUrls.depositIntent,
        body: {
          'amount': amount,
        },
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

  Future<List<TransactionModel>> getTransactions({
    String? accessToken,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.getRequest(
      ApiUrls.getTransactions,
      accessToken: accessToken,
      queryParams: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.isSuccess) {
      final model = TransactionResponseModel.fromJson(response.responseData);
      return model.data.results;
    } else {
      throw Exception(response.errorMessage);
    }
  }

  Future<ApiResponse> createWithdrawalRequest({
    required String accessToken,
    required int amount,
    required String bankName,
    required String accountNumber,
  }) async {
    try {
      final response = await _apiClient.postRequest(
        ApiUrls.withdrawalRequests,
        body: {
          'amount': amount,
          'bankName': bankName,
          'accountNumber': accountNumber,
        },
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
