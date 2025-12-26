import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/components/back_button.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? emailOrPhone;
  final String? otpCode;

  const ResetPasswordScreen({
    super.key,
    this.emailOrPhone,
    this.otpCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _authService = AuthService.instance;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  late String _emailOrPhone;
  late String _otpCode;

  @override
  void initState() {
    super.initState();
    _emailOrPhone = widget.emailOrPhone ?? '';
    _otpCode = widget.otpCode ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _emailOrPhone = (args['emailOrPhone'] as String?) ?? _emailOrPhone;
          _otpCode = (args['otpCode'] as String?) ?? _otpCode;
        });
      }
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      Funcs.showSnackBar(
        message: 'Passwords do not match',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.resetPassword(
        emailOrPhone: _emailOrPhone,
        otpCode: _otpCode,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        if (result['success']) {
          Funcs.showSnackBar(
            message: result['message'] ?? 'Password reset successfully!',
            isSuccess: true,
          );

          // Navigate to login screen
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        } else {
          Funcs.showSnackBar(
            message: result['message'] ?? 'Failed to reset password',
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Funcs.showSnackBar(
          message: 'An error occurred. Please try again.',
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: _resetPasswordAppBar(),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppStyle.appPadding),
                    if (_isLoading) const LinearProgressIndicator(),
                    const SizedBox(height: AppStyle.appGap),
                    Text(
                      'Create New Password'.tr,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSizeXLG,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppStyle.appGap),
                    Text(
                      'Your new password must be different from previously used passwords'
                          .tr,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSizeSM,
                        fontWeight: FontWeight.w500,
                        color: AppStyle.descriptionTextColor(context),
                      ),
                    ),
                    const SizedBox(height: AppStyle.appPaddingMd),
                    _resetPasswordForm(),
                    SizedBox(height: AppStyle.appPadding + 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resetPasswordAppBar() {
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
                  'Reset Password'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeXLG,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.textNeutralColor(context),
                  ),
                ),
                Text(
                  'Set a new password for your account'.tr,
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

  Widget _resetPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New Password",
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              TextFormField(
                controller: _newPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your new password'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadius),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isNewPasswordVisible,
              ),
            ],
          ),
          SizedBox(height: AppStyle.appPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Confirm Password",
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              TextFormField(
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Re-enter your new password'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadius),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
              ),
            ],
          ),
          SizedBox(height: AppStyle.appPaddingLG),
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
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
                  ),
                ),
              ),
              onPressed: _isLoading ? null : _handleResetPassword,
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppStyle.textNeutralColor(context),
                        ),
                      ),
                    )
                  : Text(
                      'Reset Password'.tr,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
