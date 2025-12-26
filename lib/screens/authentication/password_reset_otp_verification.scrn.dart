import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:kiliride/components/back_button.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';

class PasswordResetOtpVerificationScreen extends StatefulWidget {
  final String? emailOrPhone;
  final String? deliveryMethod;

  const PasswordResetOtpVerificationScreen({
    super.key,
    this.emailOrPhone,
    this.deliveryMethod,
  });

  @override
  State<PasswordResetOtpVerificationScreen> createState() =>
      _PasswordResetOtpVerificationScreenState();
}

class _PasswordResetOtpVerificationScreenState
    extends State<PasswordResetOtpVerificationScreen> {
  final _authService = AuthService.instance;
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();
  late int _resendSeconds;
  Timer? _resendTimer;
  bool _loading = false;
  late String _emailOrPhone;
  late String _deliveryMethod;

  @override
  void initState() {
    super.initState();
    _emailOrPhone = widget.emailOrPhone ?? '';
    _deliveryMethod = widget.deliveryMethod ?? 'email';
    _resendSeconds = 300; // 5 minutes
    _startResendTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _emailOrPhone = (args['emailOrPhone'] as String?) ?? _emailOrPhone;
          _deliveryMethod =
              (args['deliveryMethod'] as String?) ?? _deliveryMethod;
        });
      }
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  String get _formattedTimer {
    final minutes = (_resendSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_resendSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        if (mounted) setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    if (_resendSeconds > 0 || _loading) return;

    setState(() => _loading = true);

    try {
      final result = await _authService.forgotPassword(
        emailOrPhone: _emailOrPhone,
        deliveryMethod: _deliveryMethod,
      );

      if (mounted && result['success'] == true) {
        setState(() => _resendSeconds = 300);
        _startResendTimer();
        Funcs.showSnackBar(
          message: result['message'] ?? 'Code resent successfully',
          isSuccess: true,
        );
      } else {
        Funcs.showSnackBar(
          message: result['message'] ?? 'Failed to resend code',
          isSuccess: false,
        );
      }
    } catch (e) {
      Funcs.showSnackBar(message: e.toString(), isSuccess: false);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _verifyCode(String pin) async {
    if (pin.length < 6 || _loading) return;

    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    try {
      final result = await _authService.verifyPasswordResetOtp(
        emailOrPhone: _emailOrPhone,
        otpCode: pin,
      );

      if (result['success'] == true) {
        Funcs.showSnackBar(
          message: result['message'] ?? "OTP verified successfully!",
          isSuccess: true,
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // Navigate to reset password screen
          Navigator.pushReplacementNamed(
            context,
            '/reset-password',
            arguments: {
              'emailOrPhone': _emailOrPhone,
              'otpCode': pin,
            },
          );
        }
      } else {
        Funcs.showSnackBar(
          message: result['message'] ?? 'Invalid or expired OTP',
          isSuccess: false,
        );
      }
    } catch (e) {
      Funcs.showSnackBar(message: e.toString(), isSuccess: false);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: _otpAppBar(),
        bottomSheet: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppStyle.appBackgroundColor(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppStyle.appRadiusLG),
              topRight: Radius.circular(AppStyle.appRadiusLG),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.appPadding,
            vertical: AppStyle.appPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppStyle.appPadding),
                if (_loading) const LinearProgressIndicator(),
                const SizedBox(height: AppStyle.appGap),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: AppStyle.appFontSize,
                      color: AppStyle.textColoredFade(context),
                      fontWeight: FontWeight.w500,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "${"We sent a code to".tr} "),
                      TextSpan(
                        text: _deliveryMethod == 'email'
                            ? _maskEmail(_emailOrPhone)
                            : '- - -${_emailOrPhone.length > 4 ? _emailOrPhone.substring(_emailOrPhone.length - 4) : _emailOrPhone}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppStyle.secondaryColor(context),
                        ),
                      ),
                      TextSpan(
                        text:
                            ". ${"Enter it here to verify your identity".tr}",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _pinController,
                    focusNode: _pinFocusNode,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: AppStyle.primaryColor(
                            context,
                          ).withOpacity(0.5),
                        ),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: AppStyle.primaryColor(context).withOpacity(0.1),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: Colors.redAccent),
                      ),
                    ),
                    onCompleted: (pin) => _verifyCode(pin),
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                  ),
                ),
                const SizedBox(height: AppStyle.appPadding + AppStyle.appGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                        color: AppStyle.textColoredFade(context),
                        fontSize: AppStyle.appFontSize,
                      ),
                    ),
                    TextButton(
                      onPressed: _resendSeconds == 0 ? _resendCode : null,
                      child: Text(
                        _resendSeconds > 0
                            ? 'Resend in $_formattedTimer'
                            : 'Resend',
                        style: TextStyle(
                          color: _resendSeconds == 0
                              ? AppStyle.primaryColor(context)
                              : AppStyle.textColoredFade(context),
                          fontWeight: FontWeight.bold,
                          fontSize: AppStyle.appFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppStyle.appPadding + 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppStyle.elevatedButtonStyle(context).copyWith(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        AppStyle.secondaryColor2(context),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(
                          horizontal: AppStyle.appPadding,
                          vertical: AppStyle.appPadding,
                        ),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppStyle.appRadiusMd,
                          ),
                        ),
                      ),
                    ),
                    onPressed: (_pinController.text.length < 6 || _loading)
                        ? null
                        : () => _verifyCode(_pinController.text),
                    child: _loading
                        ? CircularProgressIndicator.adaptive(
                            backgroundColor: AppStyle.appColor(context),
                          )
                        : Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: AppStyle.appFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpAppBar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppStyle.appBarsecondaryColor(context),
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(20, 96, 109, 1),
            Color.fromRGBO(12, 46, 60, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.7],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: AppStyle.appPadding,
            child: SafeArea(
              child: CustomBackButton(
                hasPadding: true,
                color: AppStyle.textAppColor(context),
              ),
            ),
          ),
          Positioned(
            bottom: AppStyle.appPaddingLG,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Verify OTP".tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeXLG,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.textNeutralColor(context),
                  ),
                ),
                Text(
                  'Enter the code to reset your password'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeSM,
                    fontWeight: FontWeight.w400,
                    color: AppStyle.textNeutralColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }
}
