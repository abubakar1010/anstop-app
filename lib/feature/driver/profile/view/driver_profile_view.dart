import 'package:cached_network_image/cached_network_image.dart';
import 'package:ride_sharing/utils/driver/driver_custom_drawer.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/widgets/custom_app_bar_title.dart';
import 'package:ride_sharing/feature/driver/profile/controller/driver_profile_controller.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class DriverProfileView extends StatelessWidget {
  const DriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return GetBuilder<DriverProfileController>(
      init: DriverProfileController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: MessagingColors.profileBackgroundColor,
          key: scaffoldKey,
          appBar: CustomAppBarTitle(
            scaffoldKey: scaffoldKey,
            title: AppLocalization.tr.profileTitle,
          ),
          drawer: DriverCustomDrawer(),
          body: SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => controller.loadProfile(),
                        child: Text(AppLocalization.tr.retryButton),
                      ),
                    ],
                  ),
                );
              }

              final profile = controller.profileData.value;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 46.h),
                    // Profile Picture
                    ClipOval(
                      child:
                      profile?.profilePicture != null &&
                          profile!.profilePicture!.isNotEmpty
                          ?
                      CachedNetworkImage(
                        imageUrl: profile.profilePicture!,
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 100.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 30.sp,
                          color: AppColors.togglebuttonColor,
                        ),
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 50.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 29.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Name Field
                          _buildProfileField(
                            icon: Icons.person,
                            label: AppLocalization.tr.nameLabel,
                            value: '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim(),
                          ),
                          SizedBox(height: 12.h),
                          // Email Field
                          _buildProfileField(
                            icon: Icons.email_outlined,
                            label: AppLocalization.tr.emailLabel,
                            value: profile?.email ?? '',
                          ),
                          SizedBox(height: 12.h),
                          // Address Field
                          _buildProfileField(
                            icon: Icons.location_on_outlined,
                            label: AppLocalization.tr.addressHintText,
                            value: profile?.address ?? '',
                          ),
                          SizedBox(height: 24.h),
                          // Edit Profile Button
                          CustomButton(
                            onPressed: () async {
                              final result = await Get.toNamed(
                                AppRoutes.editDriverProfileScreen,
                                arguments: profile,
                              );
                              // Refresh profile if changes were saved
                              if (result == true) {
                                controller.loadProfile();
                              }
                            },
                            label: AppLocalization.tr.editProfileButton,
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0XFF8A8A8A)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0XFF8A8A8A),
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : label,
              style: TextStyle(
                fontSize: 14.sp,
                color: value.isNotEmpty
                    ? Colors.black87
                    : const Color(0XFF8A8A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
