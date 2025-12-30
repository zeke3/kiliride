import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kiliride/shared/styles.shared.dart';

class TextFieldTitle extends StatefulWidget {
  final String value;
  final Color? color;
  final FontStyle? fontStyle;
  const TextFieldTitle({
    super.key,
    required this.value,
    this.color,
    this.fontStyle,
  });

  @override
  State<TextFieldTitle> createState() => _TextFieldTitleState();
}

class _TextFieldTitleState extends State<TextFieldTitle> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyle.appGap),
      child: Text(
        widget.value.tr,
        style: TextStyle(
          fontSize: AppStyle.appFontSize,
          color: widget.color ?? AppStyle.textColored(context).withOpacity(0.9),
          fontWeight: FontWeight.w500,
          fontStyle: widget.fontStyle,
        ),
      ),
    );
  }
}
