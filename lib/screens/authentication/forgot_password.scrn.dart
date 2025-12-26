import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:kiliride/components/back_button.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  PhoneNumber? _phoneNumber;
  String selectedMethod = 'email'; // 'email' or 'sms'
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get the appropriate value based on selected method
      final String emailOrPhone = selectedMethod == 'email'
          ? _emailOrPhoneController.text.trim()
          : _phoneNumber?.international ?? '';

      final result = await _authService.forgotPassword(
        emailOrPhone: emailOrPhone,
        deliveryMethod: selectedMethod,
      );

      if (mounted) {
        if (result['success']) {
          Funcs.showSnackBar(
            message: result['message'] ?? 'OTP sent successfully',
            isSuccess: true,
          );

          // Navigate to OTP verification screen for password reset
          Navigator.pushNamed(
            context,
            '/password-reset-otp-verification',
            arguments: {
              'emailOrPhone': _emailOrPhoneController.text.trim(),
              'deliveryMethod': selectedMethod,
            },
          );
        } else {
          Funcs.showSnackBar(
            message: result['message'] ?? 'Failed to send OTP',
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
        body: _forgotPasswordAppBar(),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppStyle.appPadding),
                if (_isLoading) const LinearProgressIndicator(),
                const SizedBox(height: AppStyle.appGap),
                Text(
                  'Forgot Password'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeXLG,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppStyle.appGap),
                Text(
                  'Enter your email or phone number and select how you want to receive the verification code'
                      .tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeSM,
                    fontWeight: FontWeight.w500,
                    color: AppStyle.descriptionTextColor(context),
                  ),
                ),
                const SizedBox(height: AppStyle.appPaddingMd),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedMethod == 'email' ? "Email" : "Phone Number",
                        style: TextStyle(
                          fontSize: AppStyle.appFontSizeSM,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppStyle.appGap),
                      if (selectedMethod == 'email')
                        TextFormField(
                          controller: _emailOrPhoneController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'john.doe@example.com'.tr,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppStyle.appRadius),
                            ),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        )
                      else
                        PhoneFormField(
                          initialValue: PhoneNumber.parse('+255'),
                          decoration: InputDecoration(
                            hintText: '712 345 678'.tr,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppStyle.appRadius),
                            ),
                          ),
                          validator: PhoneValidator.compose([
                            PhoneValidator.required(context),
                            PhoneValidator.validMobile(context),
                          ]),
                          countrySelectorNavigator:
                              const CountrySelectorNavigator.page(),
                          onChanged: (newNumber) {
                            setState(() => _phoneNumber = newNumber);
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppStyle.appPaddingMd),
                Text(
                  'Delivery Method'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeSM,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppStyle.appGap),
                _verificationMethodCard(
                  icon: 'assets/icons/mail.svg',
                  title: 'Email',
                  subtitle: 'Send verification code via email',
                  value: 'email',
                ),
                const SizedBox(height: AppStyle.appPadding),
                _verificationMethodCard(
                  icon: 'assets/icons/phone_outlined.svg',
                  title: 'SMS',
                  subtitle: 'Send verification code via SMS',
                  value: 'sms',
                ),
                const SizedBox(height: AppStyle.appPaddingLG),
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
                    onPressed: _isLoading ? null : _handleContinue,
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
                            'Continue'.tr,
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

  // =================== WIDGETS ===================
  Widget _forgotPasswordAppBar() {
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
            // top: AppStyle.appPadding * 2.5,
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
                  'Choose how you want to recover your account'.tr,
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

  Widget _verificationMethodCard({
    required String icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = selectedMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(AppStyle.appPadding),
        decoration: BoxDecoration(
          color: AppStyle.appBackgroundColor(context),
          borderRadius: BorderRadius.circular(AppStyle.appRadiusMid),
          border: Border.all(
            color: isSelected
                ? AppStyle.primaryColor(context)
                : AppStyle.descriptionTextColor(context).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(243, 245, 251, 1),
                borderRadius: BorderRadius.circular(AppStyle.appRadius),
              ),
              child: SvgPicture.asset(
                icon,
                height: 24,
                color: AppStyle.descriptionTextColor(context),
              ),
            ),
            const SizedBox(width: AppStyle.appPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.tr,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSizeSM,
                      fontWeight: FontWeight.w400,
                      color: AppStyle.descriptionTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(AppStyle.appRadiusSm)),
                border: Border.all(
                  color: isSelected
                      ? AppStyle.primaryColor(context)
                      : AppStyle.descriptionTextColor(context).withOpacity(0.3),
                  width: 2,
                ),
                color: isSelected
                    ? AppStyle.primaryColor(context)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
