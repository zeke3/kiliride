import 'package:get/get_utils/src/extensions/internacionalization.dart';

class AppData {
  const AppData();

  static const String appName = 'POA';
  static String get appId => 'poa.appziro.com';
  static String get appVersion => '1.0.0';
  static String get company => 'POA LIMITED';

  // calculate the current year and if current year is great than 2022 then return 2022 - current year else return current year
  static String get copyYear => DateTime.now().year > 2023
      ? '2023 - ${DateTime.now().year}'
      : '${DateTime.now().year}';

static final List slides = [
    {
      "title": "Your Ride, Simplified".tr,
      "subtitle": "Experience the future of transportation with just a tap".tr,
      "imgSrc": "assets/img/splash1.png",
    },
    {
      "title": "Affordable & Reliable".tr,
      "subtitle": "Quality rides at prices that work for you".tr,
      "imgSrc": "assets/img/splash2.png",
    },
    {
      "title": "Book Rides Instantly".tr,
      "subtitle": "Quick pickup right at your doorstep".tr,
      "imgSrc": "assets/img/splash3.png",
    },
  ];
}
