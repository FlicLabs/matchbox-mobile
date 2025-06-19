import 'dart:async';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class SplashController extends GetxController {

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    print("onINit");
    Timer(Duration(seconds: 3), () {
      Get.offAllNamed(Routes.HOME);
    });
  }

  @override
  void onReady() {
    super.onReady();


  }

  @override
  void onClose() {
    super.onClose();
    print("onINit");
    Timer(Duration(seconds: 3), () {
      Get.offAllNamed(Routes.HOME);
    });

  }

  void increment() => count.value++;
}
