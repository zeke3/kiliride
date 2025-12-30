import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';

class SafetyToolkitBottomSheet extends StatelessWidget {
  const SafetyToolkitBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SafetyToolkitBottomSheet(),
    );
  }

  Future<void> _callPolice() async {
    // Emergency number - adjust based on country
    await Funcs().makePhoneCall('112'); // International emergency number
  }

  Future<void> _reportUnsafeDriving(BuildContext context) async {
    // TODO: Implement report unsafe driving functionality
    Funcs.showSnackBar(
      message: "Report submitted. We'll review this immediately.",
      isSuccess: true,
    );
    Navigator.pop(context);
  }

  Future<void> _messageSupport() async {
    // TODO: Implement messaging support - could open chat screen
    Funcs.showSnackBar(
      message: "Opening support chat...",
      isSuccess: true,
    );
  }

  Future<void> _shareLocation() async {
    // TODO: Implement share location functionality
    Funcs.showSnackBar(
      message: "Sharing your location...",
      isSuccess: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.appColor(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppStyle.appPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppStyle.appPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                'Safety'.tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeLLG,
                  fontWeight: FontWeight.w700,
                  color: AppStyle.textColored(context),
                ),
              ),
              const SizedBox(height: AppStyle.appGap / 2),

              // Subtitle
              Text(
                'Features to help you feel safe and secure while you ride'.tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  color: AppStyle.textColoredFade(context),
                ),
              ),
              const SizedBox(height: AppStyle.appPadding),

              // Call the police
              _buildSafetyOption(
                context: context,
                icon: 'assets/icons/safety_light.svg',
                iconColor: Colors.red,
                iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
                title: 'Call the police'.tr,
                onTap: _callPolice,
              ),
              const SizedBox(height: AppStyle.appGap / 2),

              Divider(color: AppStyle.dividerColor(context)),
              const SizedBox(height: AppStyle.appGap / 2),

              // Report unsafe driving
              _buildSafetyOption(
                context: context,
                icon: 'assets/icons/safety_info.svg',
                iconColor: Colors.grey[700]!,
                iconBackgroundColor: Colors.grey[200]!,
                title: 'Report unsafe driving'.tr,
                onTap: () => _reportUnsafeDriving(context),
              ),
              const SizedBox(height: AppStyle.appGap / 2),

              Divider(color: AppStyle.dividerColor(context)),
              const SizedBox(height: AppStyle.appGap / 2),

              // Message Kiliride Support
              _buildSafetyOption(
                context: context,
                icon: 'assets/icons/safety_support.svg',
                iconColor: Colors.grey[700]!,
                iconBackgroundColor: Colors.grey[200]!,
                title: 'Message Kiliride Support'.tr,
                onTap: _messageSupport,
              ),
              const SizedBox(height: AppStyle.appGap / 2),

              Divider(color: AppStyle.dividerColor(context)),
              const SizedBox(height: AppStyle.appGap / 2),

              // Share location
              _buildSafetyOption(
                context: context,
                icon: 'assets/icons/safety_location.svg',
                iconColor: Colors.grey[700]!,
                iconBackgroundColor: Colors.grey[200]!,
                title: 'Share location'.tr,
                onTap: _shareLocation,
              ),

              const SizedBox(height: AppStyle.appPadding),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSafetyOption({
    required BuildContext context,
    required String icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppStyle.appGap,
          horizontal: AppStyle.appGap / 2,
        ),
        child: Row(
          children: [
            // Icon container
            SvgPicture.asset(
              icon,
              color: iconColor,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: AppStyle.appPadding),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppStyle.appFontSize,
                  fontWeight: FontWeight.w500,
                  color: iconColor == Colors.red
                      ? Colors.red
                      : AppStyle.textColored(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
