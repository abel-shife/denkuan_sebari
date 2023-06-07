import 'package:camera/camera.dart';

List<CameraDescription> cameras=[];

// DropdownButton<ResolutionPreset>(
//     items: resolutionPresets
//         .map((preset) => DropdownMenuItem<ResolutionPreset>(
//             value: preset,
//             child: Text(
//                 preset.toString().split('.')[1].toUpperCase())))
//         .toList(),
//     onChanged: (value) {
//       setState(() {
//         currentResolutionPreset = value!;
//         _isCameraInitialized = false;
//       });
//       onNewCameraSelected(controller!.description);
//     },
//     value: currentResolutionPreset,
//     underline: Container())