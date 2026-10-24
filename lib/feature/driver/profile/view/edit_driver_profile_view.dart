import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/feature/driver/profile/controller/edit_driver_profile_controller.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class EditDriverProfileView extends StatelessWidget {
  const EditDriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditDriverProfileController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: MessagingColors.profileBackgroundColor,
          appBar: AppBar(
            backgroundColor: MessagingColors.profileBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              AppLocalization.tr.editProfileButton,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 46.h),
                  // Profile Picture with edit option
                  Obx(() => GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 100.h,
                                height: 100.h,
                                child: _buildProfileImage(controller),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.grey[300]!, width: 2),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.green[800],
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  SizedBox(height: 29.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Name Fields
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: controller.firstNameTEController,
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: const Color(0XFF8A8A8A),
                                  size: 24.sp,
                                ),
                                hintText: AppLocalization.tr.firstNameLabel,
                                hintextSize: 14.sp,
                                hintextColor: const Color(0XFF8A8A8A),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: CustomTextField(
                                controller: controller.lastNameTEController,
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: const Color(0XFF8A8A8A),
                                  size: 24.sp,
                                ),
                                hintText: AppLocalization.tr.lastNameLabel,
                                hintextSize: 14.sp,
                                hintextColor: const Color(0XFF8A8A8A),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Email Field
                        CustomTextField(
                          controller: controller.emailTEController,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: const Color(0XFF8A8A8A),
                            size: 24.sp,
                          ),
                          hintText: AppLocalization.tr.emailLabel,
                          hintextSize: 14.sp,
                          hintextColor: const Color(0XFF8A8A8A),
                        ),
                        SizedBox(height: 12.h),
                        // Address Field
                        CustomTextField(
                          controller: controller.addressTEController,
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            color: const Color(0XFF8A8A8A),
                            size: 24.sp,
                          ),
                          hintText: AppLocalization.tr.addressHintText,
                          hintextSize: 14.sp,
                          hintextColor: const Color(0XFF8A8A8A),
                        ),
                        SizedBox(height: 24.h),
                        // Save Changes Button
                        Obx(() => CustomButton(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () => controller.saveProfile(),
                              label: controller.isSaving.value
                                  ? 'Saving...'
                                  : AppLocalization.tr.saveChangesButton,
                            )),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(EditDriverProfileController controller) {
    // If a new image is selected, show it
    if (controller.selectedImage.value != null) {
      return Image.file(
        controller.selectedImage.value!,
        fit: BoxFit.cover,
      );
    }

    // If there's an existing profile picture URL, show it
    if (controller.profilePictureUrl.value.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: controller.profilePictureUrl.value,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 100.h,
            height: 100.h,
            color: Colors.grey,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: 50.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Default placeholder
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: 50.sp,
        color: Colors.grey[600],
      ),
    );
  }
}
