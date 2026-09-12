import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/widgets/custom_text_field.dart';
import 'package:ride_sharing/widgets/logo.dart';
import '../controller/create_support_controller.dart';

class CreateSupportScreen extends GetView<CreateSupportController> {
  const CreateSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFE),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= APP BAR =================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: Colors.black,
                        ),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        AppLocalization.tr.supportTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      IconWidget(height: 40.h, width: 40.h, fontSize: 14.sp),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                const IconWidget(),
                const SizedBox(height: 12),
                Center(child: Text(AppLocalization.tr.supportMessage1)),
                Center(child: Text(AppLocalization.tr.supportMessage2)),

                // ================= SUBJECT FIELD =================
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    controller: controller.subjectController,
                    hintText: AppLocalization.tr.enterSubjectHint,
                    hintextColor: const Color(0xFF1E1E1E),
                    hintextSize: 16.sp,
                    validator: (value) => controller.validateSubject(value),
                    prefixIcon: const Icon(
                      Icons.subject,
                      color: Color(0xFF191A44),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ================= MESSAGE FIELD =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD3D3D3)),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: controller.messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: AppLocalization.tr.writeComplaintHint,
                        border: InputBorder.none,
                      ),
                      validator: (value) => controller.validateMessage(value),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ================= SUBMIT BUTTON =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(
                    () => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : () => controller.submitSupport(),
                      child: Container(
                        width: double.infinity,
                        height: 51,
                        decoration: BoxDecoration(
                          color: controller.isLoading.value
                              ? AppColors.primaryColor.withOpacity(0.5)
                              : AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppLocalization.tr.sendToAdminButton,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
