import 'package:flutter/material.dart';
import 'package:kiliride/components/custom_mono_appbar.dart';
import 'package:kiliride/models/notification.model.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<CustomNotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadDummyNotifications();
  }

  void _loadDummyNotifications() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    _notifications = [
      // Today's notifications
      CustomNotificationModel(
        id: '1',
        title: 'New Claim Submitted',
        body: 'your recent claim for dental Check-up has been successful...',
        actionType: 'claim',
        data: {},
        userId: 'user123',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      CustomNotificationModel(
        id: '2',
        title: 'Payment Processed',
        body: 'your recent claim of 125`750,000 has been processed.',
        actionType: 'payment',
        data: {},
        userId: 'user123',
        createdAt: now.subtract(const Duration(hours: 4)),
        isRead: false,
      ),
      // Yesterday's notifications
      CustomNotificationModel(
        id: '3',
        title: 'Wellness Tip: Stay...',
        body: 'Drinking enough water is... Crucial for your overall healt...',
        actionType: 'wellness',
        data: {},
        userId: 'user123',
        createdAt: yesterday.subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      CustomNotificationModel(
        id: '4',
        title: 'System Update Available',
        body: 'A new version of the app is available with bug fixes and...',
        actionType: 'update',
        data: {},
        userId: 'user123',
        createdAt: yesterday.subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      CustomNotificationModel(
        id: '5',
        title: 'New Claim Submitted',
        body: 'your recent claim for dental Check-up has been successful...',
        actionType: 'claim',
        data: {},
        userId: 'user123',
        createdAt: yesterday.subtract(const Duration(hours: 8)),
        isRead: false,
      ),
      CustomNotificationModel(
        id: '6',
        title: 'Payment Processed',
        body: 'your recent claim of 125`750,000 has been processed.',
        actionType: 'payment',
        data: {},
        userId: 'user123',
        createdAt: yesterday.subtract(const Duration(hours: 10)),
        isRead: false,
      ),
    ];
  }

  Map<String, List<CustomNotificationModel>> _groupNotificationsByDate() {
    final Map<String, List<CustomNotificationModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var notification in _notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String dateLabel;
      if (notificationDate == today) {
        dateLabel = 'Today';
      } else if (notificationDate == yesterday) {
        dateLabel = 'Yesterday';
      } else {
        dateLabel = DateFormat('MMMM dd, yyyy').format(notification.createdAt);
      }

      if (!grouped.containsKey(dateLabel)) {
        grouped[dateLabel] = [];
      }
      grouped[dateLabel]!.add(notification);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotificationsByDate();

    return Scaffold(
      appBar: _buildAppBar(),
      body: _notifications.isEmpty
          ? Center(
              child: Text(
                'No Notifications',
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeMd,
                  color: AppStyle.invertedTextAppColor(context),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groupedNotifications.length,
              itemBuilder: (context, index) {
                final dateLabel = groupedNotifications.keys.elementAt(index);
                final notifications = groupedNotifications[dateLabel]!;

                return _buildNotificationGroup(dateLabel, notifications);
              },
            ),
    );
  }

  // =================== WIDGETS ===================

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(AppStyle.appBarHeight),
      child: CustomMonoAppBar(title: 'Notifications'),
    );
  }

  Widget _buildNotificationGroup(
    String dateLabel,
    List<CustomNotificationModel> notifications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppStyle.appPadding, AppStyle.appPadding, AppStyle.appPadding, AppStyle.appGap),
          child: Text(
            dateLabel,
            style: TextStyle(
              fontSize: AppStyle.appFontSizeSM,
              fontWeight: FontWeight.w600,
              color: AppStyle.invertedTextAppColor(context).withOpacity(0.6),
            ),
          ),
        ),
        ...notifications.map(
          (notification) => _buildNotificationItem(notification),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(CustomNotificationModel notification) {
    IconData icon;
    Color iconColor;

    switch (notification.actionType) {
      case 'claim':
        icon = Icons.file_copy_outlined;
        iconColor = AppStyle.primaryColor(context);
        break;
      case 'payment':
        icon = Icons.receipt_outlined;
        iconColor = AppStyle.primaryColor(context);
        break;
      case 'wellness':
        icon = Icons.favorite_border;
        iconColor = AppStyle.primaryColor(context);
        break;
      case 'update':
        icon = Icons.system_update_outlined;
        iconColor = AppStyle.primaryColor(context);
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = AppStyle.primaryColor(context);
    }

    return GestureDetector(
      onTap: () {
        // Handle notification tap
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppStyle.appPadding, vertical: AppStyle.appGap + 2),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppStyle.textAppColor(context).withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(239, 244, 255, 1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: AppStyle.appFontSize,
                          fontWeight: FontWeight.w500,
                          color: AppStyle.invertedTextAppColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: AppStyle.appFontSizeSM,
                          color: AppStyle.invertedTextAppColor(context).withOpacity(0.6),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
                        Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyle.appPadding,
            ),
            child: Divider(color: AppStyle.dividerColor(context)),
          ),
        ],
      ),
    );
  }
}
