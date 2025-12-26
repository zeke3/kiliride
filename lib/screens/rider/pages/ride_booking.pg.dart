import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kiliride/components/place_search_field.dart';
import 'package:kiliride/screens/rider/pages/driver_arriving.pg.dart';
import 'package:kiliride/shared/constants.dart';
import 'package:kiliride/shared/styles.shared.dart';

class RideBookingPage extends StatefulWidget {
  final Place pickupPlace;
  final Place destinationPlace;

  const RideBookingPage({
    super.key,
    required this.pickupPlace,
    required this.destinationPlace,
  });

  @override
  State<RideBookingPage> createState() => _RideBookingPageState();
}

class _RideBookingPageState extends State<RideBookingPage> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  bool _isLoadingRoute = true;
  bool _routeDrawn = false;

  // Bottom sheet
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _currentSheetSize = 0.3; // Tracks current sheet height ratio

  // Vehicle selection
  VehicleOption? _selectedVehicle;
  bool _showConfirmation = false;


// Add this near your other state variables (around line 36)
  String _selectedPaymentMethod = 'Cash';
  IconData _selectedPaymentIcon = Icons.money;
  Color _selectedPaymentColor = Colors.green;

  // Route info
  String _duration = '';
  String _distance = '';

  final List<VehicleOption> _vehicles = [
    VehicleOption(
      id: 'basic',
      name: 'Basic',
      description: 'Mid-size cars',
      iconPath: 'assets/icons/rides/basic.png',
      pricePerKm: 2000,
      capacity: 4,
      estimatedTime: '10 min',
    ),
    VehicleOption(
      id: 'boda',
      name: 'Boda',
      description: '2-wheel rides',
      iconPath: 'assets/icons/rides/boda.png',
      pricePerKm: 1000,
      capacity: 1,
      estimatedTime: '14 min',
    ),
    VehicleOption(
      id: 'xl',
      name: 'XL',
      description: 'Large cars',
      iconPath: 'assets/icons/rides/xl.png',
      pricePerKm: 2500,
      capacity: 6,
      estimatedTime: '10 min',
    ),
    VehicleOption(
      id: 'bajaji',
      name: 'Bajaji',
      description: '3-wheel rides',
      iconPath: 'assets/icons/rides/bajaji.png',
      pricePerKm: 1500,
      capacity: 3,
      estimatedTime: '15 min',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();

    // Listen to sheet size changes to adjust map
    _sheetController.addListener(_onSheetSizeChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetSizeChanged);
    _mapController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetSizeChanged() {
    final newSize = _sheetController.size;
    if ((newSize - _currentSheetSize).abs() > 0.01) {
      setState(() {
        _currentSheetSize = newSize;
      });
      // Delay to ensure the map padding is updated first
      Future.delayed(const Duration(milliseconds: 100), () {
        _refitMapWithPadding();
      });
    }
  }

  Future<void> _initializeMap() async {
    if (_routeDrawn) return;
    await _addMarkers();
    await _drawRoute();
    setState(() {
      _routeDrawn = true;
    });
  }

  Future<void> _addMarkers() async {
    if (widget.pickupPlace.latitude == null ||
        widget.destinationPlace.latitude == null) {
      return;
    }

    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          widget.pickupPlace.latitude!,
          widget.pickupPlace.longitude!,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Pickup',
          snippet: widget.pickupPlace.mainText,
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          widget.destinationPlace.latitude!,
          widget.destinationPlace.longitude!,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: widget.destinationPlace.mainText,
        ),
      ),
    );

    setState(() {});
  }

  Future<void> _drawRoute() async {
    if (widget.pickupPlace.latitude == null ||
        widget.destinationPlace.latitude == null) {
      setState(() => _isLoadingRoute = false);
      return;
    }

    final origin =
        '${widget.pickupPlace.latitude},${widget.pickupPlace.longitude}';
    final destination =
        '${widget.destinationPlace.latitude},${widget.destinationPlace.longitude}';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$googleMapApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];
          final legs = route['legs'][0];

          setState(() {
            _duration = legs['duration']['text'];
            _distance = legs['distance']['text'];
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: _decodePolyline(polylinePoints),
                color: AppStyle.primaryColor(context),
                width: 4,
              ),
            );
            _isLoadingRoute = false;
          });

          // Initial fit
          _fitMapBounds();
          // Calculate prices
          _calculatePrices(legs['distance']['value'] / 1000);
        }
      }
    } catch (e) {
      debugPrint('Error drawing route: $e');
      setState(() => _isLoadingRoute = false);
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _fitMapBounds() {
    if (_mapController == null || _markers.length < 2) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _markers
            .map((m) => m.position.latitude)
            .reduce((a, b) => a < b ? a : b),
        _markers
            .map((m) => m.position.longitude)
            .reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        _markers
            .map((m) => m.position.latitude)
            .reduce((a, b) => a > b ? a : b),
        _markers
            .map((m) => m.position.longitude)
            .reduce((a, b) => a > b ? a : b),
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void _refitMapWithPadding() {
    if (_mapController == null || _markers.length < 2) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _markers
            .map((m) => m.position.latitude)
            .reduce((a, b) => a < b ? a : b),
        _markers
            .map((m) => m.position.longitude)
            .reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        _markers
            .map((m) => m.position.latitude)
            .reduce((a, b) => a > b ? a : b),
        _markers
            .map((m) => m.position.longitude)
            .reduce((a, b) => a > b ? a : b),
      ),
    );

    // Keep route visible - moderate expansion to show context without losing route
    final latDelta = (bounds.northeast.latitude - bounds.southwest.latitude) * 0.2;
    final lngDelta = (bounds.northeast.longitude - bounds.southwest.longitude) * 0.2;

    final expandedBounds = LatLngBounds(
      southwest: LatLng(
        bounds.southwest.latitude - latDelta,
        bounds.southwest.longitude - lngDelta,
      ),
      northeast: LatLng(
        bounds.northeast.latitude + latDelta,
        bounds.northeast.longitude + lngDelta,
      ),
    );

    // Use reasonable padding to keep route clearly visible
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        expandedBounds,
        100.0,
      ),
    );
  }

  void _calculatePrices(double distanceInKm) {
    for (var vehicle in _vehicles) {
      vehicle.calculatedPrice = (vehicle.pricePerKm * distanceInKm).round();
    }
  }

  void _selectVehicle(VehicleOption vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
      _showConfirmation = false;
    });
  }

  void _confirmSelection() {
    setState(() {
      _showConfirmation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: !_showConfirmation,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_showConfirmation) {
          setState(() {
            _showConfirmation = false;
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Map with dynamic bottom padding
            GoogleMap(
              padding: EdgeInsets.only(
                bottom: screenHeight * _currentSheetSize,
              ),
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.pickupPlace.latitude ?? -6.7924,
                  widget.pickupPlace.longitude ?? 39.2083,
                ),
                zoom: 13,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
                if (_markers.length >= 2) {
                  Future.delayed(
                    const Duration(milliseconds: 500),
                    _fitMapBounds,
                  );
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  if (_showConfirmation) {
                    setState(() {
                      _showConfirmation = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
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
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ),

            // Route info header
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 80,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.green[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.pickupPlace.mainText,
                                  style: const TextStyle(
                                    fontSize: AppStyle.appFontSizeSM,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppStyle.appGap),
                          Divider(
                            height: 8,
                            color: AppStyle.dividerColor(context),
                          ),
                          const SizedBox(height: AppStyle.appGap),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.red[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.destinationPlace.mainText,
                                  style: const TextStyle(
                                    fontSize: AppStyle.appFontSizeSM,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_duration.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppStyle.primaryColor(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Draggable Bottom Sheet with 3 snaps
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.3,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              snap: true,
              snapSizes: const [0.3, 0.6, 0.9], // 3 stops only
              builder: (context, scrollController) {
                return Container(
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
                  child: _showConfirmation
                      ? _buildConfirmationView(scrollController)
                      : _buildVehicleSelection(scrollController),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection(ScrollController scrollController) {
    return Column(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose a ride',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (_distance.isNotEmpty)
                Text(
                  _distance,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoadingRoute
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _vehicles[index];
                    final isSelected = _selectedVehicle?.id == vehicle.id;
                    return GestureDetector(
                      onTap: () => _selectVehicle(vehicle),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color.fromRGBO(76, 17, 19, 1)
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              vehicle.iconPath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        vehicle.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.person,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      Text(
                                        ' ${vehicle.capacity}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${vehicle.estimatedTime} • ${vehicle.description}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'TZS ${vehicle.calculatedPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_selectedVehicle != null)
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.primaryColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Select ${_selectedVehicle!.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmationView(ScrollController scrollController) {
    if (_selectedVehicle == null) return const SizedBox();

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Container(
              padding: const EdgeInsets.all(AppStyle.appPadding),
              child: Column(
                children: [
                  Image.asset(
                    _selectedVehicle!.iconPath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    _selectedVehicle!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppStyle.appGap),
                  Text(
                    "A comfortable ride to your destination, with your friends and family.",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppStyle.appFontSizeSM,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppStyle.appPadding),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: AppStyle.appGap / 2),
                                Text(
                                  '${_selectedVehicle!.capacity} Seats',
                                  style: TextStyle(
                                    fontSize: AppStyle.appFontSizeSM,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'TZS ${_selectedVehicle!.calculatedPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppStyle.primaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppStyle.appPadding),
            const Text(
              'Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
// Replace the existing payment Container with this:
            GestureDetector(
              onTap: _showPaymentMethodSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyle.appPadding,
                  vertical: AppStyle.appGap,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppStyle.borderColor(context)!,),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedPaymentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _selectedPaymentIcon,
                        color: _selectedPaymentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedPaymentMethod,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppStyle.appPaddingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to driver arriving screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverArrivingPage(
                        pickupAddress: widget.pickupPlace.mainText,
                        destinationAddress: widget.destinationPlace.mainText,
                        pickupLat: widget.pickupPlace.latitude!,
                        pickupLng: widget.pickupPlace.longitude!,
                        destinationLat: widget.destinationPlace.latitude!,
                        destinationLng: widget.destinationPlace.longitude!,
                        vehicleName: _selectedVehicle!.name,
                        totalPrice: _selectedVehicle!.calculatedPrice,
                        paymentMethod: _selectedPaymentMethod,
                        vehicleIconPath: _selectedVehicle!.iconPath,
                      ),
                    ),
                  );
                },
                style: AppStyle.elevatedButtonStyle(context).copyWith(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    AppStyle.primaryColor(context),
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
                    ),
                  ),
                  padding: WidgetStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: AppStyle.appPadding),
                  ),
                ),
                child: const Text(
                  'Confirm order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this method after _confirmSelection()
  void _showPaymentMethodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppStyle.appColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Payment Method',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cash Option
            _buildPaymentOption(
              icon: Icons.money,
              iconColor: Colors.green,
              title: 'Cash',
              subtitle: 'Pay with cash to the driver',
              isSelected: _selectedPaymentMethod == 'Cash',
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'Cash';
                  _selectedPaymentIcon = Icons.money;
                  _selectedPaymentColor = Colors.green;
                });
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 12),

            // Card Option
            _buildPaymentOption(
              icon: Icons.credit_card,
              iconColor: Colors.blue,
              title: 'Card',
              subtitle: 'Pay with debit or credit card',
              isSelected: _selectedPaymentMethod == 'Card',
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'Card';
                  _selectedPaymentIcon = Icons.credit_card;
                  _selectedPaymentColor = Colors.blue;
                });
                Navigator.pop(context);
              },
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  // Add this helper method to build payment options
  Widget _buildPaymentOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppStyle.primaryColor(context)
                : AppStyle.borderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppStyle.primaryColor(context),
                size: 24,
              )
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}

class VehicleOption {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final double pricePerKm;
  final int capacity;
  final String estimatedTime;
  int calculatedPrice = 0;

  VehicleOption({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.pricePerKm,
    required this.capacity,
    required this.estimatedTime,
  });
}
