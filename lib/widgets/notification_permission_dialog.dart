import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/controllers/notification_handler.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final String contextInfo;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const NotificationPermissionDialog({
    super.key,
    this.contextInfo = 'general',
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Stay Updated'.tr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get notified about:'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            context: context,
            icon: Icons.work_outline,
            text: 'New job opportunities matching your skills'.tr,
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            context: context,
            icon: Icons.check_circle_outline,
            text: 'Application status updates and responses'.tr,
          ),
          // const SizedBox(height: 12),
          // _buildBenefitItem(
          //   context: context,
          //   icon: Icons.payment_outlined,
          //   text: 'Payment confirmations and job completions'.tr,
          // ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            context: context,
            icon: Icons.message_outlined,
            text: 'Important messages from employers'.tr,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can disable notifications anytime in your device settings.'
                        .tr,
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPermissionDenied?.call();
          },
          child: Text(
            'Not Now'.tr,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();

            final granted =
                await CustomNotificationHandler.requestNotificationPermissions(
                  context: contextInfo,
                );

            if (granted) {
              onPermissionGranted?.call();

              // Show success feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Notifications enabled! You\'ll receive important updates.'
                        .tr,
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              onPermissionDenied?.call();

              // Show info about manual enabling
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'You can enable notifications later in Settings.'.tr,
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Settings'.tr,
                    textColor: Colors.white,
                    onPressed: () {
                      // Open app settings (you might want to use permission_handler for this)
                    },
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Enable Notifications'.tr,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // Static method to show the dialog
  static Future<void> show(
    BuildContext context, {
    String contextInfo = 'general',
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) async {
    // First check if notifications are already enabled
    final alreadyEnabled =
        await CustomNotificationHandler.areNotificationsEnabled();

    if (alreadyEnabled) {
      // Already enabled, no need to show dialog
      onGranted?.call();
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // Don't allow dismissing by tapping outside
        builder: (BuildContext dialogContext) => NotificationPermissionDialog(
          contextInfo: contextInfo,
          onPermissionGranted: onGranted,
          onPermissionDenied: onDenied,
        ),
      );
    }
  }
}
