import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import '../app/utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class CustomPinCodeTextField extends StatelessWidget {
  const CustomPinCodeTextField(
      {super.key, this.textEditingController, this.validator, this.focusNode,this.autoFocus=false});

  final TextEditingController? textEditingController;
  final FormFieldValidator? validator;
  final FocusNode? focusNode;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return Pinput(
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return AppLocalization.tr.invalidCodeMessage;
              } else if (value.length != 6 ||
                  !RegExp(r'^\d{6}$').hasMatch(value)) {
                return AppLocalization.tr.enterValidCodeMessage;
              }
              return null;
            },
        focusNode: focusNode,

        controller: textEditingController,
        length: 6,
        defaultPinTheme: PinTheme(
          width: 46.w,
          height: 46.h,
          textStyle: TextStyle(color: AppColors.darkColor, fontSize: 16.sp),
          decoration: BoxDecoration(
            color: AppColors.appBarColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grayShade100),
          ),
        ),
        focusedPinTheme: PinTheme(
          width: 46.w,
          height: 46.h,
          textStyle: const TextStyle(color: AppColors.darkColor, fontSize: 20),
          decoration: BoxDecoration(
            //shape: BoxShape.circle,
            color: AppColors.appBarColor,
           borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grayShade100),
          ),
        ),
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 2.w,
              height: 20.h,
              color: AppColors.darkColor,
            ),
          ],
        ),
        keyboardType: TextInputType.number,
        //obscureText: true,
        autofocus: true,
        onChanged: (value) {},
        obscuringCharacter: '-');
  }
}
