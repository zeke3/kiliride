import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/models/user.model.dart';
import 'package:kiliride/shared/styles.shared.dart';

class PhoneNumberRequiredBottomSheet extends StatelessWidget {
  final UserModel? userModel;

  const PhoneNumberRequiredBottomSheet({super.key, this.userModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.appColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppStyle.appRadiusMd),
          topRight: Radius.circular(AppStyle.appRadiusMd),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppStyle.appPadding,
          right: AppStyle.appPadding,
          top: AppStyle.appPadding,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppStyle.appPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppStyle.appPadding),

            // Icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppStyle.primaryColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/phone_icon.svg',
                    color: AppStyle.primaryColor(context),
                    height: 24,
                    width: 24,
                  ),
                ),
                const SizedBox(width: AppStyle.appPadding),
                Expanded(
                  child: Text(
                    'Phone Number Required'.tr,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSizeLG,
                      fontWeight: FontWeight.bold,
                      color: AppStyle.invertedTextAppColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyle.appPadding),

            // Description
            Text(
              'To post a job, you need a phone number in your profile. This allows employees to contact you directly when they get hired at your job positions.'.tr
                  .tr,
              style: TextStyle(
                fontSize: AppStyle.appFontSize,
                color: AppStyle.textColored(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppStyle.appPaddingMd),

            // Buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    style: AppStyle.outlinedButtonStyle(context).copyWith(
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          vertical: AppStyle.appPadding,
                        ),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppStyle.appRadiusMd,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel'.tr,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppStyle.appPadding),

                // Edit Profile button
                Expanded(
                  child: ElevatedButton(
                    style: AppStyle.elevatedButtonStyle(context).copyWith(
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          vertical: AppStyle.appPadding,
                        ),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppStyle.appRadiusMd,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      // Close the bottom sheet first
                      Navigator.pop(context);

                      // Navigate to edit profile
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => UserFormBottomSheet(
                      //       user: userModel,
                      //       onSubmit: (isLoading) {
                      //         // Handle loading state if needed
                      //       },
                      //     ),
                      //   ),
                      // );
                    },
                    child: Text(
                      'Edit Profile'.tr,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSize,
                        fontWeight: FontWeight.w500,
                        color: AppStyle.textAppColor(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyle.appPadding),
          ],
        ),
      ),
    );
  }
}
