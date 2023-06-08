import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageBuilder extends StatelessWidget {
  final String imagePath;
  final bool isRemote;

  const ImageBuilder(
      {Key? key, required this.imagePath, required this.isRemote})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: Colors.white, width: 1.r),
          image: isRemote
              ? DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.cover,
                )
              : DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                )),
      child: isRemote
          ? Stack(
              alignment: Alignment.bottomRight,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.deepPurpleAccent.withOpacity(.4),
                  mini: true,
                  elevation: 0.0,
                  child: const Icon(Icons.download, color: Colors.deepPurpleAccent),
                  onPressed: () async {
                    var response = await http.get(Uri.parse(imagePath));
                    final bytes = response.bodyBytes;

                    final result = await ImageGallerySaver.saveImage(bytes);

                    if (result['isSuccess']) {
                      Fluttertoast.showToast(
                          msg: "Image Saved to Gallery!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.deepPurpleAccent,
                          textColor: Colors.white,
                          fontSize: 16.sp
                      );
                    } else {
                      Fluttertoast.showToast(
                          msg: "Image Not Saved, Please Try Again!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.sp
                      );
                    }
                  },
                ),
              ],
            )
          : SizedBox.shrink(),
    );
  }
}
