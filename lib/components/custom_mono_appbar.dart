import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/components/back_button.dart';
import 'package:kiliride/shared/styles.shared.dart';

class CustomMonoAppBar extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final bool isScreen;
  final Color? color;
  final Color? backGroundColor;
  const CustomMonoAppBar({
    super.key,
    required this.title,
    this.isScreen = false,
    this.actions,
    this.color,
    this.backGroundColor
  });

  @override
  State<CustomMonoAppBar> createState() => _CustomMonoAppBarState();
}

class _CustomMonoAppBarState extends State<CustomMonoAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: widget.backGroundColor,
      leading: CustomBackButton(),
      title: Text(
        widget.title.tr,
        style: TextStyle(
          fontSize: AppStyle.appFontSizeMd,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      actions: widget.actions,
    );
  }
}
