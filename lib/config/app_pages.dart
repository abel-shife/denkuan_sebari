import 'package:denkuan_sebari/controllers/app_controller.dart';
import 'package:denkuan_sebari/screens/camera_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(
        name: Routes.initPage,
        page: () => const CameraScreen(),
        binding: AppBinding(),
        transition: Transition.cupertino),
  ];
}

class Routes {
  static const initPage = '/initPage';
}
