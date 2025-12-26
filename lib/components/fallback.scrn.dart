import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/shared/styles.shared.dart';

class FallBackScreen extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String title;
  final String? subtitle;

  const FallBackScreen({super.key, required this.icon, required this.iconColor, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon, color: iconColor, height: 80,),
          const SizedBox(height: AppStyle.appPadding,),
          Text(title.tr, style:TextStyle(
            color: AppStyle.secondaryColor2(context),
            fontWeight: FontWeight.w700,
            fontSize: AppStyle.appFontSizeMd + 2
          )),
          Text(subtitle?.tr ?? '', style:TextStyle(
            color: Color.fromRGBO(151, 151, 151, 1),
            fontWeight: FontWeight.w400,
            fontSize: AppStyle.appFontSizeSM
          ),
          textAlign: TextAlign.center,
          )
        ]
      )
    );
  }
}
