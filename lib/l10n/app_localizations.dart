import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @splashEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get splashEnglishLabel;

  /// No description provided for @splashFrenchLabel.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get splashFrenchLabel;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Seamless, affordable, and reliable carpooling at your fingertips.'**
  String get splashTagline;

  /// No description provided for @roleWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'WELCOME To Our App'**
  String get roleWelcomeTitle;

  /// No description provided for @roleTagline.
  ///
  /// In en, this message translates to:
  /// **'Seamless, affordable, and reliable ride-sharing at your fingertips.'**
  String get roleTagline;

  /// No description provided for @asPassengerButton.
  ///
  /// In en, this message translates to:
  /// **'As a Passenger'**
  String get asPassengerButton;

  /// No description provided for @driverButton.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverButton;

  /// No description provided for @onboardingWelcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get onboardingWelcomeTo;

  /// No description provided for @onboardingAppName.
  ///
  /// In en, this message translates to:
  /// **'ANSTOP'**
  String get onboardingAppName;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Local, reliable, and affordable carpooling'**
  String get onboardingTagline;

  /// No description provided for @onboardingSafeAndSecure.
  ///
  /// In en, this message translates to:
  /// **'Safe and secure'**
  String get onboardingSafeAndSecure;

  /// No description provided for @onboardingJourneys.
  ///
  /// In en, this message translates to:
  /// **' trips'**
  String get onboardingJourneys;

  /// No description provided for @onboardingSafetyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your safety is our top priority. Every ride is monitored for your peace of mind.'**
  String get onboardingSafetyMessage;

  /// No description provided for @onboardingEasyAndConvenient.
  ///
  /// In en, this message translates to:
  /// **'Easy and Convenient'**
  String get onboardingEasyAndConvenient;

  /// No description provided for @onboardingBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get onboardingBooking;

  /// No description provided for @onboardingBookingMessage.
  ///
  /// In en, this message translates to:
  /// **'Book your ride in just a few taps. Quick, easy, and hassle-free.'**
  String get onboardingBookingMessage;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get started !!'**
  String get getStartedButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @welcomeToOurApp.
  ///
  /// In en, this message translates to:
  /// **'Welcome TO Our App'**
  String get welcomeToOurApp;

  /// No description provided for @driverWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome TO Our App'**
  String get driverWelcomeTitle;

  /// No description provided for @driverAuthTagline.
  ///
  /// In en, this message translates to:
  /// **'Seamless, affordable, and reliable ride-sharing at your fingertips.'**
  String get driverAuthTagline;

  /// No description provided for @passengerWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome TO Our App'**
  String get passengerWelcomeTitle;

  /// No description provided for @passengerAuthTagline.
  ///
  /// In en, this message translates to:
  /// **'Seamless, affordable, and reliable ride-sharing at your fingertips.'**
  String get passengerAuthTagline;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @emailHintText.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHintText;

  /// No description provided for @passwordHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get passwordHintText;

  /// No description provided for @forgetPasswordTextButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password ?'**
  String get forgetPasswordTextButton;

  /// No description provided for @logInButtonText.
  ///
  /// In en, this message translates to:
  /// **'Lets go!!'**
  String get logInButtonText;

  /// No description provided for @noAccountText.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountText;

  /// No description provided for @validationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validationErrorTitle;

  /// No description provided for @validationErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields correctly'**
  String get validationErrorMessage;

  /// No description provided for @emailValidationAppBarText.
  ///
  /// In en, this message translates to:
  /// **'E-mail Varification'**
  String get emailValidationAppBarText;

  /// No description provided for @emailValidationButtonText.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get emailValidationButtonText;

  /// No description provided for @otpAppBarText.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpAppBarText;

  /// No description provided for @otpDidNotGetText.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code?'**
  String get otpDidNotGetText;

  /// No description provided for @resendButtonText.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendButtonText;

  /// No description provided for @otpVarificationButtonText.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVarificationButtonText;

  /// No description provided for @resetPasswordAppBarText.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordAppBarText;

  /// No description provided for @resetPasswordHintText.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordHintText;

  /// No description provided for @resetConfirmPasswordHintText.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get resetConfirmPasswordHintText;

  /// No description provided for @resetPasswordConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get resetPasswordConfirmButton;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill the information to create a new account.'**
  String get createAccountSubtitle;

  /// No description provided for @driverOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your driver profile'**
  String get driverOnboardingTitle;

  /// No description provided for @driverOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a few details to start driving.'**
  String get driverOnboardingSubtitle;

  /// No description provided for @nameHintText.
  ///
  /// In en, this message translates to:
  /// **'Name here'**
  String get nameHintText;

  /// No description provided for @enterEmailHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter E-mail'**
  String get enterEmailHintText;

  /// No description provided for @enterPasswordHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPasswordHintText;

  /// No description provided for @selectBirthdayHint.
  ///
  /// In en, this message translates to:
  /// **'Select Birthday'**
  String get selectBirthdayHint;

  /// No description provided for @selectGenderHint.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGenderHint;

  /// No description provided for @addressHintText.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressHintText;

  /// No description provided for @agreeWithText.
  ///
  /// In en, this message translates to:
  /// **'Agree with '**
  String get agreeWithText;

  /// No description provided for @termsOfServiceLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceLink;

  /// No description provided for @andText.
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get andText;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @haveAccountText.
  ///
  /// In en, this message translates to:
  /// **'Have any account ?'**
  String get haveAccountText;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **' Login'**
  String get loginLink;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @uploadDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your documents'**
  String get uploadDocumentsTitle;

  /// No description provided for @uploadDocumentsMessage1.
  ///
  /// In en, this message translates to:
  /// **'please upload the required documents to complete'**
  String get uploadDocumentsMessage1;

  /// No description provided for @uploadDocumentsMessage2.
  ///
  /// In en, this message translates to:
  /// **'your application process'**
  String get uploadDocumentsMessage2;

  /// No description provided for @nationalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalIdLabel;

  /// No description provided for @drivingLicenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Driving Licence'**
  String get drivingLicenceLabel;

  /// No description provided for @carInformationLabel.
  ///
  /// In en, this message translates to:
  /// **'Car information'**
  String get carInformationLabel;

  /// No description provided for @yourPictureLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Picture'**
  String get yourPictureLabel;

  /// No description provided for @nationalIdTitle.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalIdTitle;

  /// No description provided for @nationalIdNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'National Id number'**
  String get nationalIdNumberLabel;

  /// No description provided for @uploadNationalIdFront.
  ///
  /// In en, this message translates to:
  /// **'Upload your National ID picture (Front)'**
  String get uploadNationalIdFront;

  /// No description provided for @uploadNationalIdBack.
  ///
  /// In en, this message translates to:
  /// **'Upload your National ID picture (Back)'**
  String get uploadNationalIdBack;

  /// No description provided for @drivingLicenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Driving Licence'**
  String get drivingLicenceTitle;

  /// No description provided for @drivingLicenseNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Driving License number'**
  String get drivingLicenseNumberLabel;

  /// No description provided for @uploadDrivingLicenseFront.
  ///
  /// In en, this message translates to:
  /// **'Upload your Driving License picture (Front)'**
  String get uploadDrivingLicenseFront;

  /// No description provided for @uploadDrivingLicenseBack.
  ///
  /// In en, this message translates to:
  /// **'Upload your Driving License picture (Back)'**
  String get uploadDrivingLicenseBack;

  /// No description provided for @carInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Car information'**
  String get carInformationTitle;

  /// No description provided for @carNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Car name'**
  String get carNameLabel;

  /// No description provided for @carModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Car Model'**
  String get carModelLabel;

  /// No description provided for @numberPlateLabel.
  ///
  /// In en, this message translates to:
  /// **'Number plate'**
  String get numberPlateLabel;

  /// No description provided for @uploadCarPictureFront.
  ///
  /// In en, this message translates to:
  /// **'Upload your Registration Certificate (Front)'**
  String get uploadCarPictureFront;

  /// No description provided for @uploadCarPictureBack.
  ///
  /// In en, this message translates to:
  /// **'Upload your Registration Certificate (Back)'**
  String get uploadCarPictureBack;

  /// No description provided for @uploadPictureTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Your Picture'**
  String get uploadPictureTitle;

  /// No description provided for @uploadProfilePictureLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload your picture'**
  String get uploadProfilePictureLabel;

  /// No description provided for @termsOfServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Services'**
  String get termsOfServicesTitle;

  /// No description provided for @ourTermsOfServices.
  ///
  /// In en, this message translates to:
  /// **'Our Terms of Services'**
  String get ourTermsOfServices;

  /// No description provided for @agreeWithTermsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Agree with Terms of Services  &  Privacy Policy '**
  String get agreeWithTermsAndPrivacy;

  /// No description provided for @termsAndConditionText.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet consectetur. Lacus at venenatis gravida vivamus mauris.Quisque mi est vel dis.Donec rhoncus laoreet odio orci sed risus elit accumsan.Mattis ut est tristique amet vitae at aliquet.Ac vel porttitor egestas scelerisque enim quisque senectus.Euismod ultricies vulputate id cras bibendum sollicitudin proin odio bibendum. Velit velit in scelerisque erat etiam rutrum phasellus nunc. Sed lectus sed a at et eget. Nunc purus sed quis at risus. Consectetur nibh justo proin placerat condimentum id at adipiscing.\nVel blandit mi nulla sodales consectetur. Egestas tristique ultrices gravida duis nisl odio. Posuere curabitur eu platea pellentesque ut. Facilisi elementum neque mauris facilisis in. Cursus condimentum ipsum pretium consequat turpis at porttitor nisi.Scelerisque tellus praesent condimentum euismod a faucibus. Auctor at ultricies at\nurna aliquam massa pellentesque. Vitae vulputate nullam diam placerat at magna egestas. Lectus lectus consequat porta lectus purus. Nulla duis sem sit at imperdiet lobortis dui. Nunc tellus cursus maecenas phasellus sollicitudin donec dictum.Sodales in faucibus libero augue vestibulum urna mattis curabitur'**
  String get termsAndConditionText;

  /// No description provided for @whereAreYouHeadedHint.
  ///
  /// In en, this message translates to:
  /// **'Where are you headed?'**
  String get whereAreYouHeadedHint;

  /// No description provided for @setYourLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your location'**
  String get setYourLocationTitle;

  /// No description provided for @searchAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Search address'**
  String get searchAddressHint;

  /// No description provided for @setOnMapOption.
  ///
  /// In en, this message translates to:
  /// **'Set on Map'**
  String get setOnMapOption;

  /// No description provided for @homeOption.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeOption;

  /// No description provided for @workOption.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get workOption;

  /// No description provided for @bookmarksOption.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksOption;

  /// No description provided for @setAddressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set Address'**
  String get setAddressSubtitle;

  /// No description provided for @setLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get setLocationButton;

  /// No description provided for @setOnMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Set on Map'**
  String get setOnMapTitle;

  /// No description provided for @recentPlacesLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent Places'**
  String get recentPlacesLabel;

  /// No description provided for @clearAllButton.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllButton;

  /// No description provided for @coffeeCategory.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get coffeeCategory;

  /// No description provided for @restaurantCategory.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantCategory;

  /// No description provided for @yourPickUpPointLabel.
  ///
  /// In en, this message translates to:
  /// **'Pick-up location'**
  String get yourPickUpPointLabel;

  /// No description provided for @yourDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Your destination'**
  String get yourDestinationLabel;

  /// No description provided for @savedAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved Adress'**
  String get savedAddressLabel;

  /// No description provided for @seeAllLink.
  ///
  /// In en, this message translates to:
  /// **'See all >'**
  String get seeAllLink;

  /// No description provided for @yourTripLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Trip'**
  String get yourTripLabel;

  /// No description provided for @pickupLocationExample.
  ///
  /// In en, this message translates to:
  /// **'Block b / Banasree, Dhaka'**
  String get pickupLocationExample;

  /// No description provided for @dropoffLocationExample.
  ///
  /// In en, this message translates to:
  /// **'Green Road Dhaka'**
  String get dropoffLocationExample;

  /// No description provided for @distanceExample.
  ///
  /// In en, this message translates to:
  /// **'89 km'**
  String get distanceExample;

  /// No description provided for @noteToDriverHint.
  ///
  /// In en, this message translates to:
  /// **'Give a short note to the driver,'**
  String get noteToDriverHint;

  /// No description provided for @priceExample.
  ///
  /// In en, this message translates to:
  /// **'€24'**
  String get priceExample;

  /// No description provided for @distanceExample2.
  ///
  /// In en, this message translates to:
  /// **'28 km'**
  String get distanceExample2;

  /// No description provided for @pickupLocationExample2.
  ///
  /// In en, this message translates to:
  /// **'Block B, Banasree, Dhaka'**
  String get pickupLocationExample2;

  /// No description provided for @dropoffLocationExample2.
  ///
  /// In en, this message translates to:
  /// **'Green Road, Dhaka'**
  String get dropoffLocationExample2;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @distanceValueExample.
  ///
  /// In en, this message translates to:
  /// **'29 km'**
  String get distanceValueExample;

  /// No description provided for @payViaWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay via wallet'**
  String get payViaWalletLabel;

  /// No description provided for @cancelRideQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel this ride?'**
  String get cancelRideQuestion;

  /// No description provided for @previousPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous Price'**
  String get previousPriceLabel;

  /// No description provided for @previousPriceExample.
  ///
  /// In en, this message translates to:
  /// **'€20'**
  String get previousPriceExample;

  /// No description provided for @carNumberExample.
  ///
  /// In en, this message translates to:
  /// **'DHK METRO - 8475Dkk'**
  String get carNumberExample;

  /// No description provided for @carBrandExample.
  ///
  /// In en, this message translates to:
  /// **'Toyota'**
  String get carBrandExample;

  /// No description provided for @destinationExample.
  ///
  /// In en, this message translates to:
  /// **'Green Road, Dhaka'**
  String get destinationExample;

  /// No description provided for @distanceExample3.
  ///
  /// In en, this message translates to:
  /// **'5.9 km'**
  String get distanceExample3;

  /// No description provided for @tripIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip Id'**
  String get tripIdLabel;

  /// No description provided for @tripIdExample.
  ///
  /// In en, this message translates to:
  /// **'#GD25G'**
  String get tripIdExample;

  /// No description provided for @cancelTaxiTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Taxi'**
  String get cancelTaxiTitle;

  /// No description provided for @cancellationReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter cancellation reason...'**
  String get cancellationReasonHint;

  /// No description provided for @anotherCancellationReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter another cancellation reason...'**
  String get anotherCancellationReasonHint;

  /// No description provided for @durationExample.
  ///
  /// In en, this message translates to:
  /// **'90 min'**
  String get durationExample;

  /// No description provided for @fareExample.
  ///
  /// In en, this message translates to:
  /// **'€26.00'**
  String get fareExample;

  /// No description provided for @confirmPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPaymentTitle;

  /// No description provided for @writeCommentsHint.
  ///
  /// In en, this message translates to:
  /// **'Write your comments...'**
  String get writeCommentsHint;

  /// No description provided for @backToHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHomeButton;

  /// No description provided for @viewDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetailsButton;

  /// No description provided for @tripDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetailsTitle;

  /// No description provided for @mapImageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Map image not available'**
  String get mapImageNotAvailable;

  /// No description provided for @passengerNameExample.
  ///
  /// In en, this message translates to:
  /// **'Siam'**
  String get passengerNameExample;

  /// No description provided for @dateExample.
  ///
  /// In en, this message translates to:
  /// **'26th December'**
  String get dateExample;

  /// No description provided for @ongoingStatus.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoingStatus;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// No description provided for @timeExample.
  ///
  /// In en, this message translates to:
  /// **'9:00 pm'**
  String get timeExample;

  /// No description provided for @rideValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Ride value'**
  String get rideValueLabel;

  /// No description provided for @fareExample2.
  ///
  /// In en, this message translates to:
  /// **'€ 25.69'**
  String get fareExample2;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @transactionNameExample1.
  ///
  /// In en, this message translates to:
  /// **'Welton'**
  String get transactionNameExample1;

  /// No description provided for @transactionTypeExample.
  ///
  /// In en, this message translates to:
  /// **'Add in Wallet'**
  String get transactionTypeExample;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @genderHintText.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderHintText;

  /// No description provided for @driverNameExample.
  ///
  /// In en, this message translates to:
  /// **'Siam'**
  String get driverNameExample;

  /// No description provided for @viewMediaOption.
  ///
  /// In en, this message translates to:
  /// **'View media'**
  String get viewMediaOption;

  /// No description provided for @reportOption.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportOption;

  /// No description provided for @blockOption.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockOption;

  /// No description provided for @typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessageHint;

  /// No description provided for @searchByNameHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByNameHint;

  /// No description provided for @reportHateSpeech.
  ///
  /// In en, this message translates to:
  /// **'Hate Speech'**
  String get reportHateSpeech;

  /// No description provided for @reportThreat.
  ///
  /// In en, this message translates to:
  /// **'Threat'**
  String get reportThreat;

  /// No description provided for @reportHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reportHarassment;

  /// No description provided for @reportPretending.
  ///
  /// In en, this message translates to:
  /// **'Pretending to be something'**
  String get reportPretending;

  /// No description provided for @reportFraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud Or Scam'**
  String get reportFraud;

  /// No description provided for @reportFakeIdentity.
  ///
  /// In en, this message translates to:
  /// **'Fake Identity'**
  String get reportFakeIdentity;

  /// No description provided for @reportSomethingElse.
  ///
  /// In en, this message translates to:
  /// **'Something Else'**
  String get reportSomethingElse;

  /// No description provided for @reportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportOther;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find Support or Report User'**
  String get reportSubtitle;

  /// No description provided for @reportHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'Help us understanding what\'s happening'**
  String get reportHelpMessage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @describeComplainLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe your Complain'**
  String get describeComplainLabel;

  /// No description provided for @hateSpeechDescription.
  ///
  /// In en, this message translates to:
  /// **'Hate speech involves harmful communication that originates hate (sex, religion, or gender). It harms diverse discrimination, and violence. Combating hate speech requires a balance between free expression and public safety.'**
  String get hateSpeechDescription;

  /// No description provided for @reportSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Submitted'**
  String get reportSubmittedTitle;

  /// No description provided for @reportSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your report. We will review it shortly.'**
  String get reportSubmittedMessage;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @blockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockTitle;

  /// No description provided for @blockConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure want to block'**
  String get blockConfirmMessage;

  /// No description provided for @blockConfirmMessageSuffix.
  ///
  /// In en, this message translates to:
  /// **'right now ?'**
  String get blockConfirmMessageSuffix;

  /// No description provided for @noButton.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noButton;

  /// No description provided for @yesButton.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @logoLabel.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get logoLabel;

  /// No description provided for @changePasswordOption.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordOption;

  /// No description provided for @aboutUsOption.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUsOption;

  /// No description provided for @privacyPolicyOption.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyOption;

  /// No description provided for @termsOfServiceOption.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfServiceOption;

  /// No description provided for @changeLanguageOption.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguageOption;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountButton;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @enterOldPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter old Password'**
  String get enterOldPasswordHint;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @enterNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new Password'**
  String get enterNewPasswordHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @reenterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter Password'**
  String get reenterPasswordHint;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @frenchLanguage.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get frenchLanguage;

  /// No description provided for @changeLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguageTitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sure delete your account?'**
  String get deleteAccountMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @yesDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get yesDeleteButton;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutTitle;

  /// No description provided for @logOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sure Logout?'**
  String get logOutMessage;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationTitle;

  /// No description provided for @notificationPaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successfully!'**
  String get notificationPaymentSuccess;

  /// No description provided for @notificationSpecialDiscount30.
  ///
  /// In en, this message translates to:
  /// **'30% Special Discount!'**
  String get notificationSpecialDiscount30;

  /// No description provided for @notificationCreditCardAdded.
  ///
  /// In en, this message translates to:
  /// **'Credit Card added!'**
  String get notificationCreditCardAdded;

  /// No description provided for @notificationWalletAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added Money wallet Successfully!'**
  String get notificationWalletAddedSuccess;

  /// No description provided for @notificationSpecialDiscount5.
  ///
  /// In en, this message translates to:
  /// **'5% Special Discount!'**
  String get notificationSpecialDiscount5;

  /// No description provided for @notificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet consectetur. Ultricies tincidunt alefend vitae'**
  String get notificationDescription;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @supportVehicleNotClean.
  ///
  /// In en, this message translates to:
  /// **'Vehicle not clean'**
  String get supportVehicleNotClean;

  /// No description provided for @supportVehicleTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Vehicle too small'**
  String get supportVehicleTooSmall;

  /// No description provided for @supportDriverRude.
  ///
  /// In en, this message translates to:
  /// **'Driver was rude'**
  String get supportDriverRude;

  /// No description provided for @supportDriverExtraMoney.
  ///
  /// In en, this message translates to:
  /// **'Driver requested extra money'**
  String get supportDriverExtraMoney;

  /// No description provided for @supportDriverLongRoute.
  ///
  /// In en, this message translates to:
  /// **'Driver took a long route'**
  String get supportDriverLongRoute;

  /// No description provided for @supportVehicleACNotWorking.
  ///
  /// In en, this message translates to:
  /// **'Vehicle AC not working'**
  String get supportVehicleACNotWorking;

  /// No description provided for @supportOtherIssue.
  ///
  /// In en, this message translates to:
  /// **'Other issue'**
  String get supportOtherIssue;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportMessage1.
  ///
  /// In en, this message translates to:
  /// **'If you have any kind of problem'**
  String get supportMessage1;

  /// No description provided for @supportMessage2.
  ///
  /// In en, this message translates to:
  /// **'Feel free to contact us'**
  String get supportMessage2;

  /// No description provided for @writeComplaintHint.
  ///
  /// In en, this message translates to:
  /// **'Write your complaint...'**
  String get writeComplaintHint;

  /// No description provided for @sendToAdminButton.
  ///
  /// In en, this message translates to:
  /// **'Send To Admin'**
  String get sendToAdminButton;

  /// No description provided for @submittedSuccessfullyTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted Successfully'**
  String get submittedSuccessfullyTitle;

  /// No description provided for @complaintSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your complaint has been submitted.\nWe will take action shortly.'**
  String get complaintSubmittedMessage;

  /// No description provided for @aboutUsTitle.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUsTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfServiceTitle;

  /// No description provided for @notificationMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationMenuItem;

  /// No description provided for @supportMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportMenuItem;

  /// No description provided for @logoutMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutMenuItem;

  /// No description provided for @myTripsMenuItem.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTripsMenuItem;

  /// No description provided for @myEarningsMenuItem.
  ///
  /// In en, this message translates to:
  /// **'My earnings'**
  String get myEarningsMenuItem;

  /// No description provided for @inviteAndEarnsMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Invite and earns'**
  String get inviteAndEarnsMenuItem;

  /// No description provided for @switchToPassengerButton.
  ///
  /// In en, this message translates to:
  /// **'Switch to Passenger'**
  String get switchToPassengerButton;

  /// No description provided for @myRideMenuItem.
  ///
  /// In en, this message translates to:
  /// **'My Ride'**
  String get myRideMenuItem;

  /// No description provided for @walletMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletMenuItem;

  /// No description provided for @settingsMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsMenuItem;

  /// No description provided for @switchToDriverButton.
  ///
  /// In en, this message translates to:
  /// **'Switch to drive'**
  String get switchToDriverButton;

  /// No description provided for @exampleUserName.
  ///
  /// In en, this message translates to:
  /// **'Naima Jahan'**
  String get exampleUserName;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @enterPhoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumberHint;

  /// No description provided for @oopsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get oopsErrorTitle;

  /// No description provided for @noInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'There was some problem, Check your connection and try again'**
  String get noInternetMessage;

  /// No description provided for @noInternetConnectionLabel.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnectionLabel;

  /// No description provided for @goToProfileLink.
  ///
  /// In en, this message translates to:
  /// **'Go to profile '**
  String get goToProfileLink;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItemTitle;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @yourLocationMarker.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocationMarker;

  /// No description provided for @confirmHomeAddress.
  ///
  /// In en, this message translates to:
  /// **'Confirm Home Address'**
  String get confirmHomeAddress;

  /// No description provided for @confirmWorkAddress.
  ///
  /// In en, this message translates to:
  /// **'Confirm Work Address'**
  String get confirmWorkAddress;

  /// No description provided for @confirmBookmark.
  ///
  /// In en, this message translates to:
  /// **'Confirm Bookmark'**
  String get confirmBookmark;

  /// No description provided for @driverYouAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get driverYouAreOffline;

  /// No description provided for @driverYouAreOnline.
  ///
  /// In en, this message translates to:
  /// **'You are online'**
  String get driverYouAreOnline;

  /// No description provided for @driverGoOnlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Go online to get trips and earn money.'**
  String get driverGoOnlineMessage;

  /// No description provided for @driverGoOnlineButton.
  ///
  /// In en, this message translates to:
  /// **'Go\nOnline'**
  String get driverGoOnlineButton;

  /// No description provided for @driverGoOfflineButton.
  ///
  /// In en, this message translates to:
  /// **'Go Offline'**
  String get driverGoOfflineButton;

  /// No description provided for @driverGoOnline.
  ///
  /// In en, this message translates to:
  /// **'Go Online'**
  String get driverGoOnline;

  /// No description provided for @driverOnTheWayToPickUp.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way to pick up'**
  String get driverOnTheWayToPickUp;

  /// No description provided for @yourTrip.
  ///
  /// In en, this message translates to:
  /// **'Your Trip'**
  String get yourTrip;

  /// No description provided for @driverHasArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has been arrived'**
  String get driverHasArrived;

  /// No description provided for @letsRide.
  ///
  /// In en, this message translates to:
  /// **'Lets Ride'**
  String get letsRide;

  /// No description provided for @yourRideHasBegun.
  ///
  /// In en, this message translates to:
  /// **'Your Ride has begun'**
  String get yourRideHasBegun;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupLocation;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @findingNearbyDrivers.
  ///
  /// In en, this message translates to:
  /// **'Finding nearby drivers...'**
  String get findingNearbyDrivers;

  /// No description provided for @noDriversAvailable.
  ///
  /// In en, this message translates to:
  /// **'No drivers available nearby'**
  String get noDriversAvailable;

  /// No description provided for @acceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButton;

  /// No description provided for @bidSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Bid Submitted'**
  String get bidSubmitted;

  /// No description provided for @bidSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Your bid of {amount} has been sent'**
  String bidSentMessage(String amount);

  /// No description provided for @invalidBid.
  ///
  /// In en, this message translates to:
  /// **'Invalid Bid'**
  String get invalidBid;

  /// No description provided for @enterValidBidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid bid amount'**
  String get enterValidBidAmount;

  /// No description provided for @fareLabel.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fareLabel;

  /// No description provided for @pickUp.
  ///
  /// In en, this message translates to:
  /// **'Pick up'**
  String get pickUp;

  /// No description provided for @dropOff.
  ///
  /// In en, this message translates to:
  /// **'Drop Off'**
  String get dropOff;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @rideRequirements.
  ///
  /// In en, this message translates to:
  /// **'Ride Requirements'**
  String get rideRequirements;

  /// No description provided for @passengersNote.
  ///
  /// In en, this message translates to:
  /// **'Passenger\'s Note'**
  String get passengersNote;

  /// No description provided for @putYourOfferPrice.
  ///
  /// In en, this message translates to:
  /// **'Put your offer price'**
  String get putYourOfferPrice;

  /// No description provided for @bidButton.
  ///
  /// In en, this message translates to:
  /// **'Bid'**
  String get bidButton;

  /// No description provided for @goToMap.
  ///
  /// In en, this message translates to:
  /// **'Go to map'**
  String get goToMap;

  /// No description provided for @confirmPickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pickup'**
  String get confirmPickup;

  /// No description provided for @acceptOffer.
  ///
  /// In en, this message translates to:
  /// **'Accept Offer'**
  String get acceptOffer;

  /// No description provided for @dropOffButton.
  ///
  /// In en, this message translates to:
  /// **'Drop Off'**
  String get dropOffButton;

  /// No description provided for @accountInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Not Active'**
  String get accountInactiveTitle;

  /// No description provided for @accountInactiveMessage.
  ///
  /// In en, this message translates to:
  /// **'You cannot use the app as a driver. Please wait for admin approval.'**
  String get accountInactiveMessage;

  /// No description provided for @accountInactiveButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get accountInactiveButton;

  /// No description provided for @deleteAccountScheduledTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Deletion Requested'**
  String get deleteAccountScheduledTitle;

  /// No description provided for @deleteAccountScheduledMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted within 7 days.'**
  String get deleteAccountScheduledMessage;

  /// No description provided for @dropOffNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop-off Notice'**
  String get dropOffNoticeTitle;

  /// No description provided for @dropOffNoticeMessage.
  ///
  /// In en, this message translates to:
  /// **'The driver may drop you off within a 500m radius near your destination. Do you accept this?'**
  String get dropOffNoticeMessage;

  /// No description provided for @dropOffNoticeNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get dropOffNoticeNo;

  /// No description provided for @dropOffNoticeYesAccept.
  ///
  /// In en, this message translates to:
  /// **'Yes, Accept'**
  String get dropOffNoticeYesAccept;

  /// No description provided for @locationServiceOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off'**
  String get locationServiceOffTitle;

  /// No description provided for @locationServiceOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services so we can show your real-time position on the map.'**
  String get locationServiceOffMessage;

  /// No description provided for @locationPermissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequiredTitle;

  /// No description provided for @locationPermissionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'We need your location to show where you are and to find drivers near you.'**
  String get locationPermissionRequiredMessage;

  /// No description provided for @locationPermissionDeniedForeverMessage.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please enable it in the app settings.'**
  String get locationPermissionDeniedForeverMessage;

  /// No description provided for @openSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsButton;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTitle;

  /// No description provided for @uploadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get uploadFailedTitle;

  /// No description provided for @loginFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailedTitle;

  /// No description provided for @verificationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequiredTitle;

  /// No description provided for @otpSentTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP Sent'**
  String get otpSentTitle;

  /// No description provided for @paymentConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed'**
  String get paymentConfirmedTitle;

  /// No description provided for @tripAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Accepted'**
  String get tripAcceptedTitle;

  /// No description provided for @arrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrivedTitle;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpiredMessage;

  /// No description provided for @pleaseLoginToContinueMessage.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue'**
  String get pleaseLoginToContinueMessage;

  /// No description provided for @invalidServerResponseMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server. Please try again.'**
  String get invalidServerResponseMessage;

  /// No description provided for @verifyEmailToContinueMessage.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email to continue'**
  String get verifyEmailToContinueMessage;

  /// No description provided for @emailNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Email not found. Please try again.'**
  String get emailNotFoundMessage;

  /// No description provided for @emailVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedMessage;

  /// No description provided for @otpResentMessage.
  ///
  /// In en, this message translates to:
  /// **'A new OTP has been sent to your email.'**
  String get otpResentMessage;

  /// No description provided for @pleaseEnterOtpMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get pleaseEnterOtpMessage;

  /// No description provided for @invalidOtpMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid 6-digit OTP'**
  String get invalidOtpMessage;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. Please log in.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @pleaseAgreeToTermsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please agree to terms and conditions'**
  String get pleaseAgreeToTermsMessage;

  /// No description provided for @driverOnboardingSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver onboarding completed successfully!'**
  String get driverOnboardingSuccessMessage;

  /// No description provided for @emailRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequiredError;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmailError;

  /// No description provided for @passwordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequiredError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShortError;

  /// No description provided for @confirmPasswordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordRequiredError;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatchError;

  /// No description provided for @phoneRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequiredError;

  /// No description provided for @invalidPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get invalidPhoneError;

  /// No description provided for @firstNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequiredError;

  /// No description provided for @lastNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequiredError;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequiredError;

  /// No description provided for @addressRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequiredError;

  /// No description provided for @dateOfBirthRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get dateOfBirthRequiredError;

  /// No description provided for @currentPasswordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequiredError;

  /// No description provided for @newPasswordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequiredError;

  /// No description provided for @newPasswordMustDifferError.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get newPasswordMustDifferError;

  /// No description provided for @subjectRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Subject is required'**
  String get subjectRequiredError;

  /// No description provided for @messageRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Message is required'**
  String get messageRequiredError;

  /// No description provided for @amountRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequiredError;

  /// No description provided for @invalidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmountError;

  /// No description provided for @carNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Car name is required'**
  String get carNameRequiredError;

  /// No description provided for @carModelRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Car model is required'**
  String get carModelRequiredError;

  /// No description provided for @numberPlateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Number plate is required'**
  String get numberPlateRequiredError;

  /// No description provided for @registrationCertNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Registration certificate number is required'**
  String get registrationCertNumberRequiredError;

  /// No description provided for @carNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Car number is required'**
  String get carNumberRequiredError;

  /// No description provided for @carColorRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Car color is required'**
  String get carColorRequiredError;

  /// No description provided for @yearOfManufactureRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Year of manufacture is required'**
  String get yearOfManufactureRequiredError;

  /// No description provided for @invalidYearOfManufactureError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid year of manufacture'**
  String get invalidYearOfManufactureError;

  /// No description provided for @carImagesUploadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait until the car images finish uploading'**
  String get carImagesUploadingMessage;

  /// No description provided for @uploadLicensePlateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please upload license plate picture'**
  String get uploadLicensePlateRequiredMessage;

  /// No description provided for @uploadRegistrationCertBothSidesMessage.
  ///
  /// In en, this message translates to:
  /// **'Please upload both front and back of Registration Certificate'**
  String get uploadRegistrationCertBothSidesMessage;

  /// No description provided for @drivingLicenseNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Driving license number is required'**
  String get drivingLicenseNumberRequiredError;

  /// No description provided for @drivingLicenseImagesUploadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait until the Driving License images finish uploading'**
  String get drivingLicenseImagesUploadingMessage;

  /// No description provided for @uploadDrivingLicenseBothSidesMessage.
  ///
  /// In en, this message translates to:
  /// **'Please upload both front and back of Driving License'**
  String get uploadDrivingLicenseBothSidesMessage;

  /// No description provided for @nationalIdNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'National ID number is required'**
  String get nationalIdNumberRequiredError;

  /// No description provided for @nationalIdImagesUploadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait until the National ID images finish uploading'**
  String get nationalIdImagesUploadingMessage;

  /// No description provided for @uploadNationalIdBothSidesMessage.
  ///
  /// In en, this message translates to:
  /// **'Please upload both front and back of National ID'**
  String get uploadNationalIdBothSidesMessage;

  /// No description provided for @profilePictureUploadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait until your picture finishes uploading'**
  String get profilePictureUploadingMessage;

  /// No description provided for @uploadProfilePictureRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please upload profile picture'**
  String get uploadProfilePictureRequiredMessage;

  /// No description provided for @imageUrlMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to get image URL from response'**
  String get imageUrlMissingMessage;

  /// No description provided for @imagePickFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get imagePickFailedMessage;

  /// No description provided for @imageUploadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get imageUploadFailedMessage;

  /// No description provided for @navigateToPassengerMessage.
  ///
  /// In en, this message translates to:
  /// **'Navigate to passenger location'**
  String get navigateToPassengerMessage;

  /// No description provided for @passengerNotifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Passenger has been notified'**
  String get passengerNotifiedMessage;

  /// No description provided for @passengerCompletedPaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'The passenger has completed the payment'**
  String get passengerCompletedPaymentMessage;

  /// No description provided for @noChangesToSaveMessage.
  ///
  /// In en, this message translates to:
  /// **'No changes to save'**
  String get noChangesToSaveMessage;

  /// No description provided for @tripDetailsLoadErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading trip details'**
  String get tripDetailsLoadErrorMessage;

  /// No description provided for @receiptDownloadedMessage.
  ///
  /// In en, this message translates to:
  /// **'Receipt downloaded successfully'**
  String get receiptDownloadedMessage;

  /// No description provided for @pdfGeneratedMessage.
  ///
  /// In en, this message translates to:
  /// **'PDF generated successfully'**
  String get pdfGeneratedMessage;

  /// No description provided for @invoiceDownloadedMessage.
  ///
  /// In en, this message translates to:
  /// **'Invoice downloaded successfully'**
  String get invoiceDownloadedMessage;

  /// No description provided for @pleaseEnterAddressMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address'**
  String get pleaseEnterAddressMessage;

  /// No description provided for @pleaseSelectAddressMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select an address from the suggestions'**
  String get pleaseSelectAddressMessage;

  /// No description provided for @addressSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully'**
  String get addressSavedMessage;

  /// No description provided for @selectPickupAndDestinationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select both pickup and destination locations'**
  String get selectPickupAndDestinationMessage;

  /// No description provided for @paymentCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment completed successfully'**
  String get paymentCompletedMessage;

  /// No description provided for @fundsAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Funds added successfully'**
  String get fundsAddedMessage;

  /// No description provided for @depositCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deposit completed successfully'**
  String get depositCompletedMessage;

  /// No description provided for @withdrawalSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal successful'**
  String get withdrawalSuccessMessage;

  /// No description provided for @messageSendFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get messageSendFailedMessage;

  /// No description provided for @notificationsClearedMessage.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get notificationsClearedMessage;

  /// No description provided for @thankYouForFeedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedbackMessage;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericErrorMessage;

  /// No description provided for @networkErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get networkErrorMessage;

  /// No description provided for @invalidYearRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a year between 1900 and {maxYear}'**
  String invalidYearRangeError(String maxYear);

  /// No description provided for @onboardingFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Onboarding Failed'**
  String get onboardingFailedTitle;

  /// No description provided for @resetFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Failed'**
  String get resetFailedTitle;

  /// No description provided for @registrationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed'**
  String get registrationFailedTitle;

  /// No description provided for @verificationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get verificationFailedTitle;

  /// No description provided for @invalidCredentialsMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentialsMessage;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @supportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get supportStatusInProgress;

  /// No description provided for @supportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get supportStatusResolved;

  /// No description provided for @supportStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get supportStatusClosed;

  /// No description provided for @supportLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load support messages'**
  String get supportLoadFailedMessage;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @uploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadButton;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @mediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaTitle;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @childrenLabel.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get childrenLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @detailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @pickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickupLabel;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @withdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawButton;

  /// No description provided for @youMarkerLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youMarkerLabel;

  /// No description provided for @editProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileButton;

  /// No description provided for @noTransactionsMessage.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsMessage;

  /// No description provided for @withdrawRequestSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Req. Successful'**
  String get withdrawRequestSuccessTitle;

  /// No description provided for @goToMyWalletButton.
  ///
  /// In en, this message translates to:
  /// **'Go To My Wallet'**
  String get goToMyWalletButton;

  /// No description provided for @availableBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalanceLabel;

  /// No description provided for @addMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoneyTitle;

  /// No description provided for @enterAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmountLabel;

  /// No description provided for @withdrawRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Request'**
  String get withdrawRequestTitle;

  /// No description provided for @bankNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankNameLabel;

  /// No description provided for @accountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumberLabel;

  /// No description provided for @enterAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmountHint;

  /// No description provided for @enterBankNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter bank name'**
  String get enterBankNameHint;

  /// No description provided for @enterAccountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter account number'**
  String get enterAccountNumberHint;

  /// No description provided for @yearOfManufactureLabel.
  ///
  /// In en, this message translates to:
  /// **'Year of Manufacture'**
  String get yearOfManufactureLabel;

  /// No description provided for @uploadLicensePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload License Plate Picture'**
  String get uploadLicensePlateLabel;

  /// No description provided for @registrationCertNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration Certificate Number'**
  String get registrationCertNumberLabel;

  /// No description provided for @uploadingButton.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploadingButton;

  /// No description provided for @submittingButton.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submittingButton;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @selectImageSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSourceTitle;

  /// No description provided for @chooseFromGalleryOption.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGalleryOption;

  /// No description provided for @takeAPhotoOption.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhotoOption;

  /// No description provided for @selectPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhotoTitle;

  /// No description provided for @cameraOption.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraOption;

  /// No description provided for @galleryOption.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryOption;

  /// No description provided for @iAgreeWithLabel.
  ///
  /// In en, this message translates to:
  /// **'I agree with'**
  String get iAgreeWithLabel;

  /// No description provided for @privacyPolicyInlineLabel.
  ///
  /// In en, this message translates to:
  /// **'privacy policy.'**
  String get privacyPolicyInlineLabel;

  /// No description provided for @serverErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverErrorTitle;

  /// No description provided for @serverUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The server is not working. Please try again later.'**
  String get serverUnavailableMessage;

  /// No description provided for @paymentErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Error'**
  String get paymentErrorTitle;

  /// No description provided for @paymentSuccessfulTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessfulTitle;

  /// No description provided for @paymentUnexpectedErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during payment'**
  String get paymentUnexpectedErrorMessage;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequiredTitle;

  /// No description provided for @switchToDriverModeMessage.
  ///
  /// In en, this message translates to:
  /// **'Please log out and log in again to switch to driver mode.'**
  String get switchToDriverModeMessage;

  /// No description provided for @goToLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLoginButton;

  /// No description provided for @rideAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride Accepted!'**
  String get rideAcceptedTitle;

  /// No description provided for @navigateToPickupMessage.
  ///
  /// In en, this message translates to:
  /// **'Navigate to pickup location'**
  String get navigateToPickupMessage;

  /// No description provided for @onATripLabel.
  ///
  /// In en, this message translates to:
  /// **'You are on a trip'**
  String get onATripLabel;

  /// No description provided for @didYouReceivePaymentQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did you receive the payment for this trip?'**
  String get didYouReceivePaymentQuestion;

  /// No description provided for @paymentReceivedYesButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, payment received'**
  String get paymentReceivedYesButton;

  /// No description provided for @keepOnlineLine1.
  ///
  /// In en, this message translates to:
  /// **'Keep online,'**
  String get keepOnlineLine1;

  /// No description provided for @keepOnlineLine2.
  ///
  /// In en, this message translates to:
  /// **'watch your earnings climb!'**
  String get keepOnlineLine2;

  /// No description provided for @stayOnlineButton.
  ///
  /// In en, this message translates to:
  /// **'Stay online'**
  String get stayOnlineButton;

  /// No description provided for @selectCancellationReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Please select the reason for cancellation'**
  String get selectCancellationReasonLabel;

  /// No description provided for @sorryForCancellationMessage.
  ///
  /// In en, this message translates to:
  /// **'We are sorry to see your cancellation trip!'**
  String get sorryForCancellationMessage;

  /// No description provided for @cancelNowButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Now'**
  String get cancelNowButton;

  /// No description provided for @selectCarBookForLabel.
  ///
  /// In en, this message translates to:
  /// **'Select the car book for..'**
  String get selectCarBookForLabel;

  /// No description provided for @friendPhoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Friend phone no.'**
  String get friendPhoneNumberHint;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodLabel;

  /// No description provided for @addedImportantThingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Added Important Things'**
  String get addedImportantThingsLabel;

  /// No description provided for @findCarButton.
  ///
  /// In en, this message translates to:
  /// **'Find Car'**
  String get findCarButton;

  /// No description provided for @findingNearbyCarsLabel.
  ///
  /// In en, this message translates to:
  /// **'Finding nearby cars..'**
  String get findingNearbyCarsLabel;

  /// No description provided for @rideRequestSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We have sent your ride request to the nearby drivers'**
  String get rideRequestSentMessage;

  /// No description provided for @noRidesFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No rides found'**
  String get noRidesFoundMessage;

  /// No description provided for @giveYourRatingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Give your ratings'**
  String get giveYourRatingsLabel;

  /// No description provided for @thankYouFeedbackAndTipMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your valuable feedback and tip!'**
  String get thankYouFeedbackAndTipMessage;

  /// No description provided for @complaintSubmittedMessage2.
  ///
  /// In en, this message translates to:
  /// **'Your complaint has been submitted. We will review and get back to you soon.'**
  String get complaintSubmittedMessage2;

  /// No description provided for @backToSupportButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Support'**
  String get backToSupportButton;

  /// No description provided for @enterSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Enter subject'**
  String get enterSubjectHint;

  /// No description provided for @noSupportMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'No support messages yet'**
  String get noSupportMessagesTitle;

  /// No description provided for @createSupportPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to create a new support request'**
  String get createSupportPromptMessage;

  /// No description provided for @addSupportButton.
  ///
  /// In en, this message translates to:
  /// **'Add Support'**
  String get addSupportButton;

  /// No description provided for @noMessagesYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.\nStart a conversation!'**
  String get noMessagesYetMessage;

  /// No description provided for @beginningOfConversationLabel.
  ///
  /// In en, this message translates to:
  /// **'Beginning of conversation'**
  String get beginningOfConversationLabel;

  /// No description provided for @andConjunction.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andConjunction;

  /// No description provided for @withdrawConfirmQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to withdraw\nnow?'**
  String get withdrawConfirmQuestion;

  /// No description provided for @withdrawRequestSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Withdraw request has been sent successfully.\nYou will get the money within 24 hours.'**
  String get withdrawRequestSuccessMessage;

  /// No description provided for @paymentNotReceivedButton.
  ///
  /// In en, this message translates to:
  /// **'No, or received\ndifferent amount'**
  String get paymentNotReceivedButton;

  /// No description provided for @tripCompletedCongratsMessage.
  ///
  /// In en, this message translates to:
  /// **'Congratulations, you\'ve completed another trip.'**
  String get tripCompletedCongratsMessage;

  /// No description provided for @stayConnectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss out: stay connected, grab more\ntrips, and watch your earnings soar!'**
  String get stayConnectedMessage;

  /// No description provided for @iWillPickYouUpLabel.
  ///
  /// In en, this message translates to:
  /// **'I will pick you up'**
  String get iWillPickYouUpLabel;

  /// No description provided for @withdrawNowButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Now'**
  String get withdrawNowButton;

  /// No description provided for @depositButton.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositButton;

  /// No description provided for @todayAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAtLabel(String time);

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @nowLabel.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowLabel;

  /// No description provided for @professionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professionalLabel;

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverLabel;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @arrivingAtDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Arriving at destination'**
  String get arrivingAtDestinationLabel;

  /// No description provided for @currentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocationLabel;

  /// No description provided for @destinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destinationLabel;

  /// No description provided for @paymentMethodWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get paymentMethodWallet;

  /// No description provided for @paymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'By card'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @payViaLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay via {method}'**
  String payViaLabel(String method);

  /// No description provided for @durationMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutesLabel(String minutes);

  /// No description provided for @rideNeedWheelchair.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair Accessible'**
  String get rideNeedWheelchair;

  /// No description provided for @rideNeedExtraLuggage.
  ///
  /// In en, this message translates to:
  /// **'Extra Luggage Space'**
  String get rideNeedExtraLuggage;

  /// No description provided for @rideNeedPetFriendly.
  ///
  /// In en, this message translates to:
  /// **'Pet Friendly'**
  String get rideNeedPetFriendly;

  /// No description provided for @rideNeedChildSeat.
  ///
  /// In en, this message translates to:
  /// **'Child Seat'**
  String get rideNeedChildSeat;

  /// No description provided for @selectRideNeedsHint.
  ///
  /// In en, this message translates to:
  /// **'Select ride needs'**
  String get selectRideNeedsHint;

  /// No description provided for @bookForMyselfOption.
  ///
  /// In en, this message translates to:
  /// **'Book for myself'**
  String get bookForMyselfOption;

  /// No description provided for @bookForFriendOption.
  ///
  /// In en, this message translates to:
  /// **'Book for my friend'**
  String get bookForFriendOption;

  /// No description provided for @cancelReasonDriverTooLong.
  ///
  /// In en, this message translates to:
  /// **'Driver is taking too long'**
  String get cancelReasonDriverTooLong;

  /// No description provided for @cancelReasonFoundAnother.
  ///
  /// In en, this message translates to:
  /// **'Found another ride'**
  String get cancelReasonFoundAnother;

  /// No description provided for @cancelReasonChangeOfPlans.
  ///
  /// In en, this message translates to:
  /// **'Change of plans'**
  String get cancelReasonChangeOfPlans;

  /// No description provided for @cancelReasonWrongPickup.
  ///
  /// In en, this message translates to:
  /// **'Wrong pickup location'**
  String get cancelReasonWrongPickup;

  /// No description provided for @cancelReasonDriverRequested.
  ///
  /// In en, this message translates to:
  /// **'Driver requested to cancel'**
  String get cancelReasonDriverRequested;

  /// No description provided for @cancelReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cancelReasonOther;

  /// No description provided for @fareCalculationFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not calculate the fare. Please try again.'**
  String get fareCalculationFailedMessage;

  /// No description provided for @rideRequestFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not create the ride request. Please try again.'**
  String get rideRequestFailedMessage;

  /// No description provided for @ratingSubmitFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit rating. Please try again.'**
  String get ratingSubmitFailedMessage;

  /// No description provided for @paymentConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment was confirmed successfully'**
  String get paymentConfirmedMessage;

  /// No description provided for @paymentLinkMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be started — the server did not return a payment link.'**
  String get paymentLinkMissingMessage;

  /// No description provided for @paymentLinkOpenFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not open payment link'**
  String get paymentLinkOpenFailedMessage;

  /// No description provided for @paymentFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailedMessage;

  /// No description provided for @noTripDetailsMessage.
  ///
  /// In en, this message translates to:
  /// **'No trip details available'**
  String get noTripDetailsMessage;

  /// No description provided for @uploadedLabel.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploadedLabel;

  /// No description provided for @notUploadedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not Uploaded'**
  String get notUploadedLabel;

  /// No description provided for @invalidCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'The code seems invalid. Please try again'**
  String get invalidCodeMessage;

  /// No description provided for @enterValidCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit Code'**
  String get enterValidCodeMessage;

  /// No description provided for @rideNoLongerAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This ride is no longer available'**
  String get rideNoLongerAvailableMessage;

  /// No description provided for @tripsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 trip} other{{count} trips}}'**
  String tripsCount(int count);

  /// No description provided for @walletDepositLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet deposit'**
  String get walletDepositLabel;

  /// No description provided for @walletWithdrawalLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet withdrawal'**
  String get walletWithdrawalLabel;

  /// No description provided for @enterBankNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the bank name'**
  String get enterBankNameError;

  /// No description provided for @enterAccountNumberError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the account number'**
  String get enterAccountNumberError;

  /// No description provided for @fieldRequiredError.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequiredError;

  /// No description provided for @fieldRequiredNamedError.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequiredNamedError(String field);

  /// No description provided for @passwordMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String passwordMinLengthError(int min);

  /// No description provided for @loggingInLabel.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingInLabel;

  /// No description provided for @passwordChangedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessMessage;

  /// No description provided for @accountPendingReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Your driver account is awaiting approval.'**
  String get accountPendingReviewMessage;

  /// No description provided for @accountRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your driver application was rejected. Please contact support.'**
  String get accountRejectedMessage;

  /// No description provided for @accountSuspendedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is suspended. Please contact support.'**
  String get accountSuspendedMessage;

  /// No description provided for @accountDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'This account has been deleted.'**
  String get accountDeletedMessage;

  /// No description provided for @onboardingRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please complete driver onboarding.'**
  String get onboardingRequiredMessage;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get permissionDeniedMessage;

  /// No description provided for @tooManyRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get tooManyRequestsMessage;

  /// No description provided for @accountStatusPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Application under review'**
  String get accountStatusPendingTitle;

  /// No description provided for @accountStatusPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks for applying to drive with Anstop. Our team is reviewing your documents. You can start driving as soon as your account is approved.'**
  String get accountStatusPendingBody;

  /// No description provided for @accountStatusRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application not approved'**
  String get accountStatusRejectedTitle;

  /// No description provided for @accountStatusSuspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account suspended'**
  String get accountStatusSuspendedTitle;

  /// No description provided for @accountStatusDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountStatusDeletedTitle;

  /// No description provided for @accountStatusStepCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountStatusStepCreated;

  /// No description provided for @accountStatusStepSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Documents submitted'**
  String get accountStatusStepSubmitted;

  /// No description provided for @accountStatusStepReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get accountStatusStepReview;

  /// No description provided for @accountStatusStepDrive.
  ///
  /// In en, this message translates to:
  /// **'Start driving'**
  String get accountStatusStepDrive;

  /// No description provided for @checkStatusButton.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get checkStatusButton;

  /// No description provided for @continueSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Continue setup'**
  String get continueSetupButton;

  /// No description provided for @accountStatusStillPending.
  ///
  /// In en, this message translates to:
  /// **'Your application is still under review.'**
  String get accountStatusStillPending;

  /// No description provided for @loadingButton.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingButton;

  /// No description provided for @resettingButton.
  ///
  /// In en, this message translates to:
  /// **'Resetting...'**
  String get resettingButton;

  /// No description provided for @savingButton.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingButton;

  /// No description provided for @processingButton.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingButton;

  /// No description provided for @navigatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Navigating...'**
  String get navigatingLabel;

  /// No description provided for @riderFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get riderFallbackName;

  /// No description provided for @userFallbackName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallbackName;

  /// No description provided for @unknownUserName.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownUserName;

  /// No description provided for @meLabel.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meLabel;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineStatus;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Updates about your rides and wallet will appear here.'**
  String get noNotificationsMessage;

  /// No description provided for @tripIdCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Trip ID copied'**
  String get tripIdCopiedMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
