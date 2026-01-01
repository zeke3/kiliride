import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kiliride/screens/rider/pages/rider.home.pg.dart';
import '../../../shared/styles.shared.dart';
import '../../../routes/router.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  GoogleMapController? _mapController;
  bool _isOnline = false;
  bool _isLoading = false;

  // Default location - Dar es Salaam
  static const LatLng _defaultLocation = LatLng(-6.7924, 39.2083);

  // Sample data - replace with actual data from your backend
  final String _earningsToday = "TZS 45,000";
  final String _onlineTime = "3h 25m";
  final int _tripsCount = 8;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  String _getMapStyle() {
    return Theme.of(context).brightness == Brightness.light
        ? AppStyle.mapStyle
        : AppStyle.darkMapStyle;
  }

  Future<void> _toggleOnlineStatus() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call to update driver status
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isOnline = !_isOnline;
      _isLoading = false;
    });

    // TODO: Call your API to update driver online status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 15,
            ),
            style: _getMapStyle(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            trafficEnabled: false,
            markers: {
              // Add your custom marker for driver location
              const Marker(
                markerId: MarkerId('driver_location'),
                position: _defaultLocation,
              ),
            },
          ),

          // UI Overlay
          SafeArea(
            child: Column(
              children: [
                // Top Card - Online/Offline Status
                Padding(
                  padding: const EdgeInsets.all(AppStyle.appPadding),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppStyle.appColor(context),
                      borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isOnline ? "You're Online" : "You're Offline",
                              style: TextStyle(
                                fontSize: AppStyle.appFontSizeLG,
                                fontWeight: FontWeight.w600,
                                color: AppStyle.textPrimaryColor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isOnline
                                  ? "Finding ride request"
                                  : "Go online to receive rides",
                              style: TextStyle(
                                fontSize: AppStyle.appFontSizeSM,
                                color: AppStyle.descriptionTextColor(context),
                              ),
                            ),
                          ],
                        ),
                        // Online/Offline Toggle
                        _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppStyle.primaryColor(context),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: _toggleOnlineStatus,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 51,
                                  height: 31,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: _isOnline
                                        ? AppStyle.successColor(context)
                                        : AppStyle.descriptionTextColor(
                                            context,
                                          ),
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 300),
                                    alignment: _isOnline
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Map Control Buttons (Location & Search)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyle.appPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.offAll(
                           () => RiderHomePage(),
                            transition: Transition.zoom,
                            duration: const Duration(milliseconds: 350),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppStyle.appPadding,
                            vertical: AppStyle.appGap + 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppStyle.appColor(context),
                            borderRadius: BorderRadius.circular(
                              AppStyle.appRadiusMid,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.swap_horiz,
                                  color: AppStyle.textPrimaryColor(context),
                                  size: 24,
                                ),

                                Text(
                                  ' Switch to Rider',
                                  style: TextStyle(
                                    fontSize: AppStyle.appFontSizeSM,
                                    fontWeight: FontWeight.w600,
                                    color: AppStyle.textPrimaryColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildMapButton(
                            icon: Icons.my_location,
                            onTap: () {
                              // TODO: Center map on driver's current location
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLng(_defaultLocation),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildMapButton(
                            icon: Icons.search,
                            onTap: () {
                              // TODO: Open search/filter dialog
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


                // Bottom Section - Earnings & Stats
                Container(
                  margin: EdgeInsets.all(AppStyle.appPadding),
                  decoration: BoxDecoration(
                    color: AppStyle.appColor(context),
                    borderRadius: BorderRadius.circular(AppStyle.appRadiusLG),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Earnings Card
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to earnings details page
                        },
                        child: Container(
                          margin: const EdgeInsets.all(AppStyle.appPadding),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppStyle.inputBackgroundColor(context),
                            borderRadius: BorderRadius.circular(
                              AppStyle.appRadiusMd,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(
                                    31,
                                    140,
                                    249,
                                    1,
                                  ).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/wallet_filled.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: ColorFilter.mode(
                                      Color.fromRGBO(31, 140, 249, 1),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'EARNINGS TODAY'.tr,
                                      style: TextStyle(
                                        fontSize: AppStyle.appFontSizeXSM,
                                        fontWeight: FontWeight.w900,
                                        color: AppStyle.descriptionTextColor(
                                          context,
                                        ),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _earningsToday,
                                      style: TextStyle(
                                        fontSize: AppStyle.appFontSizeLG,
                                        fontWeight: FontWeight.w700,
                                        color: AppStyle.textPrimaryColor(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow
                              Icon(
                                Icons.chevron_right,
                                color: AppStyle.descriptionTextColor(context),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Stats Row - Online Time & Trips
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppStyle.appPadding,
                          0,
                          AppStyle.appPadding,
                          AppStyle.appPadding + 8,
                        ),
                        child: Row(
                          children: [
                            // Online Time
                            Expanded(
                              child: _buildStatCard(
                                icon: 'assets/icons/recent.svg',
                                label: 'Online',
                                value: _onlineTime,
                                iconColor: AppStyle.primaryColor2(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Trips
                            Expanded(
                              child: _buildStatCard(
                                icon: 'assets/icons/car.svg',
                                label: 'Trips',
                                value: _tripsCount.toString(),
                                iconColor: AppStyle.primaryColor2(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppStyle.appColor(context),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppStyle.textPrimaryColor(context),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppStyle.inputBackgroundColor(context),
        borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromRGBO(31, 140, 249, 1).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                colorFilter: const ColorFilter.mode(
                  Color.fromRGBO(31, 140, 249, 1),
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeSM,
                    fontWeight: FontWeight.w700,
                    color: AppStyle.descriptionTextColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeMd,
                    fontWeight: FontWeight.w700,
                    color: AppStyle.textPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
