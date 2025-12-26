import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/providers/providers.dart';
import 'package:kiliride/screens/authentication/forgot_password.scrn.dart';
import 'package:kiliride/screens/authentication/otp_selection_method.scrn.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _authService = AuthService.instance;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
        ref: ref,
      );

      if (mounted) {
        if (result['success']) {
          Funcs.showSnackBar(
            message: result['message'] ?? 'Login successful!',
            isSuccess: true,
          );

          // Extract user data to determine email and phone
          final userData = result['data']?['user'];
          final email = userData?['email'] as String?;
          final phone = userData?['phone_number'] as String?;

          var userType = ref.read(userInfoProvider).user?.userType ?? 'client';

          if(userType == 'sales_agent'){
            // Navigate to Sales Navigation Screen
            Navigator.pushReplacementNamed(context, '/sales-navigation');
            return;
          } else if(userType == 'provider'){
            // Navigate to Provider Navigation Screen
            Navigator.pushReplacementNamed(context, '/provider-navigation');
            return;
          } else if(userType == 'client'){

            Navigator.pushReplacementNamed(context, '/client-navigation');
            
          }
        } else {
          Funcs.showSnackBar(
            message: result['message'] ?? 'Login failed',
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: AppStyle.appPadding),
                    _loginForm(),

                    SizedBox(height: AppStyle.appPadding + 4),


                    Row(
                      children: [
                        Expanded(child: Divider(
                          endIndent: AppStyle.appPadding,
                          color: AppStyle.dividerColor(context))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Or'.tr, style: TextStyle(
                            color: AppStyle.descriptionTextColor(context),
                            fontSize: AppStyle.appFontSize,
                            fontWeight: FontWeight.w400,
                          ),),
                        ),
                        Expanded(
                          child: Divider(
                          endIndent: AppStyle.appPadding,
                            
                            color: AppStyle.dividerColor(context)),
                        ),

                      ],
                    ),
                    SizedBox(height: AppStyle.appPadding + 4),

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        // style: AppStyle.elevatedButtonStyle(context).copyWith(
                        //   backgroundColor: WidgetStateProperty.all<Color>(
                        //     AppStyle.secondaryColor2(context),
                        //   ),
                        //   padding: WidgetStateProperty.all<EdgeInsets>(
                        //     EdgeInsets.symmetric(
                        //       horizontal: AppStyle.appPadding,
                        //       vertical: AppStyle.appPadding,
                        //     ),
                        //   ),
                        //   shape:
                        //       WidgetStateProperty.all<RoundedRectangleBorder>(
                        //         RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(
                        //             AppStyle.appRadiusMd,
                        //           ),
                        //         ),
                        //       ),
                        // ),
                        onPressed: _isLoading ? null : (){
                                      Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OtpSelectionScreen(
                                      isRegistration: false,
                                      loginWithOtp: true,
                                    ),
                                    settings: RouteSettings(
                                      arguments: {
                                        'loginWithOtp': true,
                                      },
                                    ),
                                  ),
                                );
                        },
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
                                'Login with OTP'.tr,
                                style: TextStyle(
                                  fontSize: AppStyle.appFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: AppStyle.appPadding + 4),

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
                            "Register as a client".tr,
                            style: TextStyle(
                              color: AppStyle.primaryColor(context),
                              fontSize: AppStyle.appFontSizeSM,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ADD NOTE BELOW
                    const SizedBox(height: AppStyle.appPadding),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppStyle.appPadding * 2),
                      child: Text(
                        "Note: Registration is only available for client accounts. For sales agent or provider accounts, please contact AIT.".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppStyle.descriptionTextColor(context),
                          fontSize: AppStyle.appFontSizeSM,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    // SizedBox(height: AppStyle.appPadding),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.pushReplacementNamed(
                    //       context,
                    //       '/client-navigation',
                    //     );
                    //   },
                    //   child: Text('Go to Client Home'.tr),
                    // ),
                    // SizedBox(height: AppStyle.appPadding),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.pushReplacementNamed(
                    //       context,
                    //       '/provider-navigation',
                    //     );
                    //   },
                    //   child: Text('Go to Provider Home'.tr),
                    // ),

                    // SizedBox(height: AppStyle.appPadding),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.pushReplacementNamed(
                    //       context,
                    //       '/sales-navigation',
                    //     );
                    //   },
                    //   child: Text('Go to Sales Home'.tr),
                    // ),
                  
                  ],
                ),

                const SizedBox(height: AppStyle.appPadding),

                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.end,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text(
                //       "Go to verification screen".tr,
                //       style: TextStyle(
                //         color: AppStyle.descriptionTextColor(context),
                //         fontSize: AppStyle.appFontSizeSM,
                //         fontWeight: FontWeight.w400,
                //       ),
                //     ),
                //     const SizedBox(width: AppStyle.appGap),
                //     GestureDetector(
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) =>
                //                 BiometricSelectionScreen(isRegistration: false),
                //           ),
                //         );
                //       },
                //       child: Text(
                //         "Verification".tr,
                //         style: TextStyle(
                //           color: AppStyle.primaryColor(context),
                //           fontSize: AppStyle.appFontSizeSM,
                //           fontWeight: FontWeight.w400,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
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
            bottom: AppStyle.appPaddingLG,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login to your account'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeXLG,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.textNeutralColor(context),
                  ),
                ),

                Text(
                  'Sign in to access your health cover and benefits'.tr,
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

  Widget _loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Username",
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              TextFormField(
                controller: usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'john@gmail.com or 0655443322'.tr,
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
                "Password",
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
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ForgotPasswordScreen();
                    },
                  ),
                );
              },
              child: Text(
                'Forgot Password?'.tr,
                style: TextStyle(
                  color: AppStyle.errorColor(context),
                  fontSize: AppStyle.appFontSizeSM,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
                  ),
                ),
              ),
              onPressed: _isLoading ? null : _handleLogin,
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
                      'Login'.tr,
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
