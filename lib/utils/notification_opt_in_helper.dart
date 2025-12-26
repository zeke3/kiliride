import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/controllers/notification_handler.dart';
import 'package:kiliride/widgets/notification_permission_dialog.dart';

class NotificationOptInHelper {
  // Show notification opt-in at appropriate times in the user journey

  // 1. After user successfully posts their first job
  static Future<void> promptAfterJobPost(BuildContext context) async {
    if (!context.mounted) return;

    await NotificationPermissionDialog.show(
      context,
      contextInfo: 'job_posting',
      onGranted: () {
        print("User opted in for notifications after job posting");
      },
      onDenied: () {
        print("User declined notifications after job posting");
      },
    );
  }

  // 2. After user applies to their first job
  static Future<void> promptAfterJobApplication(BuildContext context) async {
    if (!context.mounted) return;

    await NotificationPermissionDialog.show(
      context,
      contextInfo: 'job_application',
      onGranted: () {
        print("User opted in for notifications after job application");
      },
      onDenied: () {
        print("User declined notifications after job application");
      },
    );
  }

  // 3. In user profile/settings - always available option
  static Future<void> showInSettings(BuildContext context) async {
    if (!context.mounted) return;

    final isEnabled = await CustomNotificationHandler.areNotificationsEnabled();

    if (isEnabled) {
      // Show confirmation that notifications are already enabled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifications are already enabled!'.tr),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      await NotificationPermissionDialog.show(
        context,
        contextInfo: 'settings',
        onGranted: () {
          print("User enabled notifications from settings");
        },
        onDenied: () {
          print("User declined notifications from settings");
        },
      );
    }
  }

  // 4. Smart prompt - only show if user has had some engagement
  static Future<void> smartPrompt(
    BuildContext context, {
    required int userJobApplications,
    required int userJobPosts,
    required bool hasReceivedMessages,
  }) async {
    if (!context.mounted) return;

    // Only prompt if user is engaged but hasn't enabled notifications
    final isEnabled = await CustomNotificationHandler.areNotificationsEnabled();
    if (isEnabled) return;

    // Show if user has some engagement
    if (userJobApplications >= 2 || userJobPosts >= 1 || hasReceivedMessages) {
      await NotificationPermissionDialog.show(
        context,
        contextInfo: 'smart_prompt',
        onGranted: () {
          print("User opted in via smart prompt");
        },
        onDenied: () {
          print("User declined via smart prompt");
        },
      );
    }
  }

  // 5. Check notification status and show settings prompt
  static Widget buildNotificationSettingsWidget(BuildContext context) {
    return FutureBuilder<bool>(
      future: CustomNotificationHandler.areNotificationsEnabled(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final isEnabled = snapshot.data!;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              isEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: isEnabled ? Colors.green : Colors.orange,
            ),
            title: Text(
              isEnabled
                  ? 'Notifications Enabled'.tr
                  : 'Enable Notifications'.tr,
            ),
            subtitle: Text(
              isEnabled
                  ? 'You\'ll receive important updates'.tr
                  : 'Stay updated on job opportunities and applications'.tr,
            ),
            trailing: isEnabled
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: isEnabled ? null : () => showInSettings(context),
          ),
        );
      },
    );
  }
}
