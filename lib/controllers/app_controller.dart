import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController with WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // App is in the background
      // Do something
    } else if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      // Do something else
    }
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppController());
  }
}
