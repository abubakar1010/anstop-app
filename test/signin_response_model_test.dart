import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sharing/feature/auth/data/signin_response_model.dart';

void main() {
  test('parses the server sign-in contract for driver routing', () {
    final response = SignInResponseModel.fromJson({
      'statusCode': 200,
      'message': 'Signed in',
      'data': {
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'accountState': 'PENDING_REVIEW',
        'user': {
          '_id': 'driver-id',
          'role': ['DRIVER'],
          'firstName': 'Driver',
        },
      },
    });

    expect(response.data.role, ['DRIVER']);
    expect(response.data.accountState, 'PENDING_REVIEW');
    expect(response.data.userId, 'driver-id');
  });
}
