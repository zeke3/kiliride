import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/shared/styles.shared.dart';

class SuccessSubmissionScreen extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String title;
  final String? subtitle;

  const SuccessSubmissionScreen({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppStyle.appPadding),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(icon,  height: 80),
              const SizedBox(height: AppStyle.appPaddingMd),
              Text(
                title.tr,
                style: TextStyle(
                  color: AppStyle.secondaryColor2(context),
                  fontWeight: FontWeight.w700,
                  fontSize: AppStyle.appFontSizeLLG,
                ),
              ),
              Text(
                subtitle?.tr ?? '',
                style: TextStyle(
                  color: Color.fromRGBO(151, 151, 151, 1),
                  fontWeight: FontWeight.w400,
                  fontSize: AppStyle.appFontSizeSM,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppStyle.appPaddingLG),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    
                  },
                  style:AppStyle.elevatedButtonStyle(context).copyWith(
                    backgroundColor: WidgetStateProperty.all<Color>(AppStyle.primaryColor(context)),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: AppStyle.appPadding),
                    ),
                  ),
                  child: Text(
                    'Done'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppStyle.appFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppStyle.appPadding),
            ],
          ),
        ),
      ),
    );
  }
}
