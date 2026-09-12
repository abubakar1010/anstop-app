import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/widgets/custom_button.dart'; // Assuming CustomButton is imported from your widgets
import '../../../../app/utils/app_colors.dart';
import '../../../../widgets/custom_textfield_with_checkbox.dart';

class CancelTaxiScreen extends StatefulWidget {
  const CancelTaxiScreen({super.key});

  @override
  State<CancelTaxiScreen> createState() => _CancelTaxiScreenState();
}

class _CancelTaxiScreenState extends State<CancelTaxiScreen> {
  bool _isChecked1 = false;
  bool _isChecked2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text(AppLocalization.tr.cancelTaxiTitle),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.sp),
          Center(
            child: Text(
              AppLocalization.tr.selectCancellationReasonLabel,
              style: TextStyle(color: AppColors.appGreyColor),
            ),
          ),
          SizedBox(height: 20.sp),

          // TextField with Checkbox prefix
          // Row with border wrapping the checkbox and textfield
          CustomTextFieldWithCheckbox(
            isChecked: _isChecked1,
            onCheckboxChanged: (value) {
              setState(() {
                _isChecked1 = value!;
              });
            },
            hintText: AppLocalization.tr.cancellationReasonHint,
          ),
          SizedBox(height: 10.h,),
          CustomTextFieldWithCheckbox(
            isChecked: _isChecked2,
            onCheckboxChanged: (value) {
              setState(() {
                _isChecked2 = value!;
              });
            },
            hintText: AppLocalization.tr.anotherCancellationReasonHint,
          ),
          SizedBox(height: 10.h,),
          CustomTextFieldWithCheckbox(
            isChecked: _isChecked2,
            onCheckboxChanged: (value) {
              setState(() {
                _isChecked2 = value!;
              });
            },
            hintText: AppLocalization.tr.anotherCancellationReasonHint,
          ),SizedBox(height: 10.h,),
          CustomTextFieldWithCheckbox(
            isChecked: _isChecked2,
            onCheckboxChanged: (value) {
              setState(() {
                _isChecked2 = value!;
              });
            },
            hintText: AppLocalization.tr.anotherCancellationReasonHint,
          ),SizedBox(height: 10.h,),
          CustomTextFieldWithCheckbox(
            isChecked: _isChecked2,
            onCheckboxChanged: (value) {
              setState(() {
                _isChecked2 = value!;
              });
            },
            hintText: AppLocalization.tr.anotherCancellationReasonHint,
          ),
          // Add more widgets here if necessary
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: CustomButton(
          onPressed: () {
            _showThankYouDialog(context);
          },
          title: Text(
            AppLocalization.tr.submitButton,
            style: TextStyle(color: AppColors.white),
          ),
        ),
      ),
    );
  }

  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners for the dialog
          ),
          contentPadding: EdgeInsets.zero, // Remove default padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Asset Image at the top of the dialog
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Image.asset(
                  AppImage.sadEmoji, // Replace with your image path
                  height: 50.h, // Adjust the height if needed
                  width: 50.h, // Adjust the width if needed
                ),
              ),
              // Thank You Message
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  AppLocalization.tr.sorryForCancellationMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              // Optionally add a Close button
              Padding(
                padding: EdgeInsets.all(10),
                child: CustomButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  title: Text(
                    AppLocalization.tr.closeButton,
                    style: TextStyle(fontSize: 20, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
