import 'package:flutter/material.dart';

enum SnackBarType { error, info, warning, success }

void showSnackBar(
  BuildContext context,
  String text, {
  SnackBarType type = SnackBarType.success,
  Color? backgroundColor,
}) {
  switch (type) {
    case SnackBarType.success:
    case SnackBarType.error:
    case SnackBarType.info:
      backgroundColor = Colors.grey[100];
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.yellow;
      break;
  }
  final snackBar = SnackBar(
    backgroundColor: backgroundColor,
    elevation: 0.0,
    padding: const EdgeInsets.all(15.0),
    behavior: SnackBarBehavior.floating,
    content: Row(
      children: [
        if (type == SnackBarType.success)
          Icon(Icons.check_circle, color: Color(0xff6247BA)),
        if (type == SnackBarType.info)
          Icon(Icons.info, color: Color(0xff000000)),
        if (type == SnackBarType.error)
          Icon(Icons.cancel, color: Color(0xffD52923)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
