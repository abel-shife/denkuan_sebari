import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BoomerangShapeClipper extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    final double radius=size.height/3;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5.r
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0,radius,0,);
    path.lineTo(size.width,0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
