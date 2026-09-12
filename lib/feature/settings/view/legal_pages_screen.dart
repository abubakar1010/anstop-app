import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import '../controller/legal_pages_controller.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class LegalPagesScreen extends GetView<LegalPagesController> {
  const LegalPagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.title)),
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.legalDocument.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.fetchLegalDocument(),
                  child: Text(AppLocalization.tr.retryButton),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0XFF4E4E4E).withOpacity(0.01),
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                      color: const Color(0XFF4E4E4E).withOpacity(0.2),
                    ),
                  ),
                  child: HtmlWidget(
                    controller.description,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 33.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}
