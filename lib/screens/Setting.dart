import 'dart:io';
import 'dart:math';

import 'package:denkuan_sebari/widgets/boomerang_shape_clipper.dart';
import 'package:denkuan_sebari/widgets/camera_focus_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrController;

  bool _currentFlashModeOn = false;

  // @override
  // void reassemble() {
  //   if (Platform.isAndroid) {
  //     qrController!.pauseCamera();
  //   } else if (Platform.isIOS) {
  //     qrController!.resumeCamera();
  //   }
  //   super.reassemble();
  // }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        print("resss" + result!.code.toString() + result!.format.toString());
      });
    });
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox.shrink(),
                  Text(
                    'Denkuan Sebari',
                    style: TextStyle(color: Colors.white, fontSize: 20.r),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 7.h),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white60)),
                    child: Icon(Icons.help, color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(height: 50.h),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 15.h),
                      color: Colors.white,
                      width: 220.w,
                      height: 430.h),
                  Image.asset(
                    'assets/phone_frame.png',
                    width: 250.w,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30.h),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: SizedBox(
                            height: 200.r,
                            width: 200.r,
                            // child: QRView(
                            //   key: qrKey,
                            //   onQRViewCreated: _onQRViewCreated,
                            // ),
                          ),
                        ),
                        CameraFocusHelper()
                      ],
                    ),
                  )
                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20.r), left: Radius.circular(20.r))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          MaterialButton(onPressed: (){}, child: Text('Scan '),)
                        ],
                      )
                    ],
                  ),
                ),
              ),
              // Center(
              //   child: (result != null)
              //       ? Text(
              //           'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
              //       : Text('Scan a code'),
              // )
            ],
          ),
        ],
      ),
    );
  }
}
