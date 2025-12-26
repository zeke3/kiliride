import 'package:flutter/material.dart';
import 'package:kiliride/shared/styles.shared.dart';

class CustomAppBar extends StatefulWidget {
  final Widget? stackCard;
  final double? prefferedSize;
  final String? decorationImage;
  final double? decorationImageScale;
  final AlignmentGeometry? decorationImageAlignment;
  final Widget? topChild;
  final Widget? centerChild;
  final Widget? bottomChild;
  final Color? gradientColor1;
  final Color? gradientColor2;
  final Color? gradientColor3;
  const CustomAppBar({
    super.key,
    this.topChild,
    this.centerChild,
    this.bottomChild,
    this.gradientColor1,
    this.gradientColor2,
    this.gradientColor3,
    this.decorationImage,
    this.decorationImageScale,
    this.decorationImageAlignment,
    this.prefferedSize = kToolbarHeight,
    this.stackCard,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            image: widget.decorationImage != null
                ? DecorationImage(
                    scale: widget.decorationImageScale ?? 1.0,
                    alignment: widget.decorationImageAlignment ?? Alignment.center,
                    image: AssetImage(widget.decorationImage!),
                  )
                : null,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppStyle.appRadiusLLG),
              bottomRight: Radius.circular(AppStyle.appRadiusLLG),
            ),
            gradient:
                ((widget.gradientColor1 != null && widget.gradientColor2 != null) ||
                    (widget.gradientColor3 != null &&
                        widget.gradientColor2 != null) ||
                    (widget.gradientColor1 != null &&
                        widget.gradientColor3 != null))
                ? LinearGradient(
                    begin: AlignmentGeometry.topLeft,
                    end: AlignmentGeometry.bottomRight,
                    colors: [
                      if (widget.gradientColor1 != null) widget.gradientColor1!,
                      if (widget.gradientColor2 != null) widget.gradientColor2!,
                      if (widget.gradientColor3 != null) widget.gradientColor3!,
                    ],
                  )
                : null,
          ),
          padding: EdgeInsets.symmetric(horizontal: AppStyle.appPadding, vertical: AppStyle.appPadding),
          child: SafeArea(
            child: Container(
              height: widget.prefferedSize,
              child: Column(children: [
                widget.topChild ?? const SizedBox.shrink(),
                if(widget.topChild != null) SizedBox(height: AppStyle.appPadding + AppStyle.appGap),
                widget.centerChild ?? const SizedBox.shrink(),
                if (widget.centerChild != null)
                    SizedBox(height: AppStyle.appPadding + AppStyle.appGap),
                widget.bottomChild ?? const SizedBox.shrink(),
                // if (widget.bottomChild != null)
                //     SizedBox(height: AppStyle.appGap),
              ],),
            ),
          ),
        ),
      if(widget.stackCard != null)
      Positioned(
          bottom: -AppStyle.appPaddingLG - AppStyle.appPadding,
          left: AppStyle.appPadding,
          right: AppStyle.appPadding,
          child: widget.stackCard!,
        ),
      ],
    );
  }
}
