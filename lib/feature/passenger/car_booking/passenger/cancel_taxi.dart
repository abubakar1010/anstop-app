import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/widgets/custom_button.dart';
import '../../../../app/utils/app_colors.dart';
import 'controller/cancel_taxi_controller.dart';

/// Asks why the ride is being cancelled, then cancels it. Pops with `true`
/// once the server has cancelled the ride.
class CancelTaxiScreen extends StatefulWidget {
  /// The ride to cancel; null means the ride currently in progress.
  final String? rideId;
  final bool asDriver;

  const CancelTaxiScreen({super.key, this.rideId, this.asDriver = false});

  @override
  State<CancelTaxiScreen> createState() => _CancelTaxiScreenState();
}

class _CancelTaxiScreenState extends State<CancelTaxiScreen> {
  late final CancelTaxiController controller;
  late final String _tag = 'cancel:${widget.rideId ?? 'current'}';

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      CancelTaxiController(rideId: widget.rideId, asDriver: widget.asDriver),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<CancelTaxiController>(tag: _tag);
    super.dispose();
  }

  Future<void> _submit() async {
    final cancelled = await controller.submitCancellation();
    if (!cancelled || !mounted) return;
    if (!widget.asDriver) await _showSorryDialog(context);
    if (mounted) Navigator.of(context).pop(true);
  }

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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.sp),
            Center(
              child: Text(
                AppLocalization.tr.selectCancellationReasonLabel,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.appGreyColor),
              ),
            ),
            SizedBox(height: 20.sp),
            for (final reason in controller.cancellationReasons) ...[
              _ReasonTile(
                label: reason,
                isChecked: controller.isReasonSelected(reason),
                onTap: () => controller.selectReason(reason),
              ),
              SizedBox(height: 10.h),
            ],
            if (controller.isOtherSelected)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.grayShade100),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: TextField(
                  controller: controller.otherReasonTEController,
                  maxLines: 3,
                  maxLength: 300,
                  onChanged: (_) => controller.errorMessage.value = '',
                  decoration: InputDecoration(
                    hintText: AppLocalization.tr.cancellationReasonHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            if (controller.errorMessage.value.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20.h),
          ],
        )),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Obx(() => CustomButton(
          onPressed: controller.isLoading.value ? () {} : _submit,
          title: controller.isLoading.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                )
              : Text(
                  AppLocalization.tr.submitButton,
                  style: TextStyle(color: AppColors.white),
                ),
        )),
      ),
    );
  }

  Future<void> _showSorryDialog(BuildContext context) {
    return showDialog(
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Image.asset(
                  AppImage.sadEmoji,
                  height: 50.h,
                  width: 50.h,
                ),
              ),
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

/// One selectable reason, in the bordered style the screen used before.
class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.label, required this.isChecked, required this.onTap});

  final String label;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.grayShade100),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primaryColor,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
