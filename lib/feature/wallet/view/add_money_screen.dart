import 'package:ride_sharing/feature/wallet/controller/wallet_controller.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';

class AddMoneyScreen extends StatelessWidget {
  const AddMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              AppLocalization.tr.addMoneyTitle,
              style: TextStyle(
                color: AppColors.blackShade300,
                fontSize: 25.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    Text(
                      AppLocalization.tr.enterAmountLabel,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Amount Input Field
                    TextFormField(
                      controller: controller.amountTEController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: controller.validateAmount,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 16.w, right: 8.w),
                          child: Text(
                            '€',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        hintText: amountPlaceholder(),
                        hintStyle: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.r),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.r),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 20.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),


                    const Spacer(),

                    Obx(() => CustomButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.processDeposit(context),
                          label: controller.isLoading.value
                              ? AppLocalization.tr.processingButton
                              : AppLocalization.tr.confirmButton,
                        )),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildQuickAmountButton(AddMoneyController controller, int amount) {
  //   return GestureDetector(
  //     onTap: () {
  //       controller.amountTEController.text = amount.toString();
  //     },
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
  //       decoration: BoxDecoration(
  //         color: Colors.grey[100],
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(color: Colors.grey[300]!),
  //       ),
  //       child: Text(
  //         '€$amount',
  //         style: TextStyle(
  //           fontSize: 14.sp,
  //           fontWeight: FontWeight.w500,
  //           color: Colors.black87,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
