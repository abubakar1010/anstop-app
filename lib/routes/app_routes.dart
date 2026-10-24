import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

// Auth imports
import 'package:ride_sharing/feature/auth/binding/car_information_binding.dart';
import 'package:ride_sharing/feature/auth/binding/driver_registration_binding.dart';
import 'package:ride_sharing/feature/auth/binding/driving_license_binding.dart';
import 'package:ride_sharing/feature/auth/binding/email_validation_binding.dart';
import 'package:ride_sharing/feature/auth/binding/login_binding.dart';
import 'package:ride_sharing/feature/auth/binding/national_id_binding.dart';
import 'package:ride_sharing/feature/auth/binding/otp_verification_binding.dart';
import 'package:ride_sharing/feature/auth/binding/passenger_registration_binding.dart';
import 'package:ride_sharing/feature/auth/binding/reset_password_binding.dart';
import 'package:ride_sharing/feature/auth/binding/upload_documents_binding.dart';
import 'package:ride_sharing/feature/auth/binding/upload_profile_picture_binding.dart';
import 'package:ride_sharing/feature/auth/driver/car_information_screen.dart';
import 'package:ride_sharing/feature/auth/driver/driving_license_screen.dart';
import 'package:ride_sharing/feature/auth/driver/national_id_screen.dart';
import 'package:ride_sharing/feature/auth/driver/registration.dart';
import 'package:ride_sharing/feature/auth/driver/upload_profile_picture.dart';
import 'package:ride_sharing/feature/auth/driver/upload_your_documents_screen.dart';
import 'package:ride_sharing/feature/auth/view/email_validation_screen.dart';
import 'package:ride_sharing/feature/auth/view/log_in_screen.dart';
import 'package:ride_sharing/feature/auth/view/account_status_screen.dart';
import 'package:ride_sharing/feature/auth/view/otp_varification_screen.dart';
import 'package:ride_sharing/feature/auth/view/registration.dart';
import 'package:ride_sharing/feature/auth/view/reset_password_screen.dart';

// Splash & Onboarding imports
import 'package:ride_sharing/feature/splash_screen/binding/auth_selection_binding.dart';
import 'package:ride_sharing/feature/splash_screen/binding/onboarding_binding.dart';
import 'package:ride_sharing/feature/splash_screen/binding/role_selection_binding.dart';
import 'package:ride_sharing/feature/splash_screen/binding/splash_binding.dart';
import 'package:ride_sharing/feature/splash_screen/driver_auth_selection_screen.dart';
import 'package:ride_sharing/feature/splash_screen/onboarding_page_first.dart';
import 'package:ride_sharing/feature/splash_screen/auth_selection_screen.dart';
import 'package:ride_sharing/feature/splash_screen/role_selection_screen.dart';
import 'package:ride_sharing/feature/splash_screen/splash_screen.dart';

// Driver imports
import 'package:ride_sharing/feature/driver/homepage/binding/driver_homescreen_binding.dart';
import 'package:ride_sharing/feature/driver/homepage/view/driver_homescreen.dart';
import 'package:ride_sharing/feature/driver/invoice/binding/invoice_binding.dart';
import 'package:ride_sharing/feature/driver/invoice/view/invoice_view.dart';
import 'package:ride_sharing/feature/driver/my_trip/binding/my_trip_binding.dart';
import 'package:ride_sharing/feature/driver/my_trip/view/my_trip.dart';
import 'package:ride_sharing/feature/driver/my_trip_details/binding/driver_completed_trip_binding.dart';
import 'package:ride_sharing/feature/driver/my_trip_details/binding/driver_ongoing_trip_binding.dart';
import 'package:ride_sharing/feature/driver/my_trip_details/view/driver_completed_trip_details.dart';
import 'package:ride_sharing/feature/driver/my_trip_details/view/driver_ongoing_trip_details.dart';
import 'package:ride_sharing/feature/driver/profile/binding/driver_profile_binding.dart';
import 'package:ride_sharing/feature/driver/profile/binding/edit_driver_profile_binding.dart';
import 'package:ride_sharing/feature/driver/profile/view/driver_profile_view.dart';
import 'package:ride_sharing/feature/driver/profile/view/edit_driver_profile_view.dart';
import 'package:ride_sharing/feature/driver/trip_flow/binding/driver_trip_flow_binding.dart';
import 'package:ride_sharing/feature/driver/trip_flow/view/driver_trip_flow.dart';
import 'package:ride_sharing/feature/driver/wallet/binding/driver_wallet_binding.dart';
import 'package:ride_sharing/feature/driver/wallet/view/driver_wallet_page.dart';

// Shared imports
import 'package:ride_sharing/feature/messages/binding/chat_binding.dart';
import 'package:ride_sharing/feature/messages/binding/message_list_binding.dart';
import 'package:ride_sharing/feature/messages/view/chat_screen.dart';
import 'package:ride_sharing/feature/messages/view/message_list_screen.dart';
import 'package:ride_sharing/feature/notification/binding/notification_binding.dart';
import 'package:ride_sharing/feature/notification/view/notification_screen.dart';
import 'package:ride_sharing/feature/settings/binding/change_password_binding.dart';
import 'package:ride_sharing/feature/settings/binding/legal_pages_binding.dart';
import 'package:ride_sharing/feature/settings/binding/settings_binding.dart';
import 'package:ride_sharing/feature/settings/view/change_language_screen.dart';
import 'package:ride_sharing/feature/settings/view/change_password_screen.dart';
import 'package:ride_sharing/feature/settings/view/legal_pages_screen.dart';
import 'package:ride_sharing/feature/settings/view/settings_screen.dart';

// Support imports
import 'package:ride_sharing/feature/support_page/binding/support_list_binding.dart';
import 'package:ride_sharing/feature/support_page/binding/create_support_binding.dart';
import 'package:ride_sharing/feature/support_page/view/support_list_screen.dart';
import 'package:ride_sharing/feature/support_page/view/create_support_screen.dart';
import 'package:ride_sharing/feature/wallet/binding/add_money_binding.dart';

// Wallet imports
import 'package:ride_sharing/feature/wallet/view/add_money_screen.dart';

// Passenger imports
import 'package:ride_sharing/feature/passenger/car_booking/passenger/binding/cancel_taxi_binding.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/binding/pick_up_location_binding.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/binding/set_on_map_binding.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/cancel_taxi.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/pick_up_location.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/set_on_map_screen.dart';
import 'package:ride_sharing/feature/passenger/homepage/binding/home_binding.dart';
import 'package:ride_sharing/feature/passenger/homepage/view/home_page.dart';
import 'package:ride_sharing/feature/passenger/my_ride/binding/my_ride_binding.dart';
import 'package:ride_sharing/feature/passenger/my_ride/view/my_ride.dart';
import 'package:ride_sharing/feature/passenger/payment/binding/passenger_payment_binding.dart';
import 'package:ride_sharing/feature/passenger/payment/view/passenger_payment_screen.dart';
import 'package:ride_sharing/feature/passenger/set_location/binding/set_location_binding.dart';
import 'package:ride_sharing/feature/passenger/set_location/view/set_location_option_page.dart';
import 'package:ride_sharing/feature/passenger/set_location/view/set_location_screen.dart';
import 'package:ride_sharing/feature/passenger/trip_details/binding/completed_trip_binding.dart';
import 'package:ride_sharing/feature/passenger/trip_details/binding/ongoing_trip_binding.dart';
import 'package:ride_sharing/feature/passenger/trip_details/view/complete_trip_details.dart';
import 'package:ride_sharing/feature/passenger/trip_details/view/ongoing_trip_details.dart';
import 'package:ride_sharing/feature/passenger/wallet/binding/passenger_wallet_binding.dart';
import 'package:ride_sharing/feature/passenger/wallet/view/passenger_wallet_page.dart';

import '../widgets/auth_links/auth_link.dart';

abstract class AppRoutes {
  /// =========== Initial Route ===========
  static const String initialRoutes = splashScreen;

  /// =========== Splash & Onboarding ===========
  static const String splashScreen = '/';
  static const String onboardingScreen = '/onboardingScreen';
  static const String roleSelectionScreen = '/roleSelectionScreen';
  static const String passengerAuthSelectionScreen = '/passengerAuthSelectionScreen';
  static const String driverAuthSelectionScreen = '/driverAuthSelectionScreen';

  /// =========== Authentication ===========
  static const String loginScreen = '/loginScreen';
  static const String accountStatusScreen = '/accountStatusScreen';
  static const String emailValidationScreen = '/emailValidationScreen';
  static const String otpVerificationScreen = '/otpVerificationScreen';
  static const String resetPasswordScreen = '/resetPasswordScreen';
  static const String passengerRegistrationScreen = '/passengerRegistrationScreen';
  static const String driverRegistrationScreen = '/driverRegistrationScreen';
  static const String uploadDocumentsScreen = '/uploadDocumentsScreen';
  static const String nationalIdScreen = '/nationalIdScreen';
  static const String drivingLicenseScreen = '/drivingLicenseScreen';
  static const String carInformationScreen = '/carInformationScreen';
  static const String uploadProfilePictureScreen = '/uploadProfilePictureScreen';

  /// =========== Passenger Home & Booking ===========
  static const String passengerHomeScreen = '/passengerHomeScreen';
  static const String setLocationOptionScreen = '/setLocationOptionScreen';
  static const String setLocationScreen = '/setLocationScreen';
  static const String setOnMapScreen = '/setOnMapScreen';
  static const String pickUpLocationScreen = '/pickUpLocationScreen';
  static const String cancelTaxiScreen = '/cancelTaxiScreen';

  /// =========== Passenger Trip & Payment ===========
  static const String passengerMyRideScreen = '/passengerMyRideScreen';
  static const String passengerOngoingTripScreen = '/passengerOngoingTripScreen';
  static const String passengerCompletedTripScreen = '/passengerCompletedTripScreen';
  static const String passengerPaymentScreen = '/passengerPaymentScreen';
  static const String passengerWalletScreen = '/passengerWalletScreen';

  /// =========== Driver Home & Trips ===========
  static const String driverHomeScreen = '/driverHomeScreen';
  static const String driverProfileScreen = '/driverProfileScreen';
  static const String editDriverProfileScreen = '/editDriverProfileScreen';
  static const String driverMyTripScreen = '/driverMyTripScreen';
  static const String driverOngoingTripScreen = '/driverOngoingTripScreen';
  static const String driverCompletedTripScreen = '/driverCompletedTripScreen';
  static const String driverTripFlowScreen = '/driverTripFlowScreen';
  static const String driverInvoiceScreen = '/driverInvoiceScreen';
  static const String driverWalletScreen = '/driverWalletScreen';

  /// =========== Shared Features ===========
  static const String messageListScreen = '/messageListScreen';
  static const String chatScreen = '/chatScreen';
  static const String notificationScreen = '/notificationScreen';
  static const String settingsScreen = '/settingsScreen';
  static const String changePasswordScreen = '/changePasswordScreen';
  static const String changeLanguageScreen = '/changeLanguageScreen';
  static const String legalPagesScreen = '/legalPagesScreen';
  static const String supportListScreen = '/supportListScreen';
  static const String createSupportScreen = '/createSupportScreen';
  static const String addMoneyScreen = '/addMoneyScreen';

  /// =========== Routes ===========
  static final routes = [
    /// Splash & Onboarding Routes
    GetPage(
      name: splashScreen,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: onboardingScreen,
      page: () => OnboardingPageFirst(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: roleSelectionScreen,
      page: () => RoleSelectionScreen(),
      binding: RoleSelectionBinding(),
    ),
    GetPage(
      name: passengerAuthSelectionScreen,
      page: () => AuthSelectionScreen(),
      binding: AuthSelectionBinding(),
    ),
    GetPage(
      name: driverAuthSelectionScreen,
      page: () => DriverAuthSelectionScreen(),
      binding: AuthSelectionBinding(),
    ),

    /// Authentication Routes
    GetPage(
      name: loginScreen,
      page: () => LogInScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: emailValidationScreen,
      page: () => EmailValidationScreen(),
      binding: EmailValidationBinding(),
    ),
    GetPage(
      name: otpVerificationScreen,
      page: () => OtpVarificationScreen(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: resetPasswordScreen,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: passengerRegistrationScreen,
      page: () => RegistrationScreen(),
      binding: PassengerRegistrationBinding(),
    ),
    GetPage(
      name: driverRegistrationScreen,
      page: () => DriverRegistration(),
      binding: DriverRegistrationBinding(),
    ),
    GetPage(name: accountStatusScreen, page: () => const AccountStatusScreen()),
    GetPage(
      name: uploadDocumentsScreen,
      page: () => UploadYourDocuments(),
      binding: UploadDocumentsBinding(),
    ),
    GetPage(
      name: nationalIdScreen,
      page: () => NationalIdScreen(),
      binding: NationalIdBinding(),
    ),
    GetPage(
      name: drivingLicenseScreen,
      page: () => DrivingLicenseScreen(),
      binding: DrivingLicenseBinding(),
    ),
    GetPage(
      name: carInformationScreen,
      page: () => CarInformationScreen(),
      binding: CarInformationBinding(),
    ),
    GetPage(
      name: uploadProfilePictureScreen,
      page: () => UploadProfilePictureScreen(),
      binding: UploadProfilePictureBinding(),
    ),

    /// Passenger Routes
    GetPage(
      name: passengerHomeScreen,
      page: () => HomePage(),
      binding: HomePageBinding(),
    ),
    GetPage(
      name: setLocationOptionScreen,
      page: () => SetLocationOptionPage(),
      binding: SetLocationBinding(),
    ),
    GetPage(
      name: setLocationScreen,
      page: () => SetLocationScreen(),
      binding: SetLocationBinding(),
    ),
    GetPage(
      name: setOnMapScreen,
      page: () => SetOnMapScreen(),
      binding: SetOnMapBinding(),
    ),
    GetPage(
      name: pickUpLocationScreen,
      page: () => PickUpLocationScreen(),
      binding: PickUpLocationBinding(),
    ),
    GetPage(
      name: cancelTaxiScreen,
      page: () => CancelTaxiScreen(),
      binding: CancelTaxiBinding(),
    ),

    /// Passenger Trip & Payment Routes
    GetPage(
      name: passengerMyRideScreen,
      page: () => MyRidePage(),
      binding: MyRideBinding(),
    ),
    GetPage(
      name: passengerOngoingTripScreen,
      page: () => OngoingTripDetails(rideId: Get.arguments?['rideId'] ?? ''),
      binding: OngoingTripBinding(),
    ),
    GetPage(
      name: passengerCompletedTripScreen,
      page: () => CompletedTripDetails(rideId: Get.arguments?['rideId'] ?? ''),
      binding: CompletedTripBinding(),
    ),
    GetPage(
      name: passengerPaymentScreen,
      page: () => PassengerPaymentScreen(),
      binding: PassengerPaymentBinding(),
    ),
    GetPage(
      name: passengerWalletScreen,
      page: () => PassengerWalletPage(),
      binding: WalletBinding(),
    ),

    /// Driver Routes
    GetPage(
      name: driverHomeScreen,
      page: () => DriverHomeScreen(),
      binding: DriverHomeScreenBinding(),
    ),
    GetPage(
      name: driverProfileScreen,
      page: () => DriverProfileView(),
      binding: DriverProfileBinding(),
    ),
    GetPage(
      name: editDriverProfileScreen,
      page: () => const EditDriverProfileView(),
      binding: EditDriverProfileBinding(),
    ),
    GetPage(
      name: driverMyTripScreen,
      page: () => MyTripPage(),
      binding: MyTripBinding(),
    ),
    GetPage(
      name: driverOngoingTripScreen,
      page: () => DriverOngoingTripDetails(),
      binding: DriverOngoingTripBinding(),
    ),
    GetPage(
      name: driverCompletedTripScreen,
      page: () => DriverCompletedTripDetails(),
      binding: DriverCompletedTripBinding(),
    ),
    GetPage(
      name: driverTripFlowScreen,
      page: () => DriverTripFlow(),
      binding: DriverTripFlowBinding(),
    ),
    GetPage(
      name: driverInvoiceScreen,
      page: () => InvoicePage(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: driverWalletScreen,
      page: () => DriverWalletPage(),
      binding: WalletBinding(),
    ),

    /// Shared Feature Routes
    GetPage(
      name: messageListScreen,
      page: () => MessagesListScreen(),
      binding: MessageListBinding(),
    ),
    GetPage(
      name: chatScreen,
      page: () => ChatScreen(
       // userName: Get.arguments?['userName'] ?? '',
       // userStatus: Get.arguments?['userStatus'] ?? '',
      ),
      binding: ChatBinding(),
    ),
    GetPage(
      name: notificationScreen,
      page: () => NotificationScreen(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: settingsScreen,
      page: () => SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: changePasswordScreen,
      page: () => ChangePasswordScreen(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(name: changeLanguageScreen, page: () => ChangeLanguageScreen()),
    GetPage(
      name: legalPagesScreen,
      page: () => LegalPagesScreen(),
      binding: LegalPagesBinding(),
    ),

    /// Support Routes
    GetPage(
      name: supportListScreen,
      page: () =>  SupportListScreen(),
      binding: SupportListBinding(),
    ),
    GetPage(
      name: createSupportScreen,
      page: () =>  CreateSupportScreen(),
      binding: CreateSupportBinding(),
    ),

    /// Wallet Routes
    GetPage(
      name: addMoneyScreen,
      page: () =>  AddMoneyScreen(),
      binding: WalletBinding(),
    ),
  ];
}
