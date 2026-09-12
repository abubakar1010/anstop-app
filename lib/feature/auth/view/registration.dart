import 'package:ride_sharing/feature/auth/view/log_in_screen.dart';
import 'package:ride_sharing/feature/settings/data/legal_document_model.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/feature/auth/controller/registration_controller.dart';

import '../../../custom_assets/app_image.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class RegistrationScreen extends StatefulWidget {
  final String? role;

  const RegistrationScreen({super.key, this.role});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final RegistrationController _controller = Get.put(RegistrationController());
  @override
  void initState() {
    super.initState();
    // Set role if passed from previous screen
    if (widget.role != null) {
      _controller.setRole(widget.role!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50.h),
              Image.asset(
                AppImage.textLogo
              ),
              SizedBox(height: 15.h),
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
                  key: _controller.formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controller.firstNameTEController,
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0XFF8A8A8A),
                                size: 24.sp,
                              ),
                              hintText: AppLocalization.tr.firstNameLabel,
                              hintextSize: 14.sp,
                              hintextColor: Color(0XFF8A8A8A),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CustomTextField(
                              controller: _controller.lastNameTEController,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Color(0XFF8A8A8A),
                                size: 24.sp,
                              ),
                              hintText: AppLocalization.tr.lastNameLabel,
                              hintextSize: 14.sp,
                              hintextColor: Color(0XFF8A8A8A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        controller: _controller.emailTEController,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Color(0XFF8A8A8A),
                          size: 24.sp,
                        ),
                        hintText: AppLocalization.tr.enterEmailHintText,
                        hintextSize: 14.sp,
                        hintextColor: Color(0XFF8A8A8A),
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        controller: _controller.phoneTEController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: Color(0XFF8A8A8A),
                          size: 24.sp,
                        ),
                        hintText: AppLocalization.tr.phoneNumberLabel,
                        hintextSize: 14.sp,
                        hintextColor: Color(0XFF8A8A8A),
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        isObscureText: true,
                        isPassword: true,
                        controller: _controller.passwordTEController,
                        prefixIcon: Icon(
                          Icons.key,
                          color: Color(0XFF8A8A8A),
                          size: 24.sp,
                        ),
                        hintText: AppLocalization.tr.enterPasswordHintText,
                        hintextSize: 14.sp,
                        hintextColor: Color(0XFF8A8A8A),
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        isObscureText: true,
                        isPassword: true,
                        controller: _controller.confirmPasswordTEController,
                        prefixIcon: Icon(
                          Icons.key,
                          color: Color(0XFF8A8A8A),
                          size: 24.sp,
                        ),
                        hintText: AppLocalization.tr.enterPasswordHintText,
                        hintextSize: 14.sp,
                        hintextColor: Color(0XFF8A8A8A),
                      ),
                      SizedBox(height: 46.h),
                      Obx(() => Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            value: _controller.isAgreedToTerms.value,
                            onChanged: (bool? value) {
                              _controller.toggleTermsAgreement(value);
                            },
                          ),
                          Expanded(
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalization.tr.agreeWithText, style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0XFF4E4E4E),
                                ),
                                ),
                                WidgetSpan(child: GestureDetector(
                                  child: Text(AppLocalization.tr.termsOfServiceLink, style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.red,
                                      decorationThickness: 2,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.red
                                  )),
                                  onTap: () => Get.toNamed(
                                    AppRoutes.legalPagesScreen,
                                    arguments: {'type': LegalDocumentType.termsAndConditions},
                                  ),
                                )),
                                TextSpan(text: AppLocalization.tr.andText, style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0XFF4E4E4E),
                                )),
                                WidgetSpan(child: GestureDetector(
                                  child: Text(AppLocalization.tr.privacyPolicyLink, style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.red,
                                      decorationThickness: 2,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.red
                                  )),
                                  onTap: () => Get.toNamed(
                                    AppRoutes.legalPagesScreen,
                                    arguments: {'type': LegalDocumentType.privacyPolicy},
                                  ),
                                )),
                              ],
                            ),
                          ))
                        ],
                      )),
                      SizedBox(height: 17.5.sp),
                      Obx(() => CustomButton(
                        onPressed: _controller.isLoading.value ? null : () {
                          _controller.register();
                        },
                        label: _controller.isLoading.value
                          ? 'Loading...'
                          : AppLocalization.tr.registerButton,
                      )),
                      Obx(() => _controller.errorMessage.value.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                _controller.errorMessage.value,
                                style: TextStyle(color: Colors.red, fontSize: 12.sp),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox.shrink()),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: (){
                          Get.to(LogInScreen());
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: AppLocalization.tr.haveAccountText, style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0XFF4E4E4E),
                              )),
                              TextSpan(text: AppLocalization.tr.loginLink, style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
                                  decorationThickness: 2,
                                  decoration: TextDecoration.underline
                              )),
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
