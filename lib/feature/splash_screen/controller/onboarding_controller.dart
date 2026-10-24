import 'package:get/get.dart';
import 'package:ride_sharing/routes/app_routes.dart';

class OnboardingController extends GetxController {
  // ==================== State ====================
  final RxInt currentPage = 0.obs;
  final RxBool isLastPage = false.obs;

  // ==================== Business Logic ====================
  void setPage(int index) {
    currentPage.value = index;
    isLastPage.value = index == 2; // Assuming 3 pages (0, 1, 2)
  }

  void nextPage() {
    if (currentPage.value < 2) {
      currentPage.value++;
      setPage(currentPage.value);
    } else {
      completeOnboarding();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      setPage(currentPage.value);
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  void completeOnboarding() {
    Get.offAllNamed(AppRoutes.passengerAuthSelectionScreen);
  }
}
