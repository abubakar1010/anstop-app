import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/feature/auth/controller/login_controller.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/widgets/logo.dart';
import '../controller/support_list_controller.dart';
import '../widget/support_list_item.dart';

class SupportListScreen extends GetView<SupportListController> {
   SupportListScreen({super.key});
  LoginController loginController = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => loginController.navigateToHomeByRole()
        ),
        title: Text(
          AppLocalization.tr.supportTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: IconWidget(
              height: 40.h,
              width: 40.h,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Support List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.supportMessages.isEmpty) {
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
                        onPressed: () => controller.fetchSupportMessages(),
                        child: Text(AppLocalization.tr.retryButton),
                      ),
                    ],
                  ),
                );
              }

              if (controller.supportMessages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppLocalization.tr.noSupportMessagesTitle,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalization.tr.createSupportPromptMessage,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF999999),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshMessages(),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: controller.supportMessages.length,
                  itemBuilder: (context, index) {
                    final message = controller.supportMessages[index];
                    return SupportListItem(
                      supportMessage: message,
                    );
                  },
                ),
              );
            }),
          ),
          // Add Support Button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              height: 51.h,
              child: ElevatedButton(
                onPressed: () async {
                  await Get.toNamed(AppRoutes.createSupportScreen);
                  // Refresh list when coming back
                  controller.refreshMessages();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  AppLocalization.tr.addSupportButton,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
