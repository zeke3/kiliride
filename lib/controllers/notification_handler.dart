import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Re-enable Firebase Messaging for getInitialMessage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kiliride/services/db_service.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/services/db_service.dart';
import 'package:flutter/material.dart';

// Import screens for navigation


class CustomNotificationHandler {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool isInitialized = false;
  static ReceivedAction? initialAction;

  // Queue for storing notification actions when app starts from terminated state
  static Map<String, dynamic>? _queuedNotificationAction;
  static bool _isAppInitialized = false;

  // Method to mark app as initialized (called from HomeScreen)
  static void markAppAsInitialized() {
    _isAppInitialized = true;
  }

  // Method to queue notification action instead of immediate navigation
  static void queueNotificationAction(Map<String, dynamic> actionData) {
    print("Queueing notification action: $actionData");
    _queuedNotificationAction = actionData;
  }

  // Method to get and clear queued notification action
  static Map<String, dynamic>? getAndClearQueuedAction() {
    final action = _queuedNotificationAction;
    _queuedNotificationAction = null;
    return action;
  }

  // Method to check if there's a queued action
  static bool hasQueuedAction() {
    return _queuedNotificationAction != null;
  }

  // Method to process queued notification actions (called from HomeScreen)
  static Future<void> processQueuedNotificationAction() async {
    if (!hasQueuedAction()) {
      print("No queued notification action to process");
      return;
    }

    print("Processing queued notification action");
    final queuedAction = getAndClearQueuedAction();
    // if (queuedAction != null) {
    //   await _processNotificationAction(queuedAction);
    // }
  }

  static Future<void> initialize() async {
    print(
      "CustomNotificationHandler initialize called. isInitialized: $isInitialized",
    );
    print(
      "Initialize called at ${DateTime.now()}. isInitialized: $isInitialized",
    );
    if (isInitialized) {
      print("Already initialized, returning early");
      return;
    }

    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          importance: NotificationImportance.Max,
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic group',
        ),
      ],
      debug: true,
    );

    // Set up Firebase Messaging directly
    // final messaging = FirebaseMessaging.instance;

    // // // Get initial token
    // // String? fcmToken = await messaging.getToken();
    // // if (fcmToken != null) {
    // //   await _onFcmTokenHandle(fcmToken);
    // // }

    // // // Listen for token refresh
    // // messaging.onTokenRefresh.listen(_onFcmTokenHandle);

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_myForegroundMessageHandler);

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_myBackgroundMessageHandler);

    // DON'T request notification permissions automatically on initialization
    // This makes notifications optional - permissions will be requested when user opts in
    print(
      "Notification system initialized - permissions will be requested when user opts in",
    );

    // Set up notification action listener
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    // Set up Firebase Messaging permissions (still needed for FCM setup)
    // final messaging = FirebaseMessaging.instance;
    // await messaging.requestPermission(alert: true, badge: true, sound: true);

    await initializeIsolateReceivePort();

    await checkPendingNotifications();

    isInitialized = true;
  }

  // Method to check if notifications are currently enabled
  static Future<bool> areNotificationsEnabled() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  // Method to clear app badge - can be called from anywhere in the app
  static Future<void> clearAppBadge() async {
    try {
      await AwesomeNotifications().resetGlobalBadge();
      print("App badge cleared successfully");
    } catch (e) {
      print("Error clearing app badge: $e");
    }
  }

  // Method to set app badge count - shows unread notification count on app icon
  static Future<void> setBadgeCount(int count) async {
    try {
      await AwesomeNotifications().setGlobalBadgeCounter(count);
      print("App badge set to: $count");
    } catch (e) {
      print("Error setting app badge count: $e");
    }
  }

  // Method to update badge count based on current unread notifications
  static Future<void> updateBadgeCount() async {
    try {
      // final uid = AuthService().currentUser?.uid;
      final uid = ''; //REPLACE WITH BACKEND AUTH LOGIC
      if (uid == null) {
        print('No authenticated user for badge update');
        return;
      }

      final DBService dbService = DBService();
      // final unreadCount = await dbService.getUnreadNotificationCount(
      //   userId: uid,
      // );

      final unreadCount = 0; //REPLACE WITH BACKEND AUTH LOGIC
      await setBadgeCount(unreadCount);
    } catch (e) {
      print("Error updating badge count: $e");
    }
  }

  // Method to request notification permissions when user opts in
  static Future<bool> requestNotificationPermissions({
    String? context = 'general',
  }) async {
    try {
      print(
        "User explicitly requested notification permissions - context: $context",
      );

      // Request basic notification permissions
      final bool isAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();

      if (isAllowed) {
        // Request specific channel permissions
        await AwesomeNotifications().requestPermissionToSendNotifications(
          channelKey: 'basic_channel',
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Vibration,
            NotificationPermission.FullScreenIntent,
          ],
        );

        print("Notification permissions granted by user");
        return true;
      } else {
        print("Notification permissions denied by user");
        return false;
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen((silentData) => handleNotificationAction(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
      receivePort!.sendPort,
      'notification_action_port',
    );
    print("INITIALIZED PORT");
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    print("RECEIVER PORT : $receivePort");
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
        'MESSAGE SENT VIA NOTIFICATION INPUT: "${receivedAction.buttonKeyInput}"',
      );
      // await executeLongTaskInBackground();
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        print(
          'ONACTIONRECEIVEDMETHOD WAS CALLED INSIDE A PARALLEL DART ISOLATE.',
        );
        SendPort? sendPort = IsolateNameServer.lookupPortByName(
          'notification_action_port',
        );

        if (sendPort != null) {
          print('REDIRECTING THE EXECUTION TO MAIN ISOLATE PROCESS.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return handleNotificationAction(receivedAction);
    }
  }

  static Future<void> checkPendingNotifications() async {
    print("Checking for pending notifications...");

    // Check for Awesome Notifications initial action
    final initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);

    if (initialAction != null) {
      print("Initial notification action received: $initialAction");
      await handleNotificationAction(initialAction);
      return; // Return early if we found an awesome notification action
    } else {
      print("No initial awesome notification action.");
    }

    // Check for Firebase Messaging initial message (when app was terminated)
    try {
      final RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        print("Initial Firebase message received: ${initialMessage.toMap()}");
        print("Message data: ${initialMessage.data}");

        // Handle Firebase initial message directly
        await handleFirebaseInitialMessage(initialMessage);
      } else {
        print("No initial Firebase message.");
      }
    } catch (e) {
      print("Error checking for initial Firebase message: $e");
    }
  }

  // Handle Firebase initial message (when app opened from terminated state)
  static Future<void> handleFirebaseInitialMessage(
    RemoteMessage message,
  ) async {
    if (kDebugMode) {
      print("=== HANDLING FIREBASE INITIAL MESSAGE ===");
      print("Firebase initial message data: ${message.data}");
    }

    // Update app badge when user interacts with Firebase message
    try {
      // Don't clear badge here - let the mark as read functionality handle it
      print(
        "Firebase message interaction - badge will be updated after processing",
      );
    } catch (e) {
      print("Error handling Firebase message interaction: $e");
    }

    // If app is not properly initialized yet (from terminated state), queue the action
    if (!_isAppInitialized || navigatorKey.currentContext == null) {
      print(
        'App not fully initialized yet, queuing Firebase notification action',
      );

      // Queue the action data to be processed once app is initialized
      queueNotificationAction({
        'source': 'firebase',
        'action_type': message.data['action_type'],
        'job_id': message.data['job_id'],
        'data': message.data,
      });
      return;
    }

    // If app is already initialized, proceed with immediate navigation
    // await _processNotificationAction({
    //   'source': 'firebase',
    //   'action_type': message.data['action_type'],
    //   'job_id': message.data['job_id'],
    //   'data': message.data,
    // });
  }

  // Handle the actual navigation based on notification type
  static Future<void> handleNotificationAction(
    ReceivedAction receivedAction,
  ) async {
    if (kDebugMode) {
      print("=== NOTIFICATION HANDLER CALLED ===");
      print("handleNotificationAction called with: $receivedAction");
    }

    // Update app badge when user interacts with notification
    try {
      // Don't clear badge here - let the mark as read functionality handle it
      print(
        "Notification interaction - badge will be updated after processing",
      );
    } catch (e) {
      print("Error handling notification interaction: $e");
    }

    // If app is not properly initialized yet, queue the action
    if (!_isAppInitialized || navigatorKey.currentContext == null) {
      print(
        'App not fully initialized yet, queuing awesome notification action',
      );

      // Queue the action data to be processed once app is initialized
      queueNotificationAction({
        'source': 'awesome_notifications',
        'action_type': receivedAction.payload?['action_type'],
        'job_id': receivedAction.payload?['job_id'],
        'data': receivedAction.payload ?? {},
      });
      return;
    }

    // If app is already initialized, proceed with immediate navigation
    // await _processNotificationAction({
    //   'source': 'awesome_notifications',
    //   'action_type': receivedAction.payload?['action_type'],
    //   'job_id': receivedAction.payload?['job_id'],
    //   'data': receivedAction.payload ?? {},
    // });

    // Clear the specific notification after handling
    await AwesomeNotifications().dismiss(receivedAction.id!);

    // Final badge clear to ensure it's completely gone
    try {
      await AwesomeNotifications().resetGlobalBadge();
    } catch (e) {
      print("Error in final badge clear: $e");
    }
  }

  // Process notification action (either immediately or from queue)
  // static Future<void> _processNotificationAction(
  //   Map<String, dynamic> actionData,
  // ) async {
  //   if (kDebugMode) {
  //     print("=== PROCESSING NOTIFICATION ACTION ===");
  //     print("Processing action data: $actionData");
  //   }

  //   if (navigatorKey.currentContext == null) {
  //     print('No valid context for navigation');
  //     return;
  //   }

  //   final context = navigatorKey.currentContext!;
  //   final actionType = actionData['action_type'];
  //   final source = actionData['source'];

  //   if (kDebugMode) {
  //     print("Action data contents: $actionData");
  //     print("Action type extracted: $actionType");
  //     print("Source: $source");
  //   }

  //   // Fetch necessary data
  //   final uid = AuthService().currentUser?.uid;
  //   if (uid == null) {
  //     print('No authenticated user found');
  //     return;
  //   }

  //   print("User ID: $uid");

  //   try {
  //     final userData = await DBService().usersRef.doc(uid).get();

  //     // Check if context is still valid after async operation
  //     if (!context.mounted) {
  //       print('Context is no longer mounted, cannot navigate');
  //       return;
  //     }

  //     print("About to navigate for action type: $actionType");

  //     switch (actionType) {
  //       case 'job_application_received':
  //         // Navigate to applications tab screen for employers to view applications
  //         print("Navigating to JobsTabScreen for job_application_received");
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => JobsTabScreen(userData: userData),
  //           ),
  //         );
  //         break;

  //       case 'job_bid_received':
  //         // Navigate to applications tab screen for employers to view bids
  //         print("Navigating to JobsTabScreen for job_bid_received");
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => JobsTabScreen(userData: userData),
  //           ),
  //         );
  //         break;

  //       case 'job_hired':
  //         // Navigate to job details screen for hired notification
  //         final jobId = actionData['job_id'];
  //         print("JOB HIRED REDIRECT: Job ID = $jobId");

  //         if (jobId != null) {
  //           print(
  //             "Navigating to JobDetailsScreen for job_hired with jobId: $jobId",
  //           );
  //           await _navigateToJobDetails(context, jobId, userData);
  //         } else {
  //           print(
  //             "No job_id provided in job_hired notification, navigating to applications",
  //           );
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => MyApplicationsPage(userData: userData),
  //             ),
  //           );
  //         }
  //         break;

  //       case 'job_rejected':
  //         // Navigate to my applications screen to show rejection status
  //         print("Navigating to MyApplicationsPage for job_rejection");
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => MyApplicationsPage(userData: userData),
  //           ),
  //         );
  //         break;

  //       case 'job_completed':
  //         // Navigate to job details screen for completion notification
  //         final jobId = actionData['job_id'];
  //         print("JOB COMPLETED REDIRECT: Job ID = $jobId");

  //         if (jobId != null) {
  //           print(
  //             "Navigating to JobDetailsScreen for job_completed with jobId: $jobId",
  //           );
  //           await _navigateToJobDetails(context, jobId, userData);
  //         } else {
  //           print(
  //             "No job_id provided in job_completed notification, navigating to applications",
  //           );
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => MyApplicationsPage(userData: userData),
  //             ),
  //           );
  //         }
  //         break;

  //       case 'job_terminated':
  //         // Navigate to job details screen for termination notification
  //         final jobId = actionData['job_id'];
  //         print("JOB TERMINATED REDIRECT: Job ID = $jobId");

  //         if (jobId != null) {
  //           print(
  //             "Navigating to JobDetailsScreen for job_terminated with jobId: $jobId",
  //           );
  //           await _navigateToJobDetails(context, jobId, userData);
  //         } else {
  //           print(
  //             "No job_id provided in job_terminated notification, navigating to applications",
  //           );
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => MyApplicationsPage(userData: userData),
  //             ),
  //           );
  //         }
  //         break;

  //       case 'application_accepted':
  //         // Navigate to job details screen for accepted application
  //         final jobId = actionData['job_id'];
  //         print("APPLICATION ACCEPTED REDIRECT: Job ID = $jobId");

  //         if (jobId != null) {
  //           print(
  //             "Navigating to JobDetailsScreen for application_accepted with jobId: $jobId",
  //           );
  //           await _navigateToJobDetails(context, jobId, userData);
  //         } else {
  //           print(
  //             "No job_id provided in application_accepted notification, navigating to applications",
  //           );
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => MyApplicationsPage(userData: userData),
  //             ),
  //           );
  //         }
  //         break;

  //       case 'employer_note':
  //         // Navigate to job details screen for employer note notification
  //         final jobId = actionData['job_id'];
  //         print("EMPLOYER NOTE REDIRECT: Job ID = $jobId");

  //         if (jobId != null) {
  //           print(
  //             "Navigating to JobDetailsScreen for employer_note with jobId: $jobId",
  //           );
  //           await _navigateToJobDetails(context, jobId, userData);
  //         } else {
  //           print(
  //             "No job_id provided in employer_note notification, navigating to applications",
  //           );
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => MyApplicationsPage(userData: userData),
  //             ),
  //           );
  //         }
  //         break;

  //       case 'job_posted':
  //         // Navigate to the specific job post that was posted
  //         final jobId = actionData['job_id'];
  //         print("JOB POSTED REDIRECT: Job ID = $jobId");

  //         if (jobId != null) {
  //           print(
  //             "Navigating to JobDetailsScreen for job_posted with jobId: $jobId",
  //           );
  //           await _navigateToJobDetails(context, jobId, userData);
  //         } else {
  //           print(
  //             "No job_id provided in job_posted notification, navigating to home",
  //           );
  //           // Don't navigate to HomeScreen again since we're already there
  //           // Just stay on current screen
  //         }
  //         break;

  //       default:
  //         // For unknown action types, navigate to home screen
  //         print('Unknown action type: $actionType');
  //         print("Staying on current screen for unknown action type");
  //         // Don't navigate to HomeScreen again since we're already there
  //         break;
  //     }

  //     // Clear handled notifications but update badge count based on remaining unread notifications
  //     await AwesomeNotifications().cancelAll();

  //     // Update badge count to reflect current unread notifications
  //     await updateBadgeCount();
  //   } catch (e) {
  //     print('Error handling notification action: $e');
  //     // On error, just stay on current screen since we're already in proper navigation context
  //   }
  // }

  // Helper method to navigate to job details screen
  // static Future<void> _navigateToJobDetails(
  //   BuildContext context,
  //   String jobId,
  //   DocumentSnapshot userData,
  // ) async {
  //   try {
  //     final dbService = DBService();
  //     final jobDoc = await dbService.jobPostsRef.doc(jobId).get();

  //     if (jobDoc.exists && context.mounted) {
  //       final jobData = jobDoc.data() as Map<String, dynamic>;
  //       // Add the document ID to the data map
  //       jobData['id'] = jobDoc.id;
  //       final jobPost = JobPost.fromMap(jobData);

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) =>
  //               JobDetailsScreen(job: jobPost, userData: userData),
  //         ),
  //       );
  //     } else {
  //       print("Job not found or context no longer mounted, navigating to home");
  //       if (context.mounted) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => const HomeScreen()),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     print("Error fetching job data: $e");
  //     if (context.mounted) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => const HomeScreen()),
  //       );
  //     }
  //   }
  // }

  // Foreground message handler
  static Future<void> _myForegroundMessageHandler(RemoteMessage message) async {
    print('"ForegroundMessage": ${message.toString()}');
    print('Handling in foreground');

    final Map<String, dynamic> messageData = message.data;
    if (messageData.isNotEmpty) {
      final String? title = messageData['title'];
      final String? body = messageData['body'];
      if (title != null && body != null) {
        // Store the notification in Firestore for historical viewing
        await _storeNotificationFromMessageData(messageData);

        // Create the notification
        await _createNotificationFromMessageData(messageData);
      } else {
        print(
          "Missing title or body in payload, skipping notification creation",
        );
      }
    } else {
      print("No data in payload, skipping notification creation");
    }
  }

  @pragma("vm:entry-point")
  static Future<void> _myBackgroundMessageHandler(RemoteMessage message) async {
    print('"BackgroundMessage": ${message.toString()}');
    print('Handling in background/terminated');

    final Map<String, dynamic> messageData = message.data;
    if (messageData.isNotEmpty) {
      final String? title = messageData['title'];
      final String? body = messageData['body'];
      if (title != null && body != null) {
        // Store the notification in Firestore for historical viewing
        await _storeNotificationFromMessageData(messageData);

        // Create the notification
        await _createNotificationFromMessageData(messageData);
      } else {
        print(
          "Missing title or body in payload, skipping notification creation",
        );
      }
    } else {
      print("No data in payload, skipping notification creation");
    }
  }

  // Helper method to store notification in Firestore
  static Future<void> _storeNotificationFromMessageData(
    Map<String, dynamic> messageData,
  ) async {
    try {
      final data = messageData['data'] ?? messageData;
      final userId = data['user_id'] ?? messageData['user_id'];

      if (userId != null) {
        // await DBService().storeNotification(
        //   title: messageData['title'] ?? '',
        //   body: messageData['body'] ?? '',
        //   actionType: data['action_type'] ?? 'unknown',
        //   userId: userId,
        //   data: Map<String, dynamic>.from(data),
        //   jobId: data['job_id'],
        //   jobTitle: data['job_title'],
        //   senderId: data['applicant_id'] ?? data['bidder_id'],
        //   senderName: data['applicant_name'] ?? data['bidder_name'],
        // ); // REPLACE WITH BACKEND AUTH LOGIC
        print('Notification stored in Firestore for user: $userId');
      }
    } catch (e) {
      print('Error storing notification in Firestore: $e');
      // Don't fail the notification process if storage fails
    }
  }

  // Adapted creation method for Map from awesome_fcm (for background/foreground consistency)
  static Future<void> _createNotificationFromMessageData(
    Map<String, dynamic> messageData,
  ) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now()
            .millisecondsSinceEpoch, // Use unique timestamp ID for deduplication
        channelKey: 'basic_channel',
        title: messageData['title'],
        body: messageData['body'],
        payload: messageData['data'] ?? messageData, // Payload from data
        wakeUpScreen: true,
        criticalAlert: true, // For iOS
        category: NotificationCategory.Call, // Higher priority category
        notificationLayout: NotificationLayout.Default,
        showWhen: true,
        displayOnBackground: true,
        displayOnForeground: true,
        ticker: 'ticker',
      ),
    );

    // Update app badge count after creating notification
    await updateBadgeCount();
  }

  // Additional notification lifecycle methods
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification created: ${receivedNotification.toMap()}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification displayed: ${receivedNotification.toMap()}');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('Notification dismissed: ${receivedAction.toMap()}');
  }
}
