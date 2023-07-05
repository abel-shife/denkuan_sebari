import 'dart:math';

import 'package:denkuan_sebari/widgets/boomerang_shape_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CameraFocusHelper extends StatelessWidget {
  const CameraFocusHelper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.r,
      width: 200.r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomPaint(
                painter: BoomerangShapeClipper(),
                child: Container(
                    height: 50.h,
                    width: 50.h
                ),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(pi),
                child: CustomPaint(
                  painter: BoomerangShapeClipper(),
                  child: Container(
                      height: 50.h,
                      width: 50.h
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: CustomPaint(
                  painter: BoomerangShapeClipper(),
                  child: Container(
                      height: 50.h,
                      width: 50.h
                  ),
                ),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(pi),
                child: CustomPaint(
                  painter: BoomerangShapeClipper(),
                  child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
                      height: 50.h,
                      width: 50.h
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
