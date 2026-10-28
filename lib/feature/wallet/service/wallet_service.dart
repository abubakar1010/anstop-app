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

  /// One page of the user's transactions, newest first.
  Future<TransactionPagination> getTransactions({
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
        // The server defaults to oldest first, which hid every recent
        // deposit behind the first page.
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
        // Leaves out rides the rider paid by card: they never touched the
        // wallet. A driver still sees them as earnings.
        'walletOnly': 'true',
      },
    );

    if (response.isSuccess) {
      return TransactionResponseModel.fromJson(response.responseData).data;
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
