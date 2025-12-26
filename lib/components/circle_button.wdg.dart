import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kiliride/shared/styles.shared.dart';

class CircleButtonWDG extends StatefulWidget {
  final String iconSrc;
  final Function? onTap;
  final Color? color;
  final Color? solidColor;
  final double? size;
  final double? borderRadius;
  final bool? showBorder;
  final double? elevation;
  const CircleButtonWDG({
    super.key,
    required this.iconSrc,
    this.onTap,
    this.color,
    this.size,
    this.solidColor,
    this.borderRadius,
    this.showBorder,
    this.elevation,
  });

  @override
  State<CircleButtonWDG> createState() => _CircleButtonWDGState();
}

class _CircleButtonWDGState extends State<CircleButtonWDG> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius == null
            ? BorderRadius.circular(AppStyle.appRadiusLG)
            : BorderRadius.circular(widget.borderRadius!),
      ),
      elevation: widget.elevation ?? 0,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        height: widget.size ?? AppStyle.buttonHeight,
        width: widget.size ?? AppStyle.buttonHeight,
        decoration: BoxDecoration(
          color:
              widget.solidColor ??
              (widget.color == null
                      ? AppStyle.primaryColor(context)
                      : widget.color ?? AppStyle.primaryColor(context))
                  .withOpacity(0.1),
          shape: widget.borderRadius == null
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: widget.borderRadius == null
              ? null
              : BorderRadius.circular(widget.borderRadius!),
          border: widget.showBorder == true
              ? Border.all(
                  width: 1,
                  color: (widget.color ?? AppStyle.primaryColor(context))
                      .withOpacity(0.1),
                )
              : null,
        ),
        child: IconButton(
          padding: const EdgeInsets.all(6),
          onPressed: widget.onTap == null
              ? null
              : () {
                  widget.onTap!();
                },
          icon: Container(
            width: 25,
            height: 25,
            padding: const EdgeInsets.all(3),
            child: SvgPicture.asset(
              widget.iconSrc,
              color: widget.color == null
                  ? AppStyle.primaryColor(context)
                  : widget.color ?? AppStyle.primaryColor(context),
              width: 25,
              height: 25,
            ),
          ),
        ),
      ),
    );
  }
}
