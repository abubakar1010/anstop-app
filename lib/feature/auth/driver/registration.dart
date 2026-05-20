import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:ride_sharing/feature/auth/view/log_in_screen.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';

import '../../../routes/app_routes.dart';

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
  final TextEditingController _genderController = TextEditingController();

  bool isChecked = false;
  final PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');
  DateTime? _selectedDate;
  final List<String> _genders = ['MALE', 'FEMALE'];
  String? _selectedGender;

  Future<void> _selectGender(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(
      Offset.zero,
    ); // Get position of the text field
    final double textFieldWidth =
        renderBox.size.width; // Width of the text field
    final double textFieldHeight =
        renderBox.size.height; // Height of the text field
    final double middleY =
        position.dy + (textFieldHeight / 2); // Width of the text field
    final String? selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + textFieldWidth - 24, // 24 is the width of the suffixIcon
        middleY +
            30, // Vertically center the dropdown with a slight offset (20 is the approximate height of the menu)
        position.dx + textFieldWidth - 24, // Keep dropdown aligned to the right
        0,
      ),
      items: _genders.map((gender) {
        return PopupMenuItem<String>(value: gender, child: Text(gender));
      }).toList(),
    );

    if (selected != null) {
      setState(() {
        _selectedGender = selected;
        _genderController.text = _selectedGender!;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
          },
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
                AppLocalization.tr.createAccountTitle,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalization.tr.createAccountSubtitle,
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
                      // SizedBox(height: 12.h),

                      // GestureDetector(
                      //   onTap: () async {
                      //     // Show dropdown when text field is tapped
                      //     _selectGender(context);
                      //   },
                      //   child: AbsorbPointer(
                      //     child: TextField(
                      //       controller: _genderController,
                      //       decoration: InputDecoration(
                      //         prefixIcon: Icon(
                      //           Icons.person,
                      //           color: Color(0XFF8A8A8A),
                      //           size: 24,
                      //         ),
                      //         suffixIcon: Icon(
                      //           Icons.arrow_drop_down,
                      //           color: Color(0XFF8A8A8A),
                      //           size: 24,
                      //         ),
                      //         hintText: AppLocalization.tr.selectGenderHint,
                      //         hintStyle: TextStyle(
                      //           fontSize: 14,
                      //           color: Color(0XFF8A8A8A),
                      //         ),
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         enabledBorder: OutlineInputBorder(
                      //           borderSide: BorderSide(
                      //             color: Color(0XFF8A8A8A),
                      //             width: 1,
                      //           ),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderSide: BorderSide(
                      //             color: Color(0XFF8A8A8A),
                      //             width: 2,
                      //           ),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
                            Get.snackbar(
                              'Validation Error',
                              'Please select your birthday',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          // if (_genderController.text.isEmpty) {
                          //   Get.snackbar(
                          //     'Validation Error',
                          //     'Please select your gender',
                          //     snackPosition: SnackPosition.BOTTOM,
                          //     backgroundColor: Colors.red,
                          //     colorText: Colors.white,
                          //   );
                          //   return;
                          // }
                          if (_addressTEController.text.trim().isEmpty) {
                            Get.snackbar(
                              'Validation Error',
                              'Please enter your address',
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
                              // 'gender': _genderController.text.toUpperCase(),
                              'address': _addressTEController.text.trim(),
                              'dateOfBirth': _birthdayController.text.trim(),
                            },
                          );
                        },
                        label: "Next",
                      ),
                      SizedBox(height: 5.h),
                      GestureDetector(
                        onTap: () {
                          Get.to(LogInScreen());
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: AppLocalization.tr.haveAccountText,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0XFF4E4E4E),
                                ),
                              ),
                              TextSpan(
                                text: AppLocalization.tr.loginLink,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
                                  decorationThickness: 2,
                                  decoration: TextDecoration.underline,
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
            ],
          ),
        ),
      ),
    );
  }
}
