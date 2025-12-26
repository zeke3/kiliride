import 'package:flutter/material.dart';
import 'package:kiliride/services/db_service.dart';
import 'package:kiliride/services/auth.service.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final bool showBadge;

  const NotificationBadge({
    Key? key,
    required this.child,
    this.showBadge = true,
  }) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final DBService _dbService = DBService();
  final AuthService _authService = AuthService();
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.showBadge) {
      _loadUnreadCount();
    }
  }

  Future<void> _loadUnreadCount() async {
    // final userId = _authService.currentUser?.uid;
    final userId = '_authService.currentUser?.uid'; //REPLACE WITH BACKEND AUTH LOGIC
    if (userId != null) {
      try {
        // final count = await _dbService.getUnreadNotificationCount(
        //   userId: userId,
        // );
        final count = 0; //REPLACE WITH BACKEND AUTH LOGIC
        if (mounted) {
          setState(() => unreadCount = count);
        }
      } catch (e) {
        print('Error loading unread notification count: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showBadge || unreadCount == 0) {
      return widget.child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
