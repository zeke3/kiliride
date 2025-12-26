import 'package:kiliride/shared/styles.shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CustomMiniAppAppbar extends StatefulWidget {
  final String? title;
  final Widget? child;
  final bool isScreen;
  final List<Widget>? actions;
  final Padding? leading;
  const CustomMiniAppAppbar({
    super.key,
    this.title,
    this.child,
    required this.isScreen,
    this.actions,
    this.leading,
  });

  @override
  State<CustomMiniAppAppbar> createState() => _CustomMiniAppAppbarState();
}

class _CustomMiniAppAppbarState extends State<CustomMiniAppAppbar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/gifs/sas_mobile3.gif",
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.2),
          colorBlendMode: BlendMode.darken,
        ),
        Container(
          decoration: BoxDecoration(
            // image: const DecorationImage(
            //   image: AssetImage('assets/img/pattern.png'),
            //   fit: BoxFit.cover,
            // ),
            color: Colors.transparent,
            // borderRadius: const BorderRadius.only(
            //   bottomLeft: Radius.circular(AppStyle.appRadiusLG),
            //   bottomRight: Radius.circular(AppStyle.appRadiusLG),
            // ),
          ),
          child: widget.child == null
              ? AppBar(
                  surfaceTintColor: AppStyle.appBarsecondaryColor(context),
                  toolbarHeight: 100,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leading:
                      widget.leading ??
                      (widget.isScreen
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: SvgPicture.asset(
                                  "assets/icons/arrow_left.svg",
                                  color: Colors.white,
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                            )
                          : null),
                  backgroundColor: Colors.transparent,
                  title: widget.title != null
                      ? Text(
                          widget.title!.tr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(1),
                            fontSize: AppStyle.appFontSizeLG,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                        )
                      : null,
                  centerTitle: false,
                  actions: [if (widget.actions != null) ...widget.actions!],
                )
              : widget.child!,
        ),
      ],
    );
  }
}
