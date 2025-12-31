import 'dart:async';
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kiliride/components/custom_info_tile.dart';
import 'package:kiliride/providers/providers.dart';
import 'package:kiliride/screens/driver/screens/become_driver.scrn.dart';
import 'package:kiliride/screens/rider/pages/location_search.pg.dart';
import 'package:kiliride/screens/rider/screens/safety.scrn.dart';
import 'package:kiliride/screens/rider/screens/my_rides.scrn.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/services/db_service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(
    -6.7924,
    39.2083,
  ); // Dar es Salaam default
  final Set<Marker> _markers = {};
  Timer? _vehicleAnimationTimer;
  final List<VehicleMarker> _vehicles = [];
  final Random _random = Random();

  late List<RoadPath> _roadPaths;

  String? _startLocation;
  String? _destinationLocation;

  // Map style to grey out POI icons and labels
  final String _mapStyle = '''[
    {
      "featureType": "poi",
      "elementType": "labels.icon",
      "stylers": [
        {
          "saturation": -100
        },
        {
          "lightness": 50
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#ffffff"
        }
      ]
    }
  ]''';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkAndRegisterNotification();
  }

  @override
  void dispose() {
    _vehicleAnimationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _checkAndRegisterNotification() async {
    await AwesomeNotifications().dismissAllNotifications();
    bool hasNotifToken = await _hasNotifToken();
    if (!hasNotifToken) {
      await Funcs.registerNotification();
    }
  }

  Future<bool> _hasNotifToken() async {
    //DO NOT DELETE THIS FUNCTION. KEEP FOR FUTURE USE.
    // final uid = AuthService().currentUser?.uid;
    // if (uid == null) {
    //   return false;
    // }

    // return await DBService().userHasNotificationTokens(uid);
    return false;
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation, 14.0),
        );

        // Initialize paths and vehicles after location is set
        _defineRoadPaths();
        _initializeVehicles();
        _startVehicleAnimation();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      // Fallback: use default location
      _defineRoadPaths();
      _initializeVehicles();
      _startVehicleAnimation();
    }
  }

  void _defineRoadPaths() {
    final center = _currentLocation;

    _roadPaths = [
      // Main North-South Road (e.g., Morogoro Road style)
      RoadPath(
        id: 'main_ns_road',
        points: [
          LatLng(center.latitude + 0.04, center.longitude - 0.005),
          LatLng(center.latitude + 0.02, center.longitude - 0.003),
          LatLng(center.latitude + 0.01, center.longitude),
          LatLng(center.latitude, center.longitude),
          LatLng(center.latitude - 0.01, center.longitude + 0.002),
          LatLng(center.latitude - 0.02, center.longitude + 0.004),
          LatLng(center.latitude - 0.04, center.longitude + 0.006),
        ],
        bidirectional: true,
      ),
      // East-West Road (e.g., Samora Avenue style)
      RoadPath(
        id: 'main_ew_road',
        points: [
          LatLng(center.latitude + 0.003, center.longitude - 0.04),
          LatLng(center.latitude + 0.001, center.longitude - 0.02),
          LatLng(center.latitude, center.longitude),
          LatLng(center.latitude - 0.002, center.longitude + 0.02),
          LatLng(center.latitude - 0.004, center.longitude + 0.04),
        ],
        bidirectional: true,
      ),
      // Local circular loop (e.g., around a neighborhood)
      RoadPath(
        id: 'local_loop',
        points: [
          LatLng(center.latitude + 0.015, center.longitude + 0.005),
          LatLng(center.latitude + 0.012, center.longitude + 0.015),
          LatLng(center.latitude + 0.005, center.longitude + 0.018),
          LatLng(center.latitude - 0.005, center.longitude + 0.015),
          LatLng(center.latitude - 0.012, center.longitude + 0.008),
          LatLng(center.latitude - 0.015, center.longitude - 0.005),
          LatLng(center.latitude - 0.010, center.longitude - 0.015),
          LatLng(center.latitude + 0.005, center.longitude - 0.012),
          LatLng(
            center.latitude + 0.015,
            center.longitude + 0.005,
          ), // close loop
        ],
        bidirectional: false,
      ),
    ];
  }

  void _initializeVehicles() {
    _vehicles.clear();

    // Assign vehicles to different paths and directions
    final pathsWithDirection = <Map<String, dynamic>>[];

    for (var path in _roadPaths) {
      pathsWithDirection.add({'path': path, 'forward': true});
      if (path.bidirectional) {
        pathsWithDirection.add({'path': path, 'forward': false});
      }
    }

    // Create 3 cars and 2 bikes
    int carIndex = 0, bikeIndex = 0;
    for (int i = 0; i < 5; i++) {
      final assignment =
          pathsWithDirection[_random.nextInt(pathsWithDirection.length)];
      final RoadPath path = assignment['path'];
      final bool forward = assignment['forward'];

      final type = (carIndex < 3) ? VehicleType.car : VehicleType.bike;
      if (type == VehicleType.car)
        carIndex++;
      else
        bikeIndex++;

      final points = forward ? path.points : path.points.reversed.toList();

      final startIndex = _random.nextInt(points.length - 1);
      final position = points[startIndex];

      _vehicles.add(
        VehicleMarker(
          id: '${type.toString().split('.').last}_${type == VehicleType.car ? carIndex - 1 : bikeIndex - 1}',
          type: type,
          currentPath: path,
          pathPoints: points,
          pathIndex: startIndex,
          position: position,
          rotation: 0.0, // Will be calculated in animation
        ),
      );
    }

    _updateMarkers();
  }

  void _startVehicleAnimation() {
    _vehicleAnimationTimer = Timer.periodic(const Duration(milliseconds: 600), (
      timer,
    ) {
      setState(() {
        for (var vehicle in _vehicles) {
          final points = vehicle.pathPoints;
          int currentIndex = vehicle.pathIndex;

          // Move to next point
          currentIndex++;
          if (currentIndex >= points.length - 1) {
            currentIndex = 0; // Loop back
          }

          final nextPosition =
              points[currentIndex + 1 > points.length - 1
                  ? 0
                  : currentIndex + 1];
          final currentPosition = points[currentIndex];

          // Calculate movement vector
          double latDiff = nextPosition.latitude - vehicle.position.latitude;
          double lngDiff = nextPosition.longitude - vehicle.position.longitude;

          // Speed: cars faster than bikes
          double speedFactor = vehicle.type == VehicleType.car ? 1.4 : 1.0;
          double progress = 0.008 * speedFactor; // Adjust for smooth movement

          // Interpolate position
          vehicle.position = LatLng(
            vehicle.position.latitude + latDiff * progress,
            vehicle.position.longitude + lngDiff * progress,
          );

          // Update rotation (direction of movement)
          vehicle.rotation = atan2(lngDiff, latDiff) * 180 / pi;

          // Update path index when close to next point
          double distanceToNext = sqrt(
            pow(nextPosition.latitude - vehicle.position.latitude, 2) +
                pow(nextPosition.longitude - vehicle.position.longitude, 2),
          );

          if (distanceToNext < 0.0003) {
            vehicle.pathIndex = currentIndex + 1 >= points.length
                ? 0
                : currentIndex + 1;
          }
        }

        _updateMarkers();
      });
    });
  }

  Future<void> _updateMarkers() async {
    _markers.clear();

    for (var vehicle in _vehicles) {
      final BitmapDescriptor icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        vehicle.type == VehicleType.car
            ? 'assets/icons/dummy/dummy_car.png'
            : 'assets/icons/dummy/dummy_bike.png',
      );

      _markers.add(
        Marker(
          markerId: MarkerId(vehicle.id),
          position: vehicle.position,
          icon: icon,
          rotation: vehicle.rotation,
          anchor: const Offset(0.5, 0.5),
          zIndex: 10,
        ),
      );
    }

    // User location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    if (mounted) setState(() {});
  }

  void _showLocationPicker() async {
    final result = await Get.to(
      () => LocationSearchPage(),
      transition: Transition.downToUp,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _startLocation = result['pickup'];
        _destinationLocation = result['destination'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          GoogleMap(
            style: _mapStyle,
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14.0,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.55,
            ),
          ),

          // Hamburger Menu Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu, size: 24),
              ),
            ),
          ),

          // Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                CustomInfoTile(
                  message: 'Get 20% off on your by using Credit card',
                  actionLabel: 'Apply',
                  onActionPressed: () {},
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppStyle.appColor(context),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          onTap: _showLocationPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppStyle.inputBackgroundColor(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _destinationLocation ?? 'Where to?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _destinationLocation != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Schedule',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildSavedLocationTile(
                              icon: Icons.home_outlined,
                              title: 'Home',
                              subtitle: 'Zaramo st, Arusha urban',
                            ),
                            const SizedBox(height: 12),
                            _buildSavedLocationTile(
                              icon: Icons.work_outline,
                              title: 'Work',
                              subtitle: 'Haile Selassie Road, Arusha',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildSavedLocationTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppStyle.inputBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      surfaceTintColor: Colors.transparent,
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      child: Consumer(
        builder: (context, ref, child) {
          final userProvider = ref.watch(userInfoProvider);
          final userName = userProvider.userFullName.isNotEmpty
              ? userProvider.userFullName
              : 'User';
          final userRating = '5.00';

          return Column(
            children: [
              // User Profile Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 20,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: AppStyle.appColor(context),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppStyle.appRadiusMid),
                    bottomRight: Radius.circular(AppStyle.appRadiusMid),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'My account',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppStyle.primaryColor(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppStyle.primaryColor(context),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$userRating Rating',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppStyle.appGap),
              // Divider(height: 1, thickness: 1, color: AppStyle.dividerColor(context),),

              // Menu Items
              Expanded(
                child: Container(
                  color: AppStyle.appColor(context),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerMenuItem(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to payment screen
                        },
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.local_offer_outlined,
                        title: 'Promotions',
                        subtitle: 'Enter promo code',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to promotions screen
                        },
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'My Rides',
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(
                            () => const MyRidesScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.shield_outlined,
                        title: 'Safety',
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(
                            () => const SafetyScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.business_center_outlined,
                        title: 'Expense Your Rides',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to expense screen
                        },
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.help_outline,
                        title: 'Support',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to support screen
                        },
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to about screen
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Become a driver banner
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to become a driver screen
                  Get.to(
                    () => BecomeADriverScreen(userData: null),
                    transition: Transition.leftToRightWithFade,
                    duration: Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: Container(
                  color: Colors.white,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppStyle.appPadding,
                    ),
                    padding: const EdgeInsets.all(AppStyle.appPadding),
                    decoration: BoxDecoration(
                      color: AppStyle.primaryColor(
                        context,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Become a driver',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Earn money on your schedule',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models
enum VehicleType { car, bike }

class RoadPath {
  final String id;
  final List<LatLng> points;
  final bool bidirectional;

  RoadPath({required this.id, required this.points, this.bidirectional = true});
}

class VehicleMarker {
  final String id;
  final VehicleType type;
  final RoadPath currentPath;
  final List<LatLng> pathPoints;
  int pathIndex;
  LatLng position;
  double rotation;

  VehicleMarker({
    required this.id,
    required this.type,
    required this.currentPath,
    required this.pathPoints,
    required this.pathIndex,
    required this.position,
    required this.rotation,
  });
}
