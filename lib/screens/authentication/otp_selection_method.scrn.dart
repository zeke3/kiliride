import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:kiliride/components/back_button.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/shared/styles.shared.dart';

class OtpSelectionScreen extends StatefulWidget {
  final bool isRegistration;
  final bool loginWithOtp;

  const OtpSelectionScreen({super.key, this.isRegistration = true, this.loginWithOtp = false});

  @override
  State<OtpSelectionScreen> createState() => _OtpSelectionScreenState();
}

class _OtpSelectionScreenState extends State<OtpSelectionScreen> {
  TextEditingController membershipIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool isPasswordVisible = false;
  String? selectedVerificationMethod;
  String? userProvidedPhone;
  String? userProvidedEmail;
  final _authService = AuthService.instance;
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    if (selectedVerificationMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a verification method'.tr)),
      );
      return;
    }

    // Get user data from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = userProvidedEmail ?? args?['email'] as String?;
    final phone =
        userProvidedPhone ??
        args?['phone'] as String? ??
        args?['phoneNumber'] as String?;

    String? target;
    String deliveryMethod = 'sms';

    if (selectedVerificationMethod == 'email') {
      target = email;
      deliveryMethod = 'email';
    } else if (selectedVerificationMethod == 'sms') {
      target = phone;
      deliveryMethod = 'sms';
    }

    if (target == null || target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No contact available to send OTP'.tr)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authService.requestOtpLogin(
        emailOrPhone: target,
        deliveryMethod: deliveryMethod,
      );

      if (mounted) {
        if (result['success'] == true) {
          Funcs.showSnackBar(
            message: result['message'] ?? 'OTP sent',
            isSuccess: true,
          );

          // Navigate to OTP verification screen
          Navigator.pushNamed(
            context,
            '/otp-verification',
            arguments: {
              'emailOrPhone': target,
              'isEmail': deliveryMethod == 'email',
              'otpExpirySeconds': 300,
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
        Funcs.showSnackBar(message: e.toString(), isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loginAppBar(),
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
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.75 -
                AppStyle.appPadding * 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: AppStyle.appPadding),
                    _buildSelections(),
                    SizedBox(height: AppStyle.appPaddingMd),


                    if(widget.loginWithOtp) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyle.appPadding * 2,
                      ),
                      child: Text(
                        "Note: Login with OTP is only available for client accounts only"
                            .tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppStyle.descriptionTextColor(context),
                          fontSize: AppStyle.appFontSizeSM,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppStyle.appPadding),],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?".tr,
                          style: TextStyle(
                            color: AppStyle.descriptionTextColor(context),
                            fontSize: AppStyle.appFontSizeSM,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: AppStyle.appGap),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: Text(
                            "Register as Client".tr,
                            style: TextStyle(
                              color: AppStyle.primaryColor(context),
                              fontSize: AppStyle.appFontSizeSM,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
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
                const SizedBox(height: AppStyle.appPaddingMd),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =================== WIDGETS===================
  Widget _loginAppBar() {
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
                  widget.isRegistration
                      ? 'Register With Biometric'.tr
                      : 'Verify Your Account'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeXLG,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.textNeutralColor(context),
                  ),
                ),

                Text(
                  'Your  Security matters.'.tr,
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

  Widget _buildSelections() {
    return Column(
      children: [
        _buildSelectionTile(
          title: "Email",
          subtitle: "Receive verification code via email.",
          iconWidget: Icon(
            Icons.email_outlined,
            size: 44,
            color: AppStyle.secondaryColor(context),
          ),
          isSelected: selectedVerificationMethod == "email",
          onTap: () {
            // Check if email has been retrieved from route arguments
            final args =
                ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            final email = userProvidedEmail ?? args?['email'] as String?;

            // If email exists, select email directly; otherwise show bottom sheet
            if (email != null && email.isNotEmpty) {
              setState(() {
                selectedVerificationMethod = "email";
              });
            } else {
              _showEmailBottomSheet();
            }
          },
        ),
        const SizedBox(height: AppStyle.appPaddingMd),
        _buildSelectionTile(
          title: "SMS",
          subtitle: "Receive verification code via SMS.",
          icon: "assets/icons/sms.svg",
          isSelected: selectedVerificationMethod == "sms",
          onTap: () {
            // Check if phone number has been retrieved from route arguments
            final args =
                ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            final phone =
                userProvidedPhone ??
                args?['phone'] as String? ??
                args?['phoneNumber'] as String?;

            // If phone number exists, select SMS directly; otherwise show bottom sheet
            if (phone != null && phone.isNotEmpty) {
              setState(() {
                selectedVerificationMethod = "sms";
              });
            } else {
              _showPhoneNumberBottomSheet();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required String subtitle,
    String? icon,
    Widget? iconWidget,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppStyle.appRadiusMid),
          border: Border.all(
            color: isSelected
                ? AppStyle.secondaryColor(context)
                : AppStyle.borderColor(context),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(AppStyle.appPadding),
        child: Row(
          children: [
            if (iconWidget != null) ...[
              iconWidget,
            ] else if (icon != null) ...[
              SvgPicture.asset(
                icon,
                height: 40,
                color: AppStyle.secondaryColor(context),
              ),
            ],
            SizedBox(width: AppStyle.appPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.tr,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppStyle.invertedTextAppColor(context),
                    ),
                  ),
                  SizedBox(height: AppStyle.appGap / 2),
                  Text(
                    subtitle.tr,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSizeSM,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? AppStyle.secondaryColor(context)
                          : AppStyle.textColoredFade(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhoneNumberBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppStyle.appBackgroundColor(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppStyle.appRadiusLG),
              topRight: Radius.circular(AppStyle.appRadiusLG),
            ),
          ),
          padding: EdgeInsets.all(AppStyle.appPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppStyle.appPadding),
                  decoration: BoxDecoration(
                    color: AppStyle.borderColor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Enter Phone Number'.tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeLG,
                  fontWeight: FontWeight.w600,
                  color: AppStyle.invertedTextAppColor(context),
                ),
              ),
              SizedBox(height: AppStyle.appGap),
              Text(
                'Please enter your phone number to receive the verification code.'
                    .tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w400,
                  color: AppStyle.descriptionTextColor(context),
                ),
              ),
              SizedBox(height: AppStyle.appPadding),
              PhoneFormField(
                initialValue: PhoneNumber.parse('+255'),
                decoration: InputDecoration(
                  labelText: 'Phone Number'.tr,
                  hintText: '712 345 678',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: AppStyle.secondaryColor(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusMid),
                    borderSide: BorderSide(
                      color: AppStyle.borderColor(context),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusMid),
                    borderSide: BorderSide(
                      color: AppStyle.borderColor(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusMid),
                    borderSide: BorderSide(
                      color: AppStyle.secondaryColor(context),
                      width: 2,
                    ),
                  ),
                ),
                countrySelectorNavigator: const CountrySelectorNavigator.page(),
                validator: PhoneValidator.compose([
                  PhoneValidator.required(context),
                  PhoneValidator.validMobile(context),
                ]),
                onChanged: (newNumber) {
                  setState(() => _phoneNumber = newNumber);
                },
              ),
              SizedBox(height: AppStyle.appPadding),
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
                  onPressed: () async {
                    if (_phoneNumber == null || !_phoneNumber!.isValid()) {
                      Funcs.showSnackBar(
                        message: 'Please enter a valid phone number'.tr,
                        isSuccess: false,
                      );
                      return;
                    }

                    // Capture navigator and phone number before async operations
                    final navigator = Navigator.of(context);
                    final phoneNumber = _phoneNumber!.international;

                    // Close the bottom sheet first
                    navigator.pop();

                    // Update state with phone number
                    setState(() {
                      selectedVerificationMethod = 'sms';
                      userProvidedPhone = phoneNumber;
                    });

                    // Send OTP and navigate following the same flow as email
                    setState(() => _isLoading = true);
                    try {
                      final result = await _authService.requestOtpLogin(
                        emailOrPhone: phoneNumber,
                        deliveryMethod: 'sms',
                      );

                      if (mounted) {
                        if (result['success'] == true) {
                          Funcs.showSnackBar(
                            message: result['message'] ?? 'OTP sent',
                            isSuccess: true,
                          );

                          // Navigate to OTP verification screen
                          navigator.pushNamed(
                            '/otp-verification',
                            arguments: {
                              'emailOrPhone': phoneNumber,
                              'isEmail': false,
                              'otpExpirySeconds': 300,
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
                        Funcs.showSnackBar(message: e.toString(), isSuccess: false);
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  child: Text(
                    'Confirm'.tr,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppStyle.appPaddingMd),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmailBottomSheet() {
    final TextEditingController emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppStyle.appBackgroundColor(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppStyle.appRadiusLG),
              topRight: Radius.circular(AppStyle.appRadiusLG),
            ),
          ),
          padding: EdgeInsets.all(AppStyle.appPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppStyle.appPadding),
                  decoration: BoxDecoration(
                    color: AppStyle.borderColor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Enter Email Address'.tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeLG,
                  fontWeight: FontWeight.w600,
                  color: AppStyle.invertedTextAppColor(context),
                ),
              ),
              SizedBox(height: AppStyle.appGap),
              Text(
                'Please enter your email address to receive the verification code.'
                    .tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w400,
                  color: AppStyle.descriptionTextColor(context),
                ),
              ),
              SizedBox(height: AppStyle.appPadding),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address'.tr,
                  hintText: 'example@email.com',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppStyle.secondaryColor(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusMid),
                    borderSide: BorderSide(
                      color: AppStyle.borderColor(context),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusMid),
                    borderSide: BorderSide(
                      color: AppStyle.borderColor(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusMid),
                    borderSide: BorderSide(
                      color: AppStyle.secondaryColor(context),
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppStyle.appPadding),
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
                  onPressed: () async {
                    final email = emailController.text.trim();

                    // Validate email
                    if (email.isEmpty) {
                      Funcs.showSnackBar(
                        message: 'Please enter an email address'.tr,
                        isSuccess: false,
                      );
                      return;
                    }

                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                      Funcs.showSnackBar(
                        message: 'Please enter a valid email address'.tr,
                        isSuccess: false,
                      );
                      return;
                    }

                    // Capture navigator before async operations
                    final navigator = Navigator.of(context);

                    // Close the bottom sheet first
                    navigator.pop();

                    // Update state with email
                    setState(() {
                      selectedVerificationMethod = 'email';
                      userProvidedEmail = email;
                    });

                    // Send OTP and navigate following the same flow as phone
                    setState(() => _isLoading = true);
                    try {
                      final result = await _authService.requestOtpLogin(
                        emailOrPhone: email,
                        deliveryMethod: 'email',
                      );

                      if (mounted) {
                        if (result['success'] == true) {
                          Funcs.showSnackBar(
                            message: result['message'] ?? 'OTP sent',
                            isSuccess: true,
                          );

                          // Navigate to OTP verification screen
                          navigator.pushNamed(
                            '/otp-verification',
                            arguments: {
                              'emailOrPhone': email,
                              'isEmail': true,
                              'otpExpirySeconds': 300,
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
                        Funcs.showSnackBar(message: e.toString(), isSuccess: false);
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  child: Text(
                    'Confirm'.tr,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppStyle.appPaddingMd),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resendAndNavigate() async {
    if (selectedVerificationMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a delivery method'.tr)),
      );
      return;
    }

    // Read possible email/phone from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] as String?;
    final phone = args?['phone'] as String? ?? args?['phoneNumber'] as String?;

    String? target;
    String deliveryMethod = 'sms';

    if (selectedVerificationMethod == 'email') {
      target = email;
      deliveryMethod = 'email';
    } else if (selectedVerificationMethod == 'sms') {
      target = phone;
      deliveryMethod = 'sms';
    }

    if (target == null || target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No contact available to send OTP'.tr)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authService.requestOtpLogin(
        emailOrPhone: target,
        deliveryMethod: deliveryMethod,
      );

      if (result['success'] == true) {
        Funcs.showSnackBar(
          message: result['message'] ?? 'OTP resent',
          isSuccess: true,
        );

        // Navigate to OTP verification screen and pass the target
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'emailOrPhone': target,
            'isEmail': deliveryMethod == 'email',
            'otpExpirySeconds': 300,
          },
        );
      } else {
        Funcs.showSnackBar(
          message: result['message'] ?? 'Failed to resend OTP',
          isSuccess: false,
        );
      }
    } catch (e) {
      Funcs.showSnackBar(message: e.toString(), isSuccess: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
