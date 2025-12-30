import 'package:flutter/material.dart';

class AppStyle {
  // Colors
  static Color heartColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(29, 171, 135, 1) // Light theme
      : const Color.fromRGBO(255, 0, 64, 1.0); // Dark theme

  static Color invertedTextAppColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(13, 13, 13, 1) // Light theme
      : const Color.fromRGBO(255, 255, 255, 1); // Dark the

  static Color circleButtonSolidColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(255, 255, 255, 1) // Light theme
      : const Color.fromRGBO(
          13,
          13,
          13,
          1,
        ).withValues(alpha: 0.8); // Dark theme

  static Color descriptionTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(120, 130, 138, 1) // Light theme color
      : const Color.fromRGBO(80, 90, 98, 1); // Dark theme color


  static Color terminatedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromARGB(255, 168, 50, 50) // Light theme color
      : const Color.fromRGBO(80, 90, 98, 1); // Dark theme color

  static Color draftColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(120, 130, 138, 1) // Light theme color
      : const Color.fromRGBO(80, 90, 98, 1); // Dark theme color

  static Color optionalTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(217, 217, 217, 1) // Light theme color
      : const Color.fromRGBO(80, 90, 98, 1); // Dark theme color


  static Color appColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(255, 255, 255, 1) // Light theme
      : const Color.fromRGBO(13, 13, 13, 1); // Dark theme

  static Color bubbleColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(204, 223, 246, 1.0) // Light theme
      : const Color.fromRGBO(0, 40, 102, 1.0); // Dark theme

  static Color appBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(255, 255, 255, 1) // Light theme
      : const Color.fromRGBO(18, 18, 18, 1); // Dark th
  static Color inputBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(247, 247, 247, 1) // Light theme
      : const Color.fromRGBO(18, 18, 18, 1); // Dark th

  static Color messageBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(255, 255, 255, 1) // Light theme
      : const Color.fromRGBO(25, 25, 25, 1); // Dark th

  static Color textAppColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(255, 255, 255, 1) // Light theme
      : const Color.fromRGBO(255, 255, 255, 1); // D

  static Color appColor2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(255, 255, 255, 1) // Light theme
      : const Color.fromRGBO(27, 28, 31, 1); // Dark theme

  // Original
  // static Color primaryColor(BuildContext context) =>
  //     Theme.of(context).brightness == Brightness.light
  //         ? const Color.fromRGBO(29, 171, 135, 1) // Light theme
  //         : const Color.fromRGBO(39, 68, 122, 1); // Dark theme

  static Color primaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(237, 28, 36, 1) // Light theme
      : const Color.fromRGBO(29, 171, 135, 1); // Dark theme

  // Original
  // static Color textPrimaryColor(BuildContext context) =>
  //     Theme.of(context).brightness == Brightness.light
  //         ? const Color.fromRGBO(29, 171, 135, 1) // Light theme
  //         : const Color.fromRGBO(255, 255, 255, 1); // Dark theme

  static Color textPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(0, 0, 0, 1.0) // Light theme
      : const Color.fromRGBO(255, 255, 255, 1); // Dark theme

  static Color primaryColor2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(85, 170, 255, 1) // Light theme
      : const Color.fromRGBO(87, 100, 222, 1.0); // Dark theme

  //Original
  // static Color secondaryColor(BuildContext context) =>
  //     Theme.of(context).brightness == Brightness.light
  //         ? const Color.fromRGBO(
  //             39, 68, 122, 1) // Light theme (light gray for better contrast)
  //         : const Color.fromRGBO(39, 68, 122, 1); // Dark theme

  static Color secondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color(0xFF14606D) // Light theme (light gray for better contrast)
      : const Color.fromRGBO(0, 40, 102, 1.0);


  static Color textNeutralColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color.fromRGBO(
          237,
          237,
          237,
          1,
        ) // Light theme (light gray for better contrast)
          : const Color.fromRGBO(12, 38, 85, 1).withValues(alpha: 0.9); // Dark theme

  static Color messageSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(
          0,
          40,
          102,
          1.0,
        ) // Light theme (light gray for better contrast)
      : const Color.fromRGBO(
          0,
          40,
          102,
          1.0,
        ).withValues(alpha: 0.9); // Dark theme

  // Original
  // static Color appBarsecondaryColor(BuildContext context) =>
  //     Theme.of(context).brightness == Brightness.light
  //         ? const Color.fromRGBO(
  //             39, 68, 122, 1) // Light theme (light gray for better contrast)
  //         : const Color.fromRGBO(12, 38, 85, 1).withValues(alpha: 0.9); // Dark the

  static Color appBarsecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(
          0,
          40,
          102,
          1.0,
        ) // Light theme (light gray for better contrast)
      : const Color.fromRGBO(12, 38, 85, 1).withValues(alpha: 0.9); // Dark the

  // Original
  static Color dividerColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color.fromRGBO(151, 151, 151, 0.17) // Light theme (light gray for better contrast)
          : const Color.fromRGBO(255, 255, 255, 1); // D

  static Color textSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(
          0,
          40,
          102,
          1.0,
        ) // Light theme (light gray for better contrast)
      : const Color.fromRGBO(255, 255, 255, 1); // D


  static Color specialPinkColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromARGB(
          255,
          253,
          234,
          234,
        ) // Light theme (light gray for better contrast)
      : const Color.fromRGBO(255, 255, 255, 1); // D


  static Color secondaryColorA(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(71, 107, 175, 1.0) // Light theme
      : const Color.fromRGBO(
          50,
          75,
          120,
          1.0,
        ); // Dark theme (slightly darker variation)

  static Color secondaryColorLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(212, 218, 228, 1.0) // Light theme
      : const Color.fromRGBO(
          150,
          155,
          165,
          1.0,
        ); // Dark theme (slightly darker variation)

  static Color secondaryColor2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color(0xFF122040) // Light theme (slightly darker gray)
      : const Color.fromRGBO(7, 59, 94, 1.0); // Dark theme

  static Color secondaryColor3(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(
          20,
          96,
          109,
          1,
        ) // Light theme (soft neutral color)
      : const Color.fromRGBO(29, 88, 171, 1); // Dark theme

  static Color secondaryColor4(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(
          230,
          230,
          235,
          1,
        ) // Light theme (slightly darker than secondaryColor3)
      : const Color.fromRGBO(35, 36, 40, 1); // Dark theme

  static Color secondaryColor5(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(
          228,
          229,
          232,
          1,
        ) // Light theme (darker gray for more contrast)
      : const Color.fromRGBO(55, 58, 64, 1); // Dark theme

  static Color bubbleBgColorMe(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(
          87,
          100,
          222,
          1.0,
        ) // Light theme (darker gray for more contrast)
      : const Color.fromRGBO(87, 100, 222, 1.0); // Dark theme

  static Color bubbleBgColorOther(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(
          245,
          246,
          250,
          1,
        ) // Light theme (darker gray for more contrast)
      : const Color.fromRGBO(38, 43, 46, 1); // Dark theme

  static Color textColored(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(3, 3, 3, 1.0) // Light theme
      : const Color.fromRGBO(255, 255, 255, 1.0); // Dark theme

  static Color textColoredFade(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(91, 93, 122, 1) // Light theme
      : const Color.fromRGBO(149, 155, 163, 1.0); // Dark theme

  static Color textFade(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(151, 151, 151, 1) // Light theme
      : const Color.fromRGBO(149, 155, 163, 1.0); // Dark them

  static Color bgColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? Colors
            .white // Light theme
      : Colors.black; // Dark theme
  static Color inputBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(18, 18, 18, 1) // Light theme
      : const Color.fromRGBO(249, 250, 251, 1); // Dark theme

  static Color activeColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(72, 189, 105, 1) // Light theme
      : const Color.fromRGBO(225, 121, 84, 1); // Dark theme

  static Color pendingColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(254, 188, 47, 1) // Light theme
      : const Color.fromRGBO(225, 121, 84, 1); // Dark theme

  static Color infoColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(58, 151, 212, 1) // Light theme
      : const Color.fromRGBO(58, 151, 212, 1); // Dark theme

  static Color inActiveColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(254, 54, 50, 1) // Light theme
      : const Color.fromRGBO(241, 75, 75, 1); // Dark theme

  static Color errorColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(254, 54, 50, 1) // Light theme
      : const Color.fromRGBO(241, 75, 75, 1); // Dark theme

  // Original
  // static Color successColor(BuildContext context) =>
  //     Theme.of(context).brightness == Brightness.light
  //         ? const Color.fromRGBO(29, 171, 135, 1) // Light theme
  //         : const Color.fromRGBO(45, 125, 90, 1); // Dark theme

  static Color successColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(0, 150, 90, 1.0) // Light theme
      : const Color.fromRGBO(0, 150, 90, 1.0); // Dark theme

  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? Colors.grey[200]! // Light theme
      : const Color.fromRGBO(255, 255, 255, 0.1); // Dark theme
  static Color borderColor2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? Colors.grey[300]! // Light theme
      : const Color.fromRGBO(255, 255, 255, 0.1); // Dark theme

  static Color inputBG(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(247, 247, 249, 1) // Light theme
      : const Color.fromRGBO(18, 18, 18, 1); // Dark theme

  static Color inputBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? Colors.grey[200]! // Light theme
      : const Color.fromRGBO(26, 34, 50, 1); // Dark theme

  static Color textFormField(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(249, 250, 251, 1) // Light theme
      : const Color.fromRGBO(18, 18, 18, 1); // Dark th

  static Color textPurpleColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(71, 64, 94, 1) // Light theme
      : const Color.fromRGBO(255, 255, 255, 1); // Dark th
  static Color grey(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(135, 129, 155, 1) // Light theme
      : const Color.fromRGBO(135, 129, 155, 1); // Dark th
  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(246, 246, 248, 1) // Light theme
      : const Color.fromRGBO(246, 246, 248, 1); // Dark th

  static Color eveMessageBgColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromRGBO(235, 240, 255, 1) // Light theme
      : secondaryColor2(context); // Dark th

  //Food status colors
  static Color foodStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'pending':
      case 'processing':
      case 'preparing':
        return const Color.fromRGBO(221, 152, 56, 1); // Pending color
      case 'ready':
        return const Color.fromRGBO(57, 84, 145, 1); // Accepted color
      case 'cancelled':
        return const Color.fromRGBO(226, 67, 67, 1); // Rejected color
      case 'delivered':
        return const Color.fromRGBO(57, 145, 60, 1); // Rejected color
      default:
        return const Color.fromRGBO(221, 152, 56, 1); // Default color
    }
  }

  static Gradient bubbleGradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? LinearGradient(
          colors: [
            const Color.fromRGBO(57, 61, 94, 1),
            AppStyle.secondaryColor(context),
          ],
          stops: [0.0, 1.0],
        ) // Light theme
      : LinearGradient(
          colors: [
            const Color.fromRGBO(57, 61, 94, 1),
            AppStyle.secondaryColor(context),
          ],
          stops: [0.0, 1.0],
        ); // Dark theme

  static Gradient bubbleGradientMe(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? LinearGradient(
          colors: [
            AppStyle.secondaryColor(context),
            const Color.fromRGBO(74, 0, 224, 1),
          ],
          stops: [0.0, 1.0],
        ) // Light theme
      : LinearGradient(
          colors: [
            AppStyle.secondaryColor(context),
            const Color.fromRGBO(74, 0, 224, 1),
          ],
          stops: [0.0, 1.0],
        ); //

  // other dynamics
  static String notfoundImage(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? "404"
      : "404-dark"; // Dark theme

  static ButtonStyle pendingElevatedButtonStyle(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    Color backgroundColor = isLightTheme
        ? const Color.fromARGB(255, 205, 187, 28) // Light theme background
        : secondaryColor(context); // Dark theme background

    Color foregroundColor = appColor(
      context,
    ); // Consistent foreground color for both themes

    return ElevatedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      disabledBackgroundColor: backgroundColor.withValues(
        alpha: 0.1,
      ), // Disabled state background
      disabledForegroundColor: foregroundColor.withValues(
        alpha: 0.5,
      ), // Disabled state foreground
      elevation: 1.0, // Button elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          appRadius,
        ), // Consistent border radius
      ),
    );
  }

  static const evePrimaryColor = Color.fromRGBO(131, 144, 250, 1);

  // Sizes
  static const double miniAppBarHeight = 100.0;
  static const double appBarHeight = 62.0;
  static const double buttonHeight = 45.0;
  static const double tableRowHeight = 45.0;
  static const double buttonHeightLG = 55.0;
  static const double textFieldHeight = 50.0;
  static const double appFontSize = 16.0;
  static const double appFontSizeSM = 14.0;
  static const double appFontSizeXSM = 12.0;
  static const double appFontSizeXXSM = 10.0;
  static const double appFontSizeLG = 18;
  static const double appFontSizeLLG = 22;
  static const double appFontSizeXLG = 26;
  static const double appFontSizeXXLG = 32;
  static const double appFontSizeMd = 17;
  static const double appPadding = 16.0;
  static const double appPaddingLG = 69;
  static const double appPaddingMd = 69 / 2;
  static const double appPaddingSide = 200;
  static const double appGap = 8.0;
  static const double appGapSM = 6.0;
  static const double appRadius = 8;
  static const double appRadiusSm = 4;
  static const double appRadiusMd = 12;
  static const double appRadiusMid = 15;
  static const double appRadiusLG = 20;
  static const double appRadiusLLG = 30;
  static const double appRadiusXLG = 45;
  static const double inputSVGGap = 12.0;
  static const double leadingIconSize = 40;
  static const double chatBarHeight = 65.0;

  // Button Styles
  static ButtonStyle elevatedButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      foregroundColor: appColor(context),
      backgroundColor: secondaryColor(context),
      disabledBackgroundColor: secondaryColor(context).withValues(alpha: 0.5),
      disabledForegroundColor: appColor(context).withValues(alpha: 0.5),
      elevation: 0.3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius),
      ),
      textStyle: TextStyle(
        fontSize: appFontSizeSM,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static ButtonStyle textButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: primaryColor(context),
      backgroundColor: primaryColor(context).withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius),
      ),
      textStyle: TextStyle(
        fontSize: appFontSizeSM,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static ButtonStyle outlinedButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: textPrimaryColor(context),
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color: textPrimaryColor(context).withValues(alpha: 0.5),
        width: 1,
      ),
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius),
      ),
      textStyle: TextStyle(
        fontSize: appFontSizeSM,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // Themes
  static ThemeData getLightTheme({required BuildContext context}) {
    return ThemeData(
      appBarTheme: const AppBarTheme(elevation: 0),
      useMaterial3: true,
      fontFamily: "Gilroy",
      fontFamilyFallback: const <String>[
        "Gilroy",
        "EmojiFont",
      ], // Fallback fonts
      brightness: Brightness.light,
      primaryColor: primaryColor(context),
      scaffoldBackgroundColor: bgColor(context),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: elevatedButtonStyle(context),
      ),

      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: appPadding,
        ),
        isDense: true,
        filled: false,
        fillColor: inputBG(context),
        hintStyle: TextStyle(color: textColoredFade(context)),
        labelStyle: TextStyle(color: textColoredFade(context)),
        suffixIconColor: textColoredFade(context).withValues(alpha: 0.6),
        prefixIconColor: textColoredFade(context).withValues(alpha: 0.6),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(appRadius)),
          borderSide: BorderSide(
              color: Color.fromRGBO(223, 225, 231, 1),
              width: 1), // Removes the underline border
          // borderSide: BorderSide.none, // Removes the underline border
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(appRadius)),
          borderSide: BorderSide(
            color: Color.fromRGBO(223, 225, 231, 1),
            width: 1,
          ),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(appRadius)),
          borderSide: BorderSide.none,
        ),
        focusedBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(appRadius)),
          // borderSide: BorderSide(color: primaryColor(context), width: 1),
          borderSide: BorderSide(
            color: secondaryColor2(context),
            width: 1,
          ),
        ),
        errorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(appRadius)),
          borderSide: BorderSide(color: errorColor(context), width: 1),
          // borderSide: BorderSide.none,
        ),
        focusedErrorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(appRadius)),
          borderSide: BorderSide(color: errorColor(context), width: 1),
          // borderSide: BorderSide.none,
        ),
      ),
      colorScheme: ColorScheme.light(primary: primaryColor(context)),
    );
  }

  static ThemeData getDarkTheme({required BuildContext context}) {
    return ThemeData(
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Gilroy'),
      primaryTextTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Gilroy',
      ),
      useMaterial3: true,
      fontFamily: "Gilroy", // Set your custom font family here
      fontFamilyFallback: const <String>[
        "Gilroy",
        "EmojiFont",
      ], // Fallback fonts
      brightness: Brightness.dark,
      primaryColor: primaryColor(context),
      scaffoldBackgroundColor: bgColor(context),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: elevatedButtonStyle(context),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: appPadding,
        ),
        // filled: true,
        isDense: true,
        fillColor: inputBg(context),
        hintStyle: TextStyle(
          color: textColoredFade(context),
          fontSize: appFontSize,
        ),
        labelStyle: TextStyle(color: textColoredFade(context)),
        suffixIconColor: textColoredFade(context).withValues(alpha: 0.6),
        prefixIconColor: textColoredFade(context).withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppStyle.appRadius,
          ), // Adjust the border radius as needed
          borderSide: const BorderSide(
            color: Colors.transparent, // Default color for the border
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyle.appRadius),
          borderSide: BorderSide(
            color: AppStyle.secondaryColor(
              context,
            ), // Change this to your desired focus color
            width: 1.0, // Adjust the thickness as needed
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyle.appRadius),
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.5), // Default border color
            width: 0.3,
          ),
        ),
        filled: true,
        // fillColor: AppStyle.appBackgroundColor(context),
        // border: const OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(appRadius)),
        //   borderSide: BorderSide.none, // Removes the underline border
        // ),
        // enabledBorder: const OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(appRadius)),
        //   borderSide: BorderSide.none,
        // ),
        // focusedBorder: OutlineInputBorder(
        //   borderRadius: const BorderRadius.all(Radius.circular(appRadius)),
        //   borderSide: BorderSide(color: secondaryColor(context), width: 2),
        // ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(appRadius)),
          borderSide: BorderSide(color: errorColor(context), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(appRadiusMd)),
          borderSide: BorderSide(color: errorColor(context), width: 2),
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: AppStyle.primaryColor(
          context,
        ), // Custom dark theme primary color
      ),
    );
  }

  // TextStyle for form fields
  static TextStyle fieldTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: appFontSizeMd,
      color: textColored(context).withValues(alpha: 0.9),
      fontWeight: FontWeight.w500,
    );
  }

  // JSON style for the grayscale map
  static String mapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi.business",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e0e0e0"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#d5d5d5"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
      },
      {
        "featureType": "transit.station",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e0e0e0"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      }
    ]
  ''';

  static String darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#ffffff"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "administrative.country",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    },
    {
      "featureType": "administrative.land_parcel",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#bdbdbd"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "poi.business",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#181818"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#1b1b1b"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [
        {
          "color": "#2c2c2c"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#8a8a8a"
        }
      ]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#373737"
        }
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#3c3c3c"
        }
      ]
    },
    {
      "featureType": "road.highway.controlled_access",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#4e4e4e"
        }
      ]
    },
    {
      "featureType": "road.local",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#000000"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#3d3d3d"
        }
      ]
    }
  ]
''';

  // static String hdarkMapStyle = '''[
  //   {
  //     "elementType": "geometry",
  //     "stylers": [
  //       {
  //         "color": "#242f3e"
  //       }
  //     ]
  //   },
  //       {
  //     "featureType": "poi",
  //     "elementType": "geometry",
  //     "stylers": [
  //       {"color": "#2c3e50"}
  //     ]
  //   },
  //   {
  //     "elementType": "labels.text.fill",
  //     "stylers": [
  //       {
  //         "color": "#ffffff"
  //       }
  //     ]
  //   },
  //   {
  //     "elementType": "labels.text.stroke",
  //     "stylers": [
  //       {
  //         "color": "#242f3e"
  //       }
  //     ]
  //   },
  //   {
  //     "featureType": "water",
  //     "elementType": "geometry",
  //     "stylers": [
  //       {
  //         "color": "#17263c"
  //       }
  //     ]
  //   },
  //   {
  //     "featureType": "road",
  //     "elementType": "geometry",
  //     "stylers": [
  //       {
  //         "color": "#38414e"
  //       }
  //     ]
  //   }
  // ]''';
}
