import 'package:flutter/material.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget {
  final Color? color;
  const Loading({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // color: Color.fromRGBO(237, 28, 36, 1),
        // height: 150,
        // width: 150,
        child: Lottie.asset(
          'assets/lottie/kililoading.json',
          height: 150,
          width: 150,
          fit: BoxFit.contain,
          repeat: true,
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(
                const ['**'],
                value: color ?? AppStyle.primaryColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
