import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _authService = AuthService.instance;

  TextEditingController membershipIdController = TextEditingController();
  TextEditingController policyController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isPasswordVisible = false;
  bool haveAgreedTermsAndConditions = false;
  bool _isLoading = false;
  PhoneNumber? _phoneNumber;

  @override
  void dispose() {
    membershipIdController.dispose();
    policyController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!haveAgreedTermsAndConditions) {
      Funcs.showSnackBar(
        message: 'Please agree to the Terms & Conditions',
        isSuccess: false,
      );
      return;
    }

    if (_phoneNumber == null) {
      Funcs.showSnackBar(
        message: 'Please enter a valid phone number',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.registerUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phoneNumber: _phoneNumber!.international,
      );

      if (mounted) {
        if (result['success']) {
          Funcs.showSnackBar(
            message: result['message'] ?? 'Registration successful!',
            isSuccess: true,
          );

          // Navigate to OTP verification screen
          // You can pass email or phone for verification
          Navigator.pushReplacementNamed(
            context,
            '/otp-verification',
            arguments: {
              'emailOrPhone': emailController.text.trim(),
              'isEmail': true,
              'otpExpirySeconds': 300,
              'isRegistration': true,
            },
          );
          
        } else {
          Funcs.showSnackBar(
            message: result['message'] ?? 'Registration failed',
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
    return Scaffold(
      body: _signupAppBar(),
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
                children: [
                  const SizedBox(height: AppStyle.appPadding),
                  _signupForm(),
                ],
              ),
              const SizedBox(height: AppStyle.appPadding),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?".tr,
                    style: TextStyle(
                      color: AppStyle.descriptionTextColor(context),
                      fontSize: AppStyle.appFontSizeSM,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: AppStyle.appGap),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      "Login".tr,
                      style: TextStyle(
                        color: AppStyle.primaryColor(context),
                        fontSize: AppStyle.appFontSizeSM,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyle.appPaddingMd),
            ],
          ),
        ),
      ),
    );
  }

  // =================== WIDGETS===================
  Widget _signupAppBar() {
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
            bottom: AppStyle.appPaddingLG,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeXLG,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.textNeutralColor(context),
                  ),
                ),

                Text(
                  'Join us to get the best insurance services'.tr,
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

  Widget _signupForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "First Name".tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              TextFormField(
                controller: firstNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a valid first name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'John'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadius),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyle.appPadding),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Last Name".tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              TextFormField(
                controller: lastNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a valid last name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Doe'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadius),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyle.appPadding),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Phone Number".tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              PhoneFormField(
                initialValue: PhoneNumber.parse('+255'),
                decoration: const InputDecoration(
                  hintText: '712 345 678',
                  border: OutlineInputBorder(),
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
            ],
          ),
          SizedBox(height: AppStyle.appPadding),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Email".tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              TextFormField(
                controller: emailController,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'liberatus.john@ait.co.tz'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadius),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyle.appPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Password".tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              TextFormField(
                controller: passwordController,
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
                  hintText: 'Enter your password'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadius),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !isPasswordVisible,
              ),
            ],
          ),
          SizedBox(height: AppStyle.appPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Confirm your password".tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              TextFormField(
                controller: confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Confirm your password'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadius),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !isPasswordVisible,
              ),
            ],
          ),
          SizedBox(height: AppStyle.appPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: haveAgreedTermsAndConditions,
                onChanged: (value) {
                  setState(() {
                    haveAgreedTermsAndConditions =
                        !haveAgreedTermsAndConditions;
                  });
                },
              ),
              const SizedBox(width: AppStyle.appGap),
              Text(
                "I agree to the".tr,
                style: TextStyle(
                  color: AppStyle.invertedTextAppColor(context),
                  fontWeight: FontWeight.w500,
                  fontSize: AppStyle.appFontSizeSM,
                ),
              ),
              const SizedBox(width: AppStyle.appGap / 2),
              Text(
                "Terms & Conditions".tr,
                style: TextStyle(
                  color: AppStyle.primaryColor(context),
                  fontWeight: FontWeight.w500,
                  fontSize: AppStyle.appFontSizeSM,
                ),
              ),
            ],
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
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
                  ),
                ),
              ),
              onPressed: _isLoading ? null : _handleSignup,
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
                      'Create Account'.tr,
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
