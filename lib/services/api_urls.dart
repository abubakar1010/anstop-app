class ApiUrls {
  /// Server origin. Override for local dev, e.g.
  /// `flutter run --dart-define=API_HOST=http://localhost:8000`
  static const String apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'https://api.anstopcovoiturage.com',
  );

  //static const String baseUrl = "http://217.15.170.117";
 // static const String baseUrl = "https://abu-bakar8000.merinasib.shop/api/v1";
  static const String baseUrl = "$apiHost/api/v1";
 // static const String baseUrl = "https://zeron-8000.ssh.bd/api/v1";


  ///Authentication///
 // static const String register = '$baseUrl/auth/register';
  static const String signUp = '$baseUrl/auth/sign-up';
  static const String signIn = '$baseUrl/auth/sign-in';
  static const String refresh = '$baseUrl/auth/refresh';
  static const String logout = '$baseUrl/auth/logout';
  static const String me = '$baseUrl/auth/me';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String uploadFiles = '$baseUrl/users/upload-files';
  static const String driverOnboard = '$baseUrl/drivers/onboard';
  static const String driverOnboardingStatus = '$baseUrl/drivers/onboarding-status';
  static const String setLanguagePreference = '$baseUrl/shared/set-language-preference';


  //static const String imageBaseUrl = "http://217.15.170.117/";
 // static const String imageBaseUrl = "https://mihad4000.merinasib.shop/";
  static const String imageBaseUrl = "$apiHost/";


  //static const String socketUrl = "http://217.15.170.117";
  static const String socketUrl = apiHost;

  static const String myRides = '$baseUrl/rides/my-rides';
  static const String currentRide = '$baseUrl/rides/current';
  static const String mapsDirections = '$baseUrl/maps/directions';
  static const String mapsAutocomplete = '$baseUrl/maps/autocomplete';
  static const String mapsPlaceDetails = '$baseUrl/maps/place-details';

  static String getRideDetails(String rideId) => '$baseUrl/rides/$rideId';

  // Messages
  static String getMessages(String conversationId, {int page = 1, int limit = 50}) =>
      '$baseUrl/messages/$conversationId?page=$page&limit=$limit';

  // Settings
  static const String changePassword = '$baseUrl/auth/change-password';

  // Legal Documents
  static String getLegalDocument(String type) => '$baseUrl/legal-documents?type=$type';

  // Support
  static const String mySupportMessages = '$baseUrl/supports/my-messages';
  static const String createSupport = '$baseUrl/supports';

  // Account
  static const String deleteAccount = '$baseUrl/users/account';

  // Profile
  static const String myProfile = '$baseUrl/users/my-profile';
  static const String updateProfile = '$baseUrl/users/profile';

  // Transactions
  static const String depositIntent = '$baseUrl/transactions/deposit-intent';
  static const String getTransactions = '$baseUrl/transactions';
  static const String getBalance = '$baseUrl/users/balance';

  // Withdrawal
  static const String withdrawalRequests = '$baseUrl/withdrawal-requests';


  // Ride Requests
  static String calculateFare({
    required double pickUpLat,
    required double pickUpLng,
    required double destinationLat,
    required double destinationLng,
  }) => '$baseUrl/ride-requests/calculate-fare?pickUpLat=$pickUpLat&pickUpLng=$pickUpLng&destinationLat=$destinationLat&destinationLng=$destinationLng';
  static const String createRideRequest = '$baseUrl/ride-requests/create-ride-request';
  static String payRideFare(String rideId) => '$baseUrl/ride-requests/pay-ride-fare/$rideId';
  static const String createReview = '$baseUrl/reviews';
  static const String setFcmToken = '$baseUrl/users/fcm-token';
  static const String notifications = '$baseUrl/notifications';
  static const String notificationsUnreadCount = '$baseUrl/notifications/unread-count';
  static const String notificationsReadAll = '$baseUrl/notifications/read-all';
  static String notificationRead(String id) => '$baseUrl/notifications/$id/read';

  // Saved cards (stored by Stripe; the server returns brand, last 4 and expiry)
  static const String paymentMethods = '$baseUrl/payment-methods';
  static const String paymentMethodsSetupIntent = '$baseUrl/payment-methods/setup-intent';
  static String paymentMethod(String id) => '$baseUrl/payment-methods/$id';
  static String paymentMethodDefault(String id) => '$baseUrl/payment-methods/$id/default';


}
