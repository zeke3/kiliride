import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kiliride/components/custom_avatr_comp.dart';
import '../../../shared/styles.shared.dart';
import 'driver.full_profile.pg.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  // Sample data - replace with actual user data
  final String _userName = "Kassa Mwema";
  final String _userAvatar = ""; // TODO: Replace with actual avatar URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.appBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppStyle.appColor(context),
        elevation: 0,
        title: Text(
          'Settings'.tr,
          style: TextStyle(
            fontSize: AppStyle.appFontSizeLG,
            fontWeight: FontWeight.w600,
            color: AppStyle.textPrimaryColor(context),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: AppStyle.appColor(context),
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyle.appPadding,
                vertical: AppStyle.appPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: AppStyle.appFontSizeXLG,
                            fontWeight: FontWeight.w700,
                            color: AppStyle.textPrimaryColor(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {

                            Get.to(() => const DriverFullProfilePage(), transition: Transition.rightToLeftWithFade, duration: const Duration(milliseconds: 300));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View profile'.tr,
                                style: TextStyle(
                                  fontSize: AppStyle.appFontSizeSM,
                                  fontWeight: FontWeight.w500,
                                  color: AppStyle.textPrimaryColor(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: AppStyle.textPrimaryColor(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Avatar
                  if(_userAvatar.isNotEmpty)
                    CustomAvatar(
                      imageURL: _userAvatar,
                      size: 80,
                      fullName: "Kassa Mwema",
                    )
                  else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppStyle.inputBackgroundColor(context),
                      border: Border.all(
                        color: AppStyle.borderColor(context),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppStyle.descriptionTextColor(context),
                          )
                        ,
                  ),
                ],
              ),
            ),


            // Menu Items
            Container(
              color: AppStyle.appColor(context),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Documents'.tr,
                    onTap: () {
                      // TODO: Navigate to documents page
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.directions_car_outlined,
                    title: 'Vehicles'.tr,
                    onTap: () {
                      // TODO: Navigate to vehicles page
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payments'.tr,
                    onTap: () {
                      // TODO: Navigate to payments page
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Places'.tr,
                    onTap: () {
                      // TODO: Navigate to saved places page
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.tune,
                    title: 'Driver Preferences'.tr,
                    onTap: () {
                      // TODO: Navigate to driver preferences page
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.phone_outlined,
                    title: 'Emergency Contacts'.tr,
                    onTap: () {
                      // TODO: Navigate to emergency contacts page
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyle.appPadding,
                vertical: AppStyle.appPadding,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    _handleLogout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDE8E8),
                    foregroundColor: const Color(0xFFED1C24),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadiusLG),
                    ),
                  ),
                  child: Text(
                    'Logout'.tr,
                    style: const TextStyle(
                      fontSize: AppStyle.appFontSizeMd,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'.tr),
          content: Text('Are you sure you want to logout?'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFED1C24),
              ),
              child: Text('Logout'.tr),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // TODO: Implement logout logic
      // 1. Clear tokens from secure storage
      // 2. Clear user data
      // 3. Navigate to login screen
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.appPadding,
          vertical: 18,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppStyle.textPrimaryColor(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeMd,
                  fontWeight: FontWeight.w500,
                  color: AppStyle.textPrimaryColor(context),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: AppStyle.descriptionTextColor(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: AppStyle.appPadding + 40),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppStyle.borderColor(context),
      ),
    );
  }
}
