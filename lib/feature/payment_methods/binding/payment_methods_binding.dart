import 'package:get/get.dart';
import '../controller/payment_methods_controller.dart';

class PaymentMethodsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentMethodsController>(() => PaymentMethodsController());
  }
}
