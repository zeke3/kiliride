import 'package:kiliride/screens/authentication/get_started.scrn.dart';
import 'package:kiliride/screens/authentication/login.scrn.dart';
import 'package:kiliride/screens/authentication/signup.scrn.dart';
import 'package:kiliride/screens/authentication/otp_selection_method.scrn.dart';
import 'package:kiliride/screens/authentication/otp_verification.scrn.dart';
import 'package:kiliride/screens/authentication/password_reset_otp_verification.scrn.dart';
import 'package:kiliride/screens/authentication/reset_password.scrn.dart';
import 'package:kiliride/screens/driver/driver.navigation.dart';

import 'package:kiliride/wrapper.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String clientHome = '/client-home';
  static const String clientNavigation = '/client-navigation';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/signup';
  static const String getstarted = '/getstarted';
  static const String otpSelection = '/otp-selection';
  static const String otpVerification = '/otp-verification';
  static const String passwordResetOtpVerification = '/password-reset-otp-verification';
  static const String resetPassword = '/reset-password';
  static const String biometricSelection =
      '/biometric-registration-selection';
  static const String liveFaceRegistration = '/live-face-registration';
  static const String handRegistration = '/hand-registration';
  static const String handVerification = '/hand-verification';

  static const String providerNavigation = '/provider-navigation';
  static const String providerHome = '/provider-home';

  static const String salesNavigation = '/sales-navigation';
  static const String salesHome = '/sales-home';
  static const String driverNavigation = '/driver-navigation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case AppRouter.register:
        return MaterialPageRoute(builder: (context) => const SignupScreen());
      case AppRouter.getstarted:
        return MaterialPageRoute(builder: (context) => GetStartedScreen());
      case AppRouter.otpSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => OtpSelectionScreen(
            isRegistration: args?['isRegistration'] ?? false,
          ),
          settings: settings,
        );
      case AppRouter.otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            emailOrPhone: args?['emailOrPhone'] as String?,
            otpExpirySeconds: args?['otpExpirySeconds'] as int?,
            isEmail: args?['isEmail'] as bool? ?? false,
          ),
          settings: settings,
        );
      case AppRouter.passwordResetOtpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => PasswordResetOtpVerificationScreen(
            emailOrPhone: args?['emailOrPhone'] as String?,
            deliveryMethod: args?['deliveryMethod'] as String?,
          ),
          settings: settings,
        );
      case AppRouter.resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            emailOrPhone: args?['emailOrPhone'] as String?,
            otpCode: args?['otpCode'] as String?,
          ),
          settings: settings,
        );
      case AppRouter.driverNavigation:
        return MaterialPageRoute(builder: (context) => const DriverNavigation());  
      default:
        return MaterialPageRoute(builder: (context) => const Wrapper());
    }
  }
}
