import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kiliride/components/custom_avatr_comp.dart';
import 'package:kiliride/components/custom_info_tile.dart';
import 'package:kiliride/shared/styles.shared.dart';

class DriverArrivingPage extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final String vehicleName;
  final int totalPrice;
  final String paymentMethod;
  final String vehicleIconPath;

  const DriverArrivingPage({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.vehicleName,
    required this.totalPrice,
    required this.paymentMethod,
    required this.vehicleIconPath,
  });

  @override
  State<DriverArrivingPage> createState() => _DriverArrivingPageState();
}

class _DriverArrivingPageState extends State<DriverArrivingPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Mock driver data
  final String _driverName = 'Mwema Kassa';
  final String _vehicleModel = 'Toyota IST New model';
  final String _plateNumber = 'MC350EFY';
  final String _verificationCode = '2824';
  final double _driverRating = 4.9;
  final String _estimatedArrival = '05:21 Mins';

  // Mock driver position (should be updated in real implementation)
  double _driverLat = -6.7924;
  double _driverLng = 39.2083;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _addMarkers();
    _drawRoute();
  }

  Future<void> _addMarkers() async {
    // Pickup marker
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.pickupLat, widget.pickupLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Pick me here',
          snippet: widget.pickupAddress,
        ),
      ),
    );

    // Destination marker
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.destinationLat, widget.destinationLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Your destination',
          snippet: widget.destinationAddress,
        ),
      ),
    );

    // Driver marker (mock position - will update in real implementation)
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(_driverLat, _driverLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Driver', snippet: 'Arriving soon'),
      ),
    );

    setState(() {});
  }

  void _drawRoute() {
    // Mock route - in real implementation, use Google Directions API
    final routePoints = [
      LatLng(_driverLat, _driverLng),
      LatLng(widget.pickupLat, widget.pickupLng),
      LatLng(widget.destinationLat, widget.destinationLng),
    ];

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: Colors.black,
        width: 4,
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.pickupLat, widget.pickupLng),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top notification banner
          // Positioned(
          //   top: MediaQuery.of(context).padding.top + 16,
          //   left: 16,
          //   right: 16,
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(12),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.1),
          //           blurRadius: 8,
          //           offset: const Offset(0, 2),
          //         ),
          //       ],
          //     ),
          //     child: const Text(
          //       'Get ready, the driver will come soon',
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         fontSize: 14,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),

          // Safety button
          Positioned(
            top: MediaQuery.of(context).padding.top + AppStyle.appPaddingMd,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Safety',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          // Driver arrival banner
          // Positioned(
          //   bottom: 450,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     margin: const EdgeInsets.symmetric(horizontal: 16),
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //     decoration: BoxDecoration(
          //       color: Colors.black,
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Row(
          //           children: [
          //             Icon(
          //               Icons.directions_car,
          //               color: AppStyle.primaryColor(context),
          //               size: 20,
          //             ),
          //             const SizedBox(width: 8),
          //             const Text(
          //               'The driver will arrive in',
          //               style: TextStyle(color: Colors.white, fontSize: 14),
          //             ),
          //           ],
          //         ),
          //         Text(
          //           _estimatedArrival,
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontSize: 14,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Bottom sheet with driver details
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Column(
                children: [
                  CustomInfoTile(
                    message: 'The driver will arrive in',
                    actionLabel: _estimatedArrival,
                    onActionPressed: () {
                      // Handle promo action
                    },
                  ),
                  Expanded(
                    child: Container(
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
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drag handle
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Vehicle image and details
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    widget.vehicleIconPath,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.contain,
                                  ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _plateNumber,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _vehicleModel,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Divider(color: AppStyle.dividerColor(context),),
                              const SizedBox(height: AppStyle.appGap),

                              // Driver info
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppStyle.appPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  // borderRadius: BorderRadius.circular(12),
                                  // border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          left:
                                              AppStyle.appPaddingMd +
                                              AppStyle.appGap +
                                              2,
                                          top: 4,
                                          child: CustomAvatar(
                                            fullName: "Mercedes Benz",
                                            imageURL: null,
                                            imageAsset: 'assets/img/car.jpg',
                                            size: 60,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppStyle.appColor(context),
                                              width: AppStyle.appGap / 2,
                                            ),
                                          ),
                                          child: CustomAvatar(
                                            fullName: _driverName,
                                            imageURL: null,
                                            size: 60,
                                          ),
                                        ),

                                        // DO NOT DELETE BELOW CODE
                                        // Positioned(
                                        //   bottom: 0,
                                        //   right: 0,
                                        //   child: Container(
                                        //     width: 16,
                                        //     height: 16,
                                        //     decoration: BoxDecoration(
                                        //       color: Colors.green,
                                        //       shape: BoxShape.circle,
                                        //       border: Border.all(
                                        //         color: Colors.white,
                                        //         width: 2,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width:
                                          AppStyle.appPaddingMd +
                                          AppStyle.appGap,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _driverName,
                                            style: const TextStyle(
                                              fontSize: AppStyle.appFontSizeSM,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                          const SizedBox(
                                            height: AppStyle.appGap / 2,
                                          ),

                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: Colors.amber[700],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _driverRating.toString(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            // Call driver
                                          },
                                          icon: SvgPicture.asset(
                                            'assets/icons/call.svg',
                                            height: 30,
                                          ),
                                          padding: EdgeInsets.all(
                                            AppStyle.appGap,
                                          ),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.grey[200],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () {
                                            // Message driver
                                          },
                                          icon: SvgPicture.asset(
                                            'assets/icons/message.svg',
                                            height: 30,
                                          ),
                                          padding: EdgeInsets.all(
                                            AppStyle.appGap,
                                          ),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.grey[200],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                                                            Divider(color: AppStyle.dividerColor(context)),
                              const SizedBox(height: 20),

                              // Verification code
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Verification Code',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _verificationCode,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppStyle.primaryColor(
                                                context,
                                              ),
                                              letterSpacing: 4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'You will Provide this code to driver to start the ride',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: AppStyle.appPadding,),
                            Divider(color: AppStyle.dividerColor(context)),
                              const SizedBox(height: 20),

                              // Trip details
                              const Text(
                                'Trip Details',
                                style: TextStyle(
                                  fontSize: AppStyle.appFontSizeMd,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Pickup location
                              // Trip locations with vertical divider
                              Column(
                                children: [
                                  // Pickup location
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/pickup_ring.svg',
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Pickup',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              widget.pickupAddress,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppStyle.appGap),

                                  // Vertical dotted line
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: AppStyle.appGap + 3,
                                        ),
                                        child: Column(
                                          children: List.generate(
                                            4,
                                            (index) => Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[400],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(
                                      //   width: AppStyle.appGap,
                                      // ), // Aligns with the text offset above
                                      // const Expanded(
                                      //   child: SizedBox(),
                                      // ), // Empty space to push dots to left
                                    ],
                                  ),
                                  const SizedBox(height: AppStyle.appGap),

                                  // Destination
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/destination_ring.svg',
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Your destination',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              widget.destinationAddress,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppStyle.appPadding),

                              // Edit destinations
                              // TextButton(
                              //   onPressed: () {
                              //     // Edit destinations
                              //   },
                              //   child: Text(
                              //     'Edit destinations',
                              //     style: TextStyle(
                              //       fontSize: 14,
                              //       color: AppStyle.primaryColor(context),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(height: 20),

                              // Fare breakdown
                              const Text(
                                'Fare breakdown',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      widget.paymentMethod == 'Cash'
                                          ? Icons.money
                                          : Icons.credit_card,
                                      color: widget.paymentMethod == 'Cash'
                                          ? Colors.green[700]
                                          : Colors.blue[700],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.paymentMethod,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${widget.totalPrice}Tsh',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Split fare
                              const Text(
                                'Split Fare',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        // Split fare with friends
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: const Text(
                                        'Split fare with your friends',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: () {
                                      // Split fare
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: const Text(
                                      'Split Fare',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // More options
                              const Text(
                                'More',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              _buildMoreOption(
                                icon: 'assets/icons/share.svg',
                                title: 'Share ride details',
                                onTap: () {
                                  // Share ride details
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildMoreOption(
                                icon: 'assets/icons/contact_driver.svg',
                                title: 'Contact Driver',
                                onTap: () {
                                  // Contact driver
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildMoreOption(
                                icon: "assets/icons/cancel_ride.svg",
                                title: 'Cancel ride',
                                onTap: () {
                                  _showCancelDialog();
                                },
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).padding.bottom,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOption({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(8),
        //   border: Border.all(color: Colors.grey[300]!),
        // ),
        child: Row(
          children: [
            SvgPicture.asset(icon, height: 22, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: AppStyle.appFontSizeSM),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: AppStyle.primaryColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
