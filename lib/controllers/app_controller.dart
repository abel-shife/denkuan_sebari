import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController {

}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppController());
  }
}
