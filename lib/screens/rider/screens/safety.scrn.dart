import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kiliride/screens/rider/screens/pickup_code.scrn.dart';
import 'package:kiliride/screens/rider/screens/trusted_contacts.scrn.dart';
import 'package:kiliride/shared/styles.shared.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.appColor(context),
      appBar: AppBar(
        backgroundColor: AppStyle.appColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Safety',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSafetyOption(
              context: context,
              icon: Icons.security_outlined,
              title: 'Pick-up code',
              subtitle: 'Disabled',
              onTap: () {
                Get.to(
                  () => const PickupCodeScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
            _buildSafetyOption(
              context: context,
              icon: Icons.contact_phone_outlined,
              title: 'Trusted contacts',
              subtitle: 'None added',
              onTap: () {
                Get.to(
                  () => const TrustedContactsScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppStyle.appPadding),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(12),
        //   border: Border.all(
        //     color: Colors.grey[200]!,
        //     width: 1,
        //   ),
        // ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppStyle.inputBackgroundColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: Colors.black87),
            ),
            const SizedBox(width: AppStyle.appPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
