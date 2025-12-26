// Custom Info Tile Widget
import 'package:flutter/material.dart';
import 'package:kiliride/shared/styles.shared.dart';

class CustomInfoTile extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onActionPressed;

  const CustomInfoTile({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppStyle.appPadding, vertical: AppStyle.appGap ),
      decoration: BoxDecoration(
        color: Colors.black87,
        // borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onActionPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyle.appRadius),
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
