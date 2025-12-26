import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kiliride/shared/styles.shared.dart';

class CustomBackButton extends StatelessWidget {
  final bool shouldReload;
  final Color? color;
  final bool hasPadding;
  const CustomBackButton({super.key, this.shouldReload = false, this.color, this.hasPadding = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppStyle.appGap),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context, shouldReload);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color ?? AppStyle.borderColor(context)),
            borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
          ),
          padding: hasPadding ? EdgeInsets.symmetric(horizontal: AppStyle.appGap - 1, vertical: AppStyle.appGap / 2) : EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppStyle.appGap + 2),
            child: SvgPicture.asset(
              'assets/icons/arrow_back_ios.svg',
              color: color ?? AppStyle.invertedTextAppColor(context),
            ),
          ),
        ),
      ),
    );
  }
}
