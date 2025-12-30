import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class FullScreenLoader {
  /// Show full screen loading overlay
  static void show({String? animation, Color? backgroundColor, double? size}) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      barrierColor: backgroundColor ?? Colors.black54,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            width: size ?? 200,
            height: size ?? 200,
            child: Lottie.asset(
              animation ?? 'assets/lottie/kilirideloading.json',
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
        ),
      ),
    );
  }

  /// Hide full screen loading overlay
  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Navigator.of(Get.overlayContext!).pop();
    }
  }
}
