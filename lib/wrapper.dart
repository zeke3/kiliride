import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiliride/providers/providers.dart';
import 'package:kiliride/screens/authentication/get_started.scrn.dart';
import 'package:kiliride/screens/splash.scrn.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/services/refresh_token.service.dart';

class Wrapper extends ConsumerStatefulWidget {
  const Wrapper({super.key});

  @override
  ConsumerState<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends ConsumerState<Wrapper> {
  bool _showSplash = true;
  bool _tokenCheckComplete = false;
  bool _hasValidTokens = false;

  @override
  void initState() {
    super.initState();
    _setupAuthenticationFailureListener();
    _initializeApp();
  }

  /// Setup listener for authentication failures
  void _setupAuthenticationFailureListener() {
    RefreshTokenService.instance.onAuthenticationFailure = () {
      print('🔔 Authentication failure detected - navigating to GetStarted');
      if (mounted) {
        setState(() {
          _hasValidTokens = false;
          _tokenCheckComplete = true;
        });
        // Navigate to GetStarted screen
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/getstarted', (route) => false);
      }
    };
  }

  @override
  void dispose() {
    // Clear the callback when widget is disposed
    RefreshTokenService.instance.onAuthenticationFailure = null;
    super.dispose();
  }

  /// Initialize app and check token validity
  Future<void> _initializeApp() async {
    // Start splash screen timer
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });

    // Initialize refresh token service - THIS IS WHERE THE REFRESH TOKEN IS CALLED
    await _checkTokenStatus();
  }

  /// Check token status and update UI accordingly
  Future<void> _checkTokenStatus() async {
    try {
      print('🔄 Checking token status...');
      final hasValidTokens = await RefreshTokenService.instance.init();

      if (hasValidTokens) {
        print('✅ Token service initialized - user authenticated');
        // Get user profile to check user type
        await _getUserProfile();
      } else {
        print('❌ Token service failed - user needs to login');
        if (mounted) {
          setState(() {
            _hasValidTokens = false;
            _tokenCheckComplete = true;
          });
        }
      }
    } catch (e) {
      print('❌ Error initializing token service: $e');
      if (mounted) {
        setState(() {
          _hasValidTokens = false;
          _tokenCheckComplete = true;
        });
      }
    }
  }

  /// Get user profile and navigate based on user type
  Future<void> _getUserProfile() async {
    try {
      final authService = AuthService.instance;
      final profileResult = await authService.getMyProfile(ref: ref);

      if (mounted) {
        setState(() {
          _hasValidTokens = true;
          _tokenCheckComplete = true;
        });

        // Check if profile was retrieved successfully
        if (profileResult['success'] == true) {
          // Initialize app data now that user is authenticated
          // No await - runs in background without blocking UI
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(appDataProvider).initializeAllData();
          });

          _navigateBasedOnUserType();
        } else {
          // Profile fetch failed, go to get started
          print('❌ Failed to get user profile');
        }
      }
    } catch (e) {
      print('❌ Error getting user profile: $e');
      if (mounted) {
        setState(() {
          _hasValidTokens = false;
          _tokenCheckComplete = true;
        });
      }
    }
  }

  /// Navigate to appropriate screen based on user type
  void _navigateBasedOnUserType() {
    if (!mounted) return;

    final userType = ref.read(userInfoProvider).user?.userType ?? 'client';
    if (userType == 'sales_agent') {
      // Navigate to Sales Navigation Screen
      Navigator.pushReplacementNamed(context, '/sales-navigation');
    } else if (userType == 'provider') {
      // Navigate to Provider Navigation Screen
      Navigator.pushReplacementNamed(context, '/provider-navigation');
    } else if (userType == 'client') {
      // Navigate to Client Navigation Screen
      Navigator.pushReplacementNamed(context, '/client-navigation');
    } else {
      // Unknown user type, stay on get started
      print('⚠️ Unknown user type: $userType');
    }
  }

  /// Call this method after successful login to refresh token status
  Future<void> refreshTokenStatus() async {
    await _checkTokenStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    // If token check is complete and user is authenticated, navigation will happen automatically
    // Otherwise show GetStartedScreen
    // if (_tokenCheckComplete && _hasValidTokens) {
    //   // Return a loading indicator while navigation happens
    //   return const SplashScreen();
    // }

    if (_tokenCheckComplete && !_hasValidTokens) {
      return const GetStartedScreen();
    }

    // While checking tokens, show splash
    return const SplashScreen();
  }
}
