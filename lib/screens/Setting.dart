import 'dart:io';
import 'dart:math';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:denkuan_sebari/config/Consts.dart';
import 'package:denkuan_sebari/config/connectivity_status.dart';
import 'package:denkuan_sebari/widgets/boomerang_shape_clipper.dart';
import 'package:denkuan_sebari/widgets/camera_focus_helper.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrController;
  late FlipCardController _flipController;
  bool _currentFlashModeOn = false;

  @override
  void reassemble() {
    if (Platform.isAndroid) {
      qrController!.pauseCamera();
    } else if (Platform.isIOS) {
      qrController!.resumeCamera();
    }
    super.reassemble();
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          controller.pauseCamera();
          Constants.ipAddress = result!.code!;
          _flipController.toggleCard();
          setState(() {});
          print("resss" + result!.code.toString() + result!.format.toString());
        }
      });
    });
  }

  @override
  void initState() {
    _flipController = FlipCardController();
    super.initState();
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
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: SizedBox(
                                height: 200.r,
                                width: 200.r,
                                child: FlipCard(
                                  controller: _flipController,
                                  direction: FlipDirection.HORIZONTAL,
                                  side: CardSide.FRONT,
                                  flipOnTouch: true,
                                  back: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      QRView(
                                        key: qrKey,
                                        onQRViewCreated: _onQRViewCreated,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            qrController!.toggleFlash();
                                            _currentFlashModeOn =
                                                !_currentFlashModeOn;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white54),
                                          padding: EdgeInsets.all(8.r),
                                          child: Icon(
                                              _currentFlashModeOn
                                                  ? Icons.flash_on
                                                  : Icons.flash_off,
                                              color: Colors.amber),
                                        ),
                                      ),
                                    ],
                                  ),
                                  front: QrImageView(
                                    data: Constants.ipAddress,
                                    version: QrVersions.auto,
                                  ),
                                ),
                              ),
                            ),
                            CameraFocusHelper(),
                          ],
                        ),
                        SizedBox(height: 40.h),
                        Text(ConnectivityStatus.connected.name),
                        SizedBox(height: 5.h),
                        AvatarGlow(
                          glowColor:  Get.theme.primaryColor,
                          endRadius: 100.r,
                          duration: Duration(milliseconds: 1000),
                          repeat: true,
                          showTwoGlows: true,
                          repeatPauseDuration: Duration(milliseconds: 100),
                          child: MaterialButton(     // Replace this child with your own
                            elevation: 8.0,
                            height: 50.r,
                            color: Get.theme.primaryColor,
                            onPressed: (){},
                            shape: CircleBorder(),
                            child: Icon(Icons.power_settings_new_outlined, color: Colors.white70,),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(20.r),
                          left: Radius.circular(20.r))),
                  // padding:
                  //     EdgeInsets.symmetric(vertical: 40.h, horizontal: 40.w),
                  // width: double.infinity,
                  // child: FlipCard(
                  //   controller: _flipController,
                  //   direction: FlipDirection.HORIZONTAL,
                  //   side: CardSide.FRONT,
                  //   back: MaterialButton(
                  //       onPressed: () {
                  //         _topFlipController.toggleCard();
                  //         _flipController.toggleCard();
                  //       },
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Text('Share Address',
                  //               style: TextStyle(color: Colors.white)),
                  //           SizedBox(width: 15.w),
                  //           Icon(
                  //             Icons.share,
                  //             color: Colors.white,
                  //           )
                  //         ],
                  //       ),
                  //       elevation: 0,
                  //       color: Get.theme.primaryColor,
                  //       shape: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(20.r),
                  //           borderSide:
                  //               BorderSide(color: Get.theme.primaryColor))),
                  //   front: MaterialButton(
                  //       onPressed: () {
                  //         _topFlipController.toggleCard();
                  //         _flipController.toggleCard();
                  //       },
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Text('Scan to Connect to Server',
                  //               style: TextStyle(color: Colors.white)),
                  //           SizedBox(width: 15.w),
                  //           Icon(
                  //             Icons.qr_code_2,
                  //             color: Colors.white,
                  //           )
                  //         ],
                  //       ),
                  //       elevation: 0,
                  //       color: Get.theme.primaryColor,
                  //       shape: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(20.r),
                  //           borderSide:
                  //               BorderSide(color: Get.theme.primaryColor))),
                  // )
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
