import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kiliride/screens/driver/pages/driver.activity.pg.dart';
import 'package:kiliride/screens/driver/pages/driver.home.pg.dart';
import 'package:kiliride/screens/driver/pages/driver.profile.pg.dart';
import 'package:kiliride/shared/styles.shared.dart';

class DriverNavigation extends StatefulWidget {
  const DriverNavigation({super.key});

  @override
  State<DriverNavigation> createState() => _DriverNavigationState();
}

class _DriverNavigationState extends State<DriverNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DriverHomePage(), // Today tab
    const DriverActivityPage(),
    const DriverProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Material(
        elevation: 8,
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Stack(
            children: [
              BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: Color.fromRGBO(31, 140, 249, 1),
                unselectedItemColor: Color.fromRGBO(31, 140, 249, 1).withOpacity(0.6),
                selectedFontSize: 12,
                unselectedFontSize: 10,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 4, top: 4),
                      child: SvgPicture.asset(
                        'assets/icons/home.svg',
                        color: _currentIndex == 0
                            ? Color.fromRGBO(31, 140, 249, 1)
                            : Color.fromRGBO(31, 140, 249, 1).withOpacity(0.6),
                        width: 25,
                        height: 25,
                      ),
                    ),
                    label: 'Home'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 4, top: 4),
                      child: SvgPicture.asset(
                        'assets/icons/activity.svg',
                        color: _currentIndex == 1
                            ? Color.fromRGBO(31, 140, 249, 1)
                            : Color.fromRGBO(31, 140, 249, 1).withOpacity(0.6),
                        width: 25,
                        height: 25,
                      ),
                    ),
                    label: 'Activity'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 4, top: 4),
                      child: SvgPicture.asset(
                        'assets/icons/profile.svg',
                        color: _currentIndex == 2
                            ? Color.fromRGBO(31, 140, 249, 1)
                            : Color.fromRGBO(31, 140, 249, 1).withOpacity(0.6),
                        width: 28,
                        height: 28,
                      ),
                    ),
                    label: 'Profile'.tr,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

