import 'dart:io';

import 'package:camera/camera.dart';
import 'package:denkuan_sebari/config/Consts.dart';
import 'package:denkuan_sebari/screens/loader_scree.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  List<ResolutionPreset> resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  //zoom
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;

  //exposure
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

  //flash mode
  FlashMode? _currentFlashMode;
  int _isRearCameraSelected = 0;

  //to store the retrived files
  List<File> allFileList = [];

  File? _imageFile;

  bool loading = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    onNewCameraSelected(cameras[_isRearCameraSelected]);
    refreshAlreadyCapturedImages();
    subscribeToServer();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Column(
              children: [
                AspectRatio(
                    aspectRatio: 1 / controller!.value.aspectRatio,
                    child: Stack(
                      children: [
                        controller!.buildPreview(),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Slider(
                                      value: _currentZoomLevel,
                                      min: _minAvailableZoom,
                                      max: _maxAvailableZoom,
                                      activeColor: Colors.white,
                                      inactiveColor: Colors.white30,
                                      onChanged: (value) async {
                                        setState(() {
                                          _currentZoomLevel = value;
                                        });
                                        await controller!
                                            .setZoomLevel(_currentZoomLevel);
                                      },
                                    )),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius:
                                              BorderRadius.circular(5.r)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3.w, vertical: 3.h),
                                      child: Text(
                                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isCameraInitialized = false;
                                        });
                                        onNewCameraSelected(cameras[
                                            _isRearCameraSelected == 0
                                                ? 1
                                                : 0]);
                                        setState(() {
                                          _isRearCameraSelected =
                                              _isRearCameraSelected == 0
                                                  ? 1
                                                  : 0;
                                        });
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: Colors.black38,
                                            size: 60.h,
                                          ),
                                          Icon(
                                              _isRearCameraSelected == 0
                                                  ? Icons.camera_rear
                                                  : Icons.camera_front,
                                              color: Colors.white,
                                              size: 30.h)
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          loading = true;
                                        });
                                        processPicture();
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(Icons.circle,
                                              color: Colors.white38,
                                              size: 80.h),
                                          Icon(Icons.circle,
                                              color: Colors.white, size: 65.h),
                                          loading
                                              ? const CircularProgressIndicator(
                                                  color: Colors.black12)
                                              : const SizedBox.shrink()
                                        ],
                                      ),
                                    ),
                                    Container(
                                        width: 60.r,
                                        height: 60.r,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                              color: Colors.white, width: 1.r),
                                          image: _imageFile != null
                                              ? DecorationImage(
                                                  image: FileImage(_imageFile!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 120.h,
                          child: SizedBox(
                            height: 350.h,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius:
                                            BorderRadius.circular(5.r)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 3.h),
                                    child: Text(
                                      '${_currentExposureOffset.toStringAsFixed(1)}x',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Expanded(
                                      child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Slider(
                                      value: _currentExposureOffset,
                                      min: _minAvailableExposureOffset,
                                      max: _maxAvailableExposureOffset,
                                      activeColor: Colors.white,
                                      inactiveColor: Colors.white30,
                                      onChanged: (value) async {
                                        setState(() {
                                          _currentExposureOffset = value;
                                        });
                                        await controller!.setExposureOffset(
                                            _currentExposureOffset);
                                      },
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          color: Colors.black38,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    _currentFlashMode = FlashMode.off;
                                  });
                                  await controller!
                                      .setFlashMode(_currentFlashMode!);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentFlashMode == FlashMode.off
                                          ? Colors.white12
                                          : null),
                                  padding: EdgeInsets.all(15.r),
                                  child: Icon(
                                    Icons.flash_off,
                                    color: _currentFlashMode == FlashMode.off
                                        ? Colors.amber
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    _currentFlashMode = FlashMode.auto;
                                  });
                                  await controller!
                                      .setFlashMode(_currentFlashMode!);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentFlashMode == FlashMode.auto
                                          ? Colors.white12
                                          : null),
                                  padding: EdgeInsets.all(15.r),
                                  child: Icon(
                                    Icons.flash_auto,
                                    color: _currentFlashMode == FlashMode.auto
                                        ? Colors.amber
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    _currentFlashMode = FlashMode.always;
                                  });
                                  await controller!
                                      .setFlashMode(_currentFlashMode!);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          _currentFlashMode == FlashMode.always
                                              ? Colors.white12
                                              : null),
                                  padding: EdgeInsets.all(15.r),
                                  child: Icon(
                                    Icons.flash_on,
                                    color: _currentFlashMode == FlashMode.always
                                        ? Colors.amber
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    _currentFlashMode = FlashMode.torch;
                                  });
                                  await controller!.setFlashMode(
                                    FlashMode.torch,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          _currentFlashMode == FlashMode.torch
                                              ? Colors.white12
                                              : null),
                                  padding: EdgeInsets.all(15.r),
                                  child: Icon(
                                    Icons.highlight,
                                    color: _currentFlashMode == FlashMode.torch
                                        ? Colors.amber
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                Expanded(
                  child: ListView.builder(
                    itemCount: allFileList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      File image = allFileList[index];

                      return Container(
                          width: 100.w,
                          margin: EdgeInsets.symmetric(
                              vertical: 5.h, horizontal: 5.w),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: Colors.white, width: 1.r),
                            image: image != null
                                ? DecorationImage(
                                    image: FileImage(image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ));
                    },
                  ),
                )
              ],
            )
          : const LoaderScreen(),
    );
  }

  onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    _currentFlashMode =
        controller != null ? controller!.value.flashMode : FlashMode.off;
    final CameraController cameraController = CameraController(
        cameraDescription, currentResolutionPreset,
        imageFormatGroup: ImageFormatGroup.jpeg);

    await previousCameraController?.dispose();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      _maxAvailableZoom = await cameraController.getMaxZoomLevel();
      _minAvailableZoom = await cameraController.getMinZoomLevel();
      _maxAvailableExposureOffset =
          await cameraController.getMaxExposureOffset();
      _minAvailableExposureOffset =
          await cameraController.getMinExposureOffset();
      cameraController.setFlashMode(_currentFlashMode!);
    } on CameraException catch (e) {
      print('Error initializing camera $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      //A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occurred while taking picture: $e');
      return null;
    }
  }

  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;
    if (status.isGranted) {
      print('Camera Permission: GRANTED');
      // Set and initialize the new camera
      onNewCameraSelected(cameras[_isRearCameraSelected]);
      // refreshAlreadyCapturedImages();
    } else {
      print('Camera Permission: DENIED');
    }
  }

  refreshAlreadyCapturedImages() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg')) {
        allFileList.add(File(file.path));
        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    allFileList = allFileList.reversed.toList();

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      setState(() {
        _imageFile = File('${directory.path}/$recentFileName');
      });
    }
  }

  void processPicture() async {
    XFile? rawImage = await takePicture();
    File imageFile = File(rawImage!.path);
    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    final Directory directory = await getApplicationDocumentsDirectory();
    String fileFormat = imageFile.path.split('.').last;

    await imageFile.copy('${directory.path}/$currentUnix.$fileFormat');
    File file = File('${directory.path}/$currentUnix.$fileFormat');

    _imageFile = file;
    allFileList.insert(0, file);
    await sendImageToServer(file);
    await ImageGallerySaver.saveFile(imageFile.path,
        name: '$currentUnix.$fileFormat');
  }

  sendImageToServer(File file) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.3.9:3000/upload'));
      request.files.add(await http.MultipartFile.fromPath('photo', file.path));

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
    } catch (_) {}
  }

  void subscribeToServer() {
    IO.Socket socket = IO.io('http://192.168.3.9:3000');
    socket.on('newPhoto', (data){
      print('on-newPhoto');
      print(data);
    });
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
  }
}
