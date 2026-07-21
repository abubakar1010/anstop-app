import 'package:get/get.dart';
import '../controller/car_information_controller.dart';
import '../controller/driving_license_controller.dart';
import '../controller/national_id_controller.dart';
import '../controller/upload_documents_controller.dart';
import '../controller/upload_profile_picture_controller.dart';

class UploadDocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadDocumentsController>(() => UploadDocumentsController());

    // The four section controllers are owned by this route, not by the
    // individual document screens, so whatever the driver types or uploads
    // survives popping back to the list and is still there on submit.
    Get.put<NationalIdController>(NationalIdController());
    Get.put<DrivingLicenseController>(DrivingLicenseController());
    Get.put<CarInformationController>(CarInformationController());
    Get.put<UploadProfilePictureController>(UploadProfilePictureController());
  }
}
