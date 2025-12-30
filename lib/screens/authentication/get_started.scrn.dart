import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/screens/rider/pages/rider.home.pg.dart';
import 'package:kiliride/shared/data.shared.dart';
import 'package:kiliride/shared/styles.shared.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  int currentIndex = 0;
  late PageController _pageController;
  Timer? _timer;
  bool _userInteracting = false;
  late int _initialPage;

  @override
  void initState() {
    super.initState();
    final length = AppData.slides.length;
    _initialPage = 1000 * length;
    _pageController = PageController(initialPage: _initialPage);
    _startAutoSlide();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness:
            Brightness.dark, // Keep as dark for status bar (adjust if needed)
        systemNavigationBarIconBrightness:
            Brightness.light, // Changed to light for white nav bar icons
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted || _userInteracting) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  void _pauseAutoSlide() {
    _userInteracting = true;
    _timer?.cancel();
  }

  void _resumeAutoSlide() {
    _userInteracting = false;
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 10,
      width: currentIndex == index ? 30 : 10,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: currentIndex == index
            ? Colors.white
            : AppStyle.borderColor(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final length = AppData.slides.length;

    return Scaffold(
      // backgroundColor: AppStyle.appColor(context),
      resizeToAvoidBottomInset: true,
      body: 
      Stack(
        children: [
          GestureDetector(
            onPanStart: (_) => _pauseAutoSlide(),
            onPanEnd: (_) {
              // Resume auto-slide after a delay to allow the page animation to complete
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) _resumeAutoSlide();
              });
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: null, // Set to null for infinite scrolling
              onPageChanged: (index) {
                if (mounted) {
                  setState(
                    () => currentIndex = (index % length + length) % length,
                  );
                }
              },
              itemBuilder: (context, index) {
                final realIndex = (index % length + length) % length;
                return Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppData.slides[realIndex]["imgSrc"]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color.fromRGBO(95, 95, 95, 0),
                      const Color.fromRGBO(0, 0, 0, 1),
                    ],
                    stops: const [0.0, 0.95,],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppStyle.appPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppStyle.appPadding * 4),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyle.appPadding ,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppData.slides[currentIndex]["title"],
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppStyle.appFontSizeXXLG,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: AppStyle.appGap),
                      Text(
                        AppData.slides[currentIndex]["subtitle"],
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppStyle.appFontSizeSM,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppStyle.appPadding + AppStyle.appGap),
                Padding(
                  padding: const EdgeInsets.only(left: AppStyle.appPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      AppData.slides.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                ),
                const SizedBox(height: AppStyle.appPadding + AppStyle.appGap),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppStyle.appPadding),
                  child: SizedBox(
                    height: 50,
                    width: size.width,
                    child: ElevatedButton(
                      style: AppStyle.elevatedButtonStyle(context).copyWith(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          AppStyle.primaryColor(context),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
                          ),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to rider home page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RiderHomePage(),
                          ),
                        );
                      },
                      child: Text(
                        "Get Started".tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              
                const SizedBox(height: AppStyle.appPadding * 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
