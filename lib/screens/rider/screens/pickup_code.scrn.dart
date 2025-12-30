import 'package:flutter/material.dart';
import 'package:kiliride/shared/styles.shared.dart';

class PickupCodeScreen extends StatefulWidget {
  const PickupCodeScreen({super.key});

  @override
  State<PickupCodeScreen> createState() => _PickupCodeScreenState();
}

class _PickupCodeScreenState extends State<PickupCodeScreen> {
  bool _isEnabled = false;

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
          'Pick-up code',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureItem(
              'Verify each trip by matching a unique code with your driver',
            ),
            const SizedBox(height: 20),
            _buildFeatureItem(
              'Feel safer knowing you\'re in the right vehicle with the right driver',
            ),
            const SizedBox(height: 20),
            _buildFeatureItem(
              'Prevent someone else from taking your ride by mistake',
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppStyle.inputBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enable pick-up code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Switch(
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isEnabled = value;
                      });
                    },
                    activeTrackColor: AppStyle.primaryColor(context),
                    activeThumbColor: Colors.white,
                    inactiveThumbColor: AppStyle.textColoredFade(context),
                    inactiveTrackColor: AppStyle.textColoredFade(
                      context,
                    ).withValues(alpha: 0.2),
                    trackOutlineColor: WidgetStateProperty.all(
                      Colors.transparent
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Icon(
            Icons.check,
            color: AppStyle.primaryColor(context),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
