import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class CustomUploadItems extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final Color borderColor;
  final File? uploadedImage;

  const CustomUploadItems({
    Key? key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderColor = Colors.black,
    this.uploadedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(
        borderWidth: borderWidth,
        borderColor: borderColor,
      ),
      child: Container(
        width: double.infinity,
        height: 150.h,
        child: Stack(
          children: [
            if (uploadedImage != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    uploadedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: borderColor,
                    ),
                    SizedBox(height: 5.sp),
                    Text(
                      AppLocalization.tr.uploadButton,
                      style: TextStyle(
                        color: borderColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final double borderWidth;
  final Color borderColor;

  DottedBorderPainter({
    required this.borderWidth,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    const double dashWidth = 5.0;
    const double dashSpace = 5.0;

    // Draw top line
    _drawDashedLine(canvas, Offset(0, 0), Offset(size.width, 0), paint, dashWidth, dashSpace);
    // Draw left line
    _drawDashedLine(canvas, Offset(0, 0), Offset(0, size.height), paint, dashWidth, dashSpace);
    // Draw bottom line
    _drawDashedLine(canvas, Offset(0, size.height), Offset(size.width, size.height), paint, dashWidth, dashSpace);
    // Draw right line
    _drawDashedLine(canvas, Offset(size.width, 0), Offset(size.width, size.height), paint, dashWidth, dashSpace);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dashWidth, double dashSpace) {
    double distance = (end - start).distance;
    if (distance <= 0) return;

    // Calculate direction vector
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;

    // Normalize the direction
    double stepX = dx / distance;
    double stepY = dy / distance;

    int dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      double currentDistance = (dashWidth + dashSpace) * i;

      Offset startDash = Offset(
        start.dx + stepX * currentDistance,
        start.dy + stepY * currentDistance,
      );

      double endDistance = currentDistance + dashWidth;
      if (endDistance > distance) endDistance = distance;

      Offset endDash = Offset(
        start.dx + stepX * endDistance,
        start.dy + stepY * endDistance,
      );

      canvas.drawLine(startDash, endDash, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
