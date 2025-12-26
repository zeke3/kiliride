import 'package:flutter/material.dart';
import 'package:kiliride/components/custom_avatr_comp.dart';
import 'package:kiliride/shared/styles.shared.dart';

class CustomTile extends StatelessWidget {
  final Widget leadingWidget;
  final Widget titleWidget;
  final Widget subtitleWidget;
  final Widget? trailingWidget;
  final bool showAllBorders;
  final void Function()? onTap;

  const CustomTile({super.key, required this.leadingWidget, required this.titleWidget, required this.subtitleWidget, this.trailingWidget, this.showAllBorders = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: showAllBorders ?
          Border.all(
            color: AppStyle.borderColor(context),
          )
          :
           Border(
            bottom: BorderSide(color: AppStyle.borderColor(context)),
          ),
        ),
        padding: const EdgeInsets.only(
          bottom: AppStyle.appPadding + 4,
          top: AppStyle.appPadding + 4,
        ),
        child: Row(
          children: [
            leadingWidget,
            const SizedBox(width: AppStyle.appPadding + AppStyle.appGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget,
                  const SizedBox(height: AppStyle.appGap),
                  subtitleWidget,
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              const SizedBox(width: AppStyle.appPadding),
              trailingWidget!,
            ]
          ],
        ),
      ),
    );;
  }
}