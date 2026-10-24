class SignInResponseModel {
  final int statusCode;
  final String message;
  final SignInData data;

  SignInResponseModel({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) {
    return SignInResponseModel(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: SignInData.fromJson(json['data'] ?? {}),
    );
  }
}

class SignInData {
  final String accessToken;
  final String refreshToken;
  final String? accountState;
  final List<String> role;
  final bool needsVerification;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;

  SignInData({
    required this.accessToken,
    required this.refreshToken,
    this.accountState,
    required this.role,
    required this.needsVerification,
    this.userId,
    this.firstName,
    this.lastName,
    this.profilePicture,
  });

  factory SignInData.fromJson(Map<String, dynamic> json) {
    // Try to get user info from 'user' object or directly from data
    final user = json['user'] as Map<String, dynamic>?;
    return SignInData(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      accountState: json['accountState'] as String?,
      role: (json['role'] ?? user?['role']) != null
          ? List<String>.from(json['role'] ?? user!['role'])
          : [],
      needsVerification: json['needsVerification'] ?? false,
      userId: user?['_id'] ?? json['userId'] ?? json['_id'],
      firstName: user?['firstName'] ?? json['firstName'],
      lastName: user?['lastName'] ?? json['lastName'],
      profilePicture: user?['profilePicture'] ?? json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accountState': accountState,
      'role': role,
      'needsVerification': needsVerification,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
    };
  }
}
