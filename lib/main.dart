// lib/main.dart
import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kiliride/screens/splash.scrn.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kiliride/controllers/notification_handler.dart';
import 'package:kiliride/firebase_options.dart';
import 'package:kiliride/routes/router.dart';
import 'package:kiliride/services/db_service.dart';
import 'package:kiliride/services/guest_mode_service.dart';
import 'package:kiliride/services/language_service.dart';
import 'package:kiliride/services/locale.service.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:kiliride/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

// Centralized initialization of all app services
class AppInitializer {
  static bool _isFirebaseInitialized = false;

  static bool get isFirebaseInitialized => _isFirebaseInitialized;

  static Future<void> initializeApp() async {
    try {
      // Firebase initialization with timeout for better UX
      if (Firebase.apps.isEmpty) {
        debugPrint('Starting Firebase initialization...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(
          const Duration(seconds: 10), // Add timeout to prevent hanging
          onTimeout: () {
            debugPrint('Firebase initialization timed out');
            throw TimeoutException(
              'Firebase initialization timeout',
              const Duration(seconds: 10),
            );
          },
        );

        // Initialize Firebase Storage with specific bucket
        FirebaseStorage.instanceFor(
          bucket:
              'gs://daykiliride-768aa.firebasestorage.app', // Replace with your actual bucket
        );

        debugPrint('Firebase core initialized successfully');
        _isFirebaseInitialized = true;

        debugPrint('All Firebase services initialized successfully');
      } else {
        debugPrint('Firebase already initialized');
        _isFirebaseInitialized = true;
      }
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      _isFirebaseInitialized = false;

      // Don't try to use Crashlytics here since it might not be initialized
      // Just log to console and let the app continue
      debugPrint(
        'Firebase initialization failed, continuing without Firebase services',
      );
    }
  }

  static Future<void> initializePermissions() async {
    try {
      // Don't request permissions on first launch to avoid delays
      // Just check current status without requesting
      final List<Permission> permissions = [
        Permission.storage,
        Permission.photos,
      ];

      // Only check status, don't request immediately
      for (final permission in permissions) {
        final status = await permission.status;
        debugPrint('$permission: $status');
      }

      // Permissions will be requested when actually needed in the app
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      // Don't throw here as permissions can be requested later
    }
  }
}

Future<void> main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize core services
    await AppInitializer.initializeApp();

    // Set up Flutter error handling for Crashlytics
    FlutterError.onError = (FlutterErrorDetails details) {
      print("FLUTTER ERROR: ${details.exception}");
      // Also log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // Handle platform-specific errors
    PlatformDispatcher.instance.onError = (error, stack) {
      print('PLATFORM ERROR: $error');
      return true;
    };

    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Initialize custom notification handler (includes all notification setup)
    await CustomNotificationHandler.initialize();

    // Initialize language settings
    await LanguageService.initializeLanguage();

    // Initialize guest mode service
    await GuestModeService.initGuestMode();

    // Run the app within ProviderScope for Riverpod
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    debugPrint('Fatal error during app initialization: $e');

    print("ERROR: $e");
    print("STACK TRACE: $stackTrace");

    // Run the error fallback app
    runApp(ErrorApp(error: e.toString()));
  }
}

// Error fallback app
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(error, style: TextStyle(color: Colors.red[800])),
        ),
      ),
    );
  }
}

// Convert MyApp to ConsumerStatefulWidget
class MyApp extends ConsumerStatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Define a reset function to clear Riverpod states
  void resetAppState() {
    // This will refresh all providers
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: AppStyle.getLightTheme(context: context),
      // darkTheme: AppStyle.getDarkTheme(context: context),
      navigatorKey: CustomNotificationHandler.navigatorKey,
      // Add Analytics Observer to track navigation
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generateRoute,
      translations: LocaleService(),
      locale: Get.locale ?? LocaleService.locale,
      fallbackLocale: LocaleService.fallbackLocale,
      home: SasMobileApp(
        title: 'SAS Mobile',
        resetAppState: resetAppState, // Pass the reset function
      ),
    );
  }
}

// Update SasMobileApp to accept the reset function via constructor
class SasMobileApp extends StatefulWidget {
  final String title;
  final VoidCallback? resetAppState;

  const SasMobileApp({
    super.key,
    required this.title,
    this.resetAppState, // Accept the reset function
  });

  @override
  State<SasMobileApp> createState() => _SasMobileAppState();
}

class _SasMobileAppState extends State<SasMobileApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("CHECKING FOR UPDATES");
      checkForUpdate(context);
      // Clear badge when app first loads
      _clearAppBadge();
    });
    _initializeAppPermissions();
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Update badge count when app resumes (user actively opens app)
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed - updating badge count");
      _updateBadgeCount();
    }
  }

  /// Clear the app badge number
  Future<void> _clearAppBadge() async {
    try {
      await AwesomeNotifications().resetGlobalBadge();
      debugPrint("App badge cleared successfully");
    } catch (e) {
      debugPrint("Error clearing app badge: $e");
      // Record error to Crashlytics
    }
  }

  /// Update the app badge count based on unread notifications
  Future<void> _updateBadgeCount() async {
    try {
      await CustomNotificationHandler.updateBadgeCount();
      debugPrint("App badge count updated successfully");
    } catch (e) {
      debugPrint("Error updating app badge count: $e");
      // Record error to Crashlytics
    }
  }

  Future<void> _initializeAppPermissions() async {
    try {
      await AppInitializer.initializePermissions();
    } catch (e, stackTrace) {
      print("ERROR INITIALIZING PERMISSIONS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Wrapper());
  }

  void checkForUpdate(BuildContext context) async {
    // Get the current version of the app first (this doesn't require network)
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // Set current version in Crashlytics

    // Fetch the latest version from Firestore with retry logic
    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        DocumentSnapshot appDataVersionDoc = await DBService().appDataRef
            .doc("versionControl")
            .get();

        // Get the data
        String latestVersion = appDataVersionDoc['latestVersion'];
        bool forceUpdate = appDataVersionDoc['forceUpdate'];
        bool disableDialog = appDataVersionDoc['disableDialog'];
        String playStoreUrl = appDataVersionDoc['playStoreUrl'];
        String appStoreUrl = appDataVersionDoc['appStoreUrl'];

        // Forced update
        if (forceUpdate && latestVersion != currentVersion) {
          // Show update dialog
          if (!disableDialog) {
            showUpdateDialog(
              latestVersion: latestVersion,
              isDismissible: false,
              context: CustomNotificationHandler.navigatorKey.currentContext!,
              playStoreUrl: playStoreUrl,
              appStoreUrl: appStoreUrl,
            );
          }
        }

        //Optional update
        if (!forceUpdate && latestVersion != currentVersion) {
          // Show update dialog
          if (!disableDialog) {
            showUpdateDialog(
              latestVersion: latestVersion,
              isDismissible: true,
              context: CustomNotificationHandler.navigatorKey.currentContext!,
              playStoreUrl: playStoreUrl,
              appStoreUrl: appStoreUrl,
            );
          }
        }

        // Success - break out of retry loop
        break;
      } catch (e, stackTrace) {
        retryCount++;
        debugPrint("Version check attempt $retryCount failed: $e");

        // Check if this is a transient Firestore error
        bool isTransientError =
            e.toString().contains('unavailable') ||
            e.toString().contains('deadline-exceeded') ||
            e.toString().contains('timeout') ||
            e.toString().contains('internal');

        if (isTransientError && retryCount < maxRetries) {
          // Wait with exponential backoff before retrying
          int delayMs = (1000 * (1 << (retryCount - 1))).clamp(1000, 8000);

          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }
        break;
      }
    }
  }

  void showUpdateDialog({
    required BuildContext context,
    required String appStoreUrl,
    required String playStoreUrl,
    required bool isDismissible,
    required String latestVersion,
  }) {
    double deviceHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: deviceHeight * 0.4,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "New Update Available".tr,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSizeLG,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppStyle.appPadding),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(AppStyle.appPadding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppStyle.appRadiusLG,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF6247BA),
                              const Color(0xFF151F42),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                        child: Image.asset(
                          "assets/img/logo.png",
                          height: 70,
                          width: 70,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: AppStyle.appPadding + AppStyle.appGap,
                    ),
                    Row(
                      children: [
                        if (isDismissible)
                          Expanded(
                            child: TextButton(
                              style: AppStyle.textButtonStyle(context).copyWith(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  AppStyle.secondaryColor(
                                    context,
                                  ).withValues(alpha: 0.1),
                                ),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                  AppStyle.secondaryColor(context),
                                ),
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.symmetric(
                                    vertical: AppStyle.appPadding,
                                  ),
                                ),
                                shape:
                                    WidgetStateProperty.all<
                                      RoundedRectangleBorder
                                    >(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppStyle.appRadiusLLG,
                                        ),
                                      ),
                                    ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Ignore"),
                            ),
                          ),
                        if (isDismissible) SizedBox(width: AppStyle.appPadding),
                        Expanded(
                          child: ElevatedButton(
                            style: AppStyle.elevatedButtonStyle(context)
                                .copyWith(
                                  padding: WidgetStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(
                                      vertical: AppStyle.appPadding,
                                    ),
                                  ),
                                  shape:
                                      WidgetStateProperty.all<
                                        RoundedRectangleBorder
                                      >(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppStyle.appRadiusLLG,
                                          ),
                                        ),
                                      ),
                                ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (mounted) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                    }
                                    try {
                                      Uri url = Platform.isAndroid
                                          ? Uri.parse(playStoreUrl)
                                          : Uri.parse(appStoreUrl);

                                      if (await canLaunchUrl(url)) {
                                        debugPrint("URL: $url");
                                        await launchUrl(url);
                                      }
                                    } catch (e, stackTrace) {
                                      debugPrint(
                                        "ERROR FOR OPENING STORE FOR UPDATING: $e",
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator.adaptive(
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Update",
                                    style: TextStyle(
                                      fontSize: AppStyle.appFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyle.appPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Latest Version",
                          style: TextStyle(
                            color: AppStyle.primaryColor(context),
                            fontSize: AppStyle.appFontSize,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: AppStyle.appPadding),
                        Text(
                          latestVersion,
                          style: TextStyle(
                            color: AppStyle.primaryColor(context),
                            fontSize: AppStyle.appFontSize,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Error Screen displayed if fetching job posts fails
class ErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorScreen({super.key, required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Error fetching data: $error',
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
