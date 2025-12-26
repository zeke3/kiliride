import 'package:flutter/material.dart';
import 'package:kiliride/shared/styles.shared.dart';

class Loading extends StatelessWidget {
  final Color? color;
  const Loading({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator.adaptive(
          backgroundColor: color ?? AppStyle.primaryColor(context),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
