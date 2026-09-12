import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class PrivacyAndTermsHelper extends StatelessWidget {
  PrivacyAndTermsHelper({super.key});

  final PrivacyController _controller = Get.find<PrivacyController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(() => Checkbox(
          value: _controller.isChecked.value,
          onChanged: _controller.toggleCheckbox,
          activeColor: AppColors.primaryColor,
        )),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.appGreyColor,
              ),
              children: [
                TextSpan(text: "${AppLocalization.tr.iAgreeWithLabel} "),
                TextSpan(
                  text: "${AppLocalization.tr.termsOfServicesTitle} ",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      //Get.toNamed(AppRoutes.termsScreen);
                    },
                ),
                TextSpan(text: "${AppLocalization.tr.andConjunction} "),
                TextSpan(
                  text: AppLocalization.tr.privacyPolicyInlineLabel,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      //Get.toNamed(AppRoutes.privacyPolicyScreen); // example navigation
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PrivacyController extends GetxController {
  var isChecked = false.obs;

  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
  }
}

