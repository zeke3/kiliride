import 'package:flutter/material.dart';
import 'dart:math' show pi;

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    double notchRadius = 20.0; // The size of the circular notches

    // Start at the top-left corner
    path.moveTo(0, 0);

    // Draw a line to the top-right corner
    path.lineTo(size.width, 0);

    // Move to the center-right and draw a notch
    path.lineTo(size.width, size.height / 2 - notchRadius);
    path.arcToPoint(
      Offset(size.width, size.height / 2 + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Move to the bottom-right corner
    path.lineTo(size.width, size.height);

    // Draw a line to the bottom-left corner
    path.lineTo(0, size.height);

    // Move to the center-left and draw a notch
    path.lineTo(0, size.height / 2 + notchRadius);
    path.arcToPoint(
      Offset(0, size.height / 2 - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Move back to the starting point
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}


class AvatarClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double avatarRadius = 40; // Adjust to match the avatar size
    double avatarCenterX = size.width / 2; // Center the avatar horizontally
    double avatarCenterY = avatarRadius; // Center of the avatar vertically

    // Start from the top-left corner
    path.moveTo(0, 0);

    // Line down to just below the avatar
    path.lineTo(0, avatarCenterY + avatarRadius - 10);

    // Create an arc around the avatar
    path.arcToPoint(
      Offset(size.width, avatarCenterY + avatarRadius - 10),
      radius: Radius.circular(avatarRadius), // Adjust for a smoother curve
      clockwise: false,
    );

    // Continue to the bottom-right corner
    path.lineTo(size.width, 0); // Go back to the top-right
    path.lineTo(0, 0); // Back to the starting point
    path.close(); // Close the path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // No need to reclip
  }
}

// Custom Clipper class to create the curved hole effect
class HolePainter extends CustomPainter {
  final Color color;
  final double holeRadius;
  final double cornerRadius;
  final double startAngle;
  final double sweepAngle;

  HolePainter({
    required this.color,
    required this.holeRadius,
    this.cornerRadius = 20, // Default corner radius
    this.startAngle = -pi,
    this.sweepAngle = -pi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final centerX = size.width / 2;
    final holeTop = 0.0;

    final path = Path()
      ..moveTo(cornerRadius, 0)
      ..lineTo(centerX - holeRadius, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, holeTop), radius: holeRadius),
        startAngle,
        sweepAngle,
        false,
      )
      ..lineTo(size.width - cornerRadius, 0)
      ..arcToPoint(
        Offset(size.width, cornerRadius),
        radius: Radius.circular(cornerRadius),
        clockwise: true,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, cornerRadius)
      ..arcToPoint(
        Offset(cornerRadius, 0),
        radius: Radius.circular(cornerRadius),
        clockwise: true,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
