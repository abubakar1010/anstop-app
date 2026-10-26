import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';

import '../../../routes/app_routes.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/feature/auth/view/log_out_dialog.dart';

class DriverRegistration extends StatefulWidget {
  const DriverRegistration({super.key});

  @override
  State<DriverRegistration> createState() => _DriverRegistrationState();
}

class _DriverRegistrationState extends State<DriverRegistration> {
  /// Controller are define here
  final TextEditingController _firstNameTEController = TextEditingController();
  final TextEditingController _lastNameTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final TextEditingController _confirmPasswordTEController =
      TextEditingController();
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _addressTEController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  bool isChecked = false;
  final PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = '${_selectedDate?.toLocal()}'.split(' ')[0];
      });
    }
  }

  /// This screen is the app's start page for a signed-in driver who has not
  /// finished onboarding (splash opens it with offAllNamed), so there may be
  /// nothing behind it. Popping then leaves a black screen; offer to sign out
  /// instead, which is the only other way out of an unfinished account.
  void _onBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _logOut();
    }
  }

  Future<void> _logOut() async {
    final result = await LogoutDialog.show(context);
    if (result == true) Get.offAllNamed(AppRoutes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _onBack,
          child: Icon(CupertinoIcons.back, color: Colors.black),
        ),
        //  middle: Text('Create Account'),
        backgroundColor: Colors.white,
        border: Border(bottom: BorderSide.none),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 46.h),
              Text(
                AppLocalization.tr.driverOnboardingTitle,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalization.tr.driverOnboardingSubtitle,
                style: TextStyle(fontSize: 12.sp),
              ),
              SizedBox(height: 29.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  child: Column(
                    children: [
                      // PhoneNumberInput(
                      //   controller: _phoneNumberController,
                      //   onInputChanged: (PhoneNumber number) {
                      //     setState(() {
                      //       _phoneNumber = number;
                      //     });
                      //   },
                      //   onInputValidated: (bool value) {
                      //     print(value ? 'Valid number' : 'Invalid number');
                      //   },
                      //   initialValue: _phoneNumber,
                      // ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: _birthdayController,
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: Color(0XFF8A8A8A),
                              size: 24.sp,
                            ),
                            hintText: AppLocalization.tr.selectBirthdayHint,
                            hintextSize: 14.sp,
                            hintextColor: Color(0XFF8A8A8A),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        controller: _addressTEController,
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: Color(0XFF8A8A8A),
                          size: 24.sp,
                        ),
                        hintText: AppLocalization.tr.addressHintText,
                        hintextSize: 14.sp,
                        hintextColor: Color(0XFF8A8A8A),
                      ),

                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Checkbox(
                      //       checkColor: Colors.white,
                      //       // fillColor: Color(0XFF323232),
                      //       value: isChecked,
                      //       onChanged: (bool? value) {
                      //         setState(() {
                      //           isChecked = value!;
                      //         });
                      //       },
                      //     ),
                      //     RichText(
                      //       textAlign: TextAlign.center,
                      //       maxLines: 1,
                      //       text: TextSpan(
                      //         children: [
                      //           TextSpan(
                      //             text: AppLocalization.tr.agreeWithText, style: TextStyle(
                      //             fontSize: 12.sp,
                      //             fontWeight: FontWeight.w400,
                      //             color: Color(0XFF4E4E4E),
                      //           ),
                      //           ),
                      //           WidgetSpan(child: GestureDetector(
                      //             child: Text(AppLocalization.tr.termsOfServiceLink, style: TextStyle(
                      //                 fontSize: 12.sp,
                      //                 fontWeight: FontWeight.w400,
                      //                 color: Colors.red,
                      //                 decorationThickness: 2,
                      //                 decoration: TextDecoration.underline,
                      //                 decorationColor: Colors.red
                      //             )),
                      //             onTap: ()=> {
                      //               Get.to(() => TermsOfServices())
                      //             },
                      //           )),
                      //           TextSpan(text: AppLocalization.tr.andText, style: TextStyle(
                      //             fontSize: 12.sp,
                      //             fontWeight: FontWeight.w400,
                      //             color: Color(0XFF4E4E4E),
                      //           )),
                      //           TextSpan(
                      //               text: AppLocalization.tr.privacyPolicyLink, style: TextStyle(
                      //               fontSize: 12.sp,
                      //               fontWeight: FontWeight.w400,
                      //               color: Colors.red,
                      //               decorationThickness: 2,
                      //               decoration: TextDecoration.underline
                      //           )),
                      //         ],
                      //       ),
                      //     )
                      //   ],
                      // )
                      SizedBox(height: 17.5.sp),
                      CustomButton(
                        onPressed: () {
                          // Validate required fields
                          if (_birthdayController.text.isEmpty) {
                            AppSnackbar.snackbar(
                              AppLocalization.tr.validationErrorTitle,
                              AppLocalization.tr.dateOfBirthRequiredError,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          if (_addressTEController.text.trim().isEmpty) {
                            AppSnackbar.snackbar(
                              AppLocalization.tr.validationErrorTitle,
                              AppLocalization.tr.addressRequiredError,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          // Navigate with profile data
                          Get.toNamed(
                            AppRoutes.uploadDocumentsScreen,
                            arguments: {
                              'address': _addressTEController.text.trim(),
                              'dateOfBirth': _birthdayController.text.trim(),
                            },
                          );
                        },
                        label: AppLocalization.tr.nextButton,
                      ),
                      SizedBox(height: 5.h),
                      // Already signed in here, so offer a way out rather
                      // than a "have an account? log in" link.
                      GestureDetector(
                        onTap: _logOut,
                        child: Text(
                          AppLocalization.tr.logoutButton,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                            decorationThickness: 2,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
