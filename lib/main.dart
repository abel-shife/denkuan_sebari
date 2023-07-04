import 'package:camera/camera.dart';
import 'package:denkuan_sebari/config/Consts.dart';
import 'package:denkuan_sebari/config/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'screens/camera_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the camera $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return GetMaterialApp(
              title: 'Denkuan Sebari',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: const MaterialColor(0XFF115E37, {
                  50: Color.fromRGBO(17, 94, 55, .1),
                  100: Color.fromRGBO(17, 94, 55, .2),
                  200: Color.fromRGBO(17, 94, 55, .3),
                  300: Color.fromRGBO(17, 94, 55, .4),
                  400: Color.fromRGBO(17, 94, 55, .5),
                  500: Color.fromRGBO(17, 94, 55, .6),
                  600: Color.fromRGBO(17, 94, 55, .7),
                  700: Color.fromRGBO(17, 94, 55, .8),
                  800: Color.fromRGBO(17, 94, 55, .9),
                  900: Color.fromRGBO(17, 94, 55, 1),
                }),
                colorScheme: ColorScheme.fromSeed(seedColor: Color(0XFF115E37)),
              ),
              initialRoute: Routes.initPage,
              getPages: AppPages.pages);
        });
  }
}
