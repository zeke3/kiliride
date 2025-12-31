// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:get/get.dart';
// import 'package:kiliride/components/loading.dart';
// import 'package:kiliride/components/place_search_field.dart';
// import 'package:kiliride/providers/theme.provider.dart';
// import 'package:kiliride/shared/constants.dart';
// import 'package:kiliride/shared/funcs.main.ctrl.dart'; // <-- Make sure to import Funcs
// import 'package:kiliride/shared/styles.shared.dart';

// class LocationPickerScreen extends riverpod.ConsumerStatefulWidget {
//   final LatLng initialLocation;
//   final String appBarTitle;
//   final String confirmButtonText;

//   const LocationPickerScreen({
//     super.key,
//     required this.initialLocation,
//     this.appBarTitle = "Set Location",
//     this.confirmButtonText = "Confirm Location",
//   });

//   @override
//   _LocationPickerScreenState createState() => _LocationPickerScreenState();
// }

// class _LocationPickerScreenState
//     extends riverpod.ConsumerState<LocationPickerScreen>
//     with TickerProviderStateMixin {
//   GoogleMapController? _mapController;
//   late LatLng _currentLocation;
//   Place? _selectedPlace;
//   bool _isGeocoding = true;
//   Timer? _geocodeTimer;
//   bool _userSelectedPlace = false; // Track if user selected from search
//   bool _isProgrammaticCameraMove =
//       false; // Track programmatic camera animations

//   // --- ADDED for Search ---
//   late final TextEditingController _searchController;
//   // --- END ADDED ---

//   // --- ADDED FOR ANIMATION ---
//   late final AnimationController _glowController;
//   late final Animation<double> _glowAnimation;
//   // --- END ADDED ---

//   @override
//   void initState() {
//     super.initState();
//     _currentLocation = widget.initialLocation;
//     _searchController = TextEditingController(); // <-- ADDED

//     // --- ADDED FOR ANIMATION ---
//     _glowController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     );
//     _glowAnimation = Tween(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
//     _glowController.repeat(reverse: true);
//     // --- END ADDED ---
//   }

//   @override
//   void dispose() {
//     _geocodeTimer?.cancel();
//     _glowController.dispose();
//     _mapController?.dispose();
//     _searchController.dispose(); // <-- ADDED
//     super.dispose();
//   }

//   // --- ADDED: Handler for search selection ---
//   void _onPlaceSelectedFromSearch(Place place) {
//     debugPrint("📍 Place selected from search: ${place.mainText}");
//     debugPrint("📍 Coordinates: ${place.latitude}, ${place.longitude}");

//     if (place.latitude == null || place.longitude == null) {
//       Funcs.showSnackBar(
//         message: "Selected location is invalid.",
//         isSuccess: false,
//       );
//       return;
//     }

//     final LatLng newPosition = LatLng(place.latitude!, place.longitude!);
//     _searchController.text = place.mainText; // Update text field

//     // Update the selected place immediately without reverse geocoding
//     setState(() {
//       _currentLocation = newPosition;
//       _selectedPlace = place;
//       _isGeocoding = false;
//       _userSelectedPlace = true; // Mark that user selected this place
//     });

//     debugPrint("📍 Selected place set, _userSelectedPlace = true");

//     // Mark that we're about to do a programmatic camera move
//     _isProgrammaticCameraMove = true;

//     // Animate map to the new position
//     _mapController?.animateCamera(
//       CameraUpdate.newLatLngZoom(newPosition, 16.5),
//     );

//     // Unfocus the search bar
//     FocusScope.of(context).unfocus();
//   }
//   // --- END ADDED ---

//   // Calls Google's reverse geocoding API
//   Future<void> _reverseGeocode(LatLng position) async {
//     setState(() {
//       _isGeocoding = true;
//       _selectedPlace = null;
//       _userSelectedPlace = false; // Reset user selection flag
//     });

//     try {
//       final url =
//           'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapApiKey';
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK' && data['results'].isNotEmpty) {
//           // Default to the first result
//           var result = data['results'][0];

//           // Search for a POI or Establishment in the results to prioritize it
//           // Also look for establishments with names (not just streets)
//           for (var item in data['results']) {
//             final List<dynamic> types = item['types'];
//             final hasName =
//                 item['name'] != null && item['name'].toString().isNotEmpty;

//             // Prioritize named establishments and POIs
//             if ((types.contains('point_of_interest') ||
//                     types.contains('establishment') ||
//                     types.contains('premise') ||
//                     types.contains('tourist_attraction') ||
//                     types.contains('lodging') ||
//                     types.contains('restaurant') ||
//                     types.contains('store')) &&
//                 hasName) {
//               result = item;
//               break; // Found a specific named place, use it!
//             }
//           }

//           final String fullAddress = result['formatted_address'];
//           final String? placeName =
//               result['name']; // Get the place name if available

//           // Extract address components
//           final addressComponents =
//               result['address_components'] as List<dynamic>;
//           String? region,
//               country,
//               locality,
//               sublocality,
//               route,
//               premise,
//               neighborhood,
//               poi,
//               establishment;

//           for (var component in addressComponents) {
//             final types = component['types'] as List<dynamic>;
//             final longName = component['long_name'];

//             if (types.contains('administrative_area_level_1')) {
//               region = longName;
//             } else if (types.contains('country')) {
//               country = longName;
//             } else if (types.contains('locality')) {
//               locality = longName;
//             } else if (types.contains('sublocality') ||
//                 types.contains('sublocality_level_1')) {
//               sublocality = longName;
//             } else if (types.contains('route')) {
//               route = longName;
//             } else if (types.contains('premise')) {
//               premise = longName;
//             } else if (types.contains('neighborhood')) {
//               neighborhood = longName;
//             } else if (types.contains('point_of_interest')) {
//               poi = longName;
//             } else if (types.contains('establishment')) {
//               establishment = longName;
//             }
//           }

//           // Build main text - prioritize more specific location info
//           String mainAddressText;

//           // Priority order: Place Name > POI > Establishment > Premise > Route > Neighborhood > Sublocality > Locality
//           if (placeName != null &&
//               placeName.isNotEmpty &&
//               !placeName.contains('+')) {
//             // Use the place name if it exists and is not a plus code
//             mainAddressText = placeName;
//           } else if (poi != null && poi.isNotEmpty) {
//             mainAddressText = poi;
//           } else if (establishment != null && establishment.isNotEmpty) {
//             mainAddressText = establishment;
//           } else if (premise != null && premise.isNotEmpty) {
//             mainAddressText = premise;
//           } else if (route != null && route.isNotEmpty) {
//             mainAddressText = route;
//           } else if (neighborhood != null && neighborhood.isNotEmpty) {
//             mainAddressText = neighborhood;
//           } else if (sublocality != null && sublocality.isNotEmpty) {
//             mainAddressText = sublocality;
//           } else if (locality != null && locality.isNotEmpty) {
//             mainAddressText = locality;
//           } else {
//             // Fallback: extract from formatted address
//             final plusCodeRegex = RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{2,}\s*,');
//             if (plusCodeRegex.hasMatch(fullAddress)) {
//               mainAddressText = fullAddress.split(',')[1].trim();
//             } else {
//               mainAddressText = fullAddress.split(',').first.trim();
//             }
//             if (mainAddressText.isEmpty && fullAddress.isNotEmpty) {
//               mainAddressText = fullAddress;
//             }
//           }

//           // Build secondary text - show area context
//           String secondaryAddressText;
//           // If we used place name, add more context
//           if (placeName != null && mainAddressText == placeName) {
//             // Add locality/sublocality as secondary if available
//             if (locality != null && locality.isNotEmpty) {
//               secondaryAddressText = locality;
//             } else if (sublocality != null && sublocality.isNotEmpty) {
//               secondaryAddressText = sublocality;
//             } else {
//               secondaryAddressText = fullAddress
//                   .split(',')
//                   .skip(1)
//                   .join(',')
//                   .trim();
//             }
//           } else if (sublocality != null && mainAddressText != sublocality) {
//             secondaryAddressText = sublocality;
//           } else if (locality != null && mainAddressText != locality) {
//             secondaryAddressText = locality;
//           } else {
//             secondaryAddressText = fullAddress
//                 .split(',')
//                 .skip(1)
//                 .join(',')
//                 .trim();
//           }

//           if (mounted) {
//             setState(() {
//               _selectedPlace = Place(
//                 description: fullAddress,
//                 mainText: mainAddressText,
//                 secondaryText: secondaryAddressText,
//                 latitude: position.latitude,
//                 longitude: position.longitude,
//                 placeId: result['place_id'],
//                 types: (result['types'] as List)
//                     .map((t) => t.toString())
//                     .toList(),
//                 country: country,
//                 region: region,
//               );
//               _isGeocoding = false;
//             });
//           }
//         } else {
//           throw Exception("Reverse geocoding failed: ${data['status']}");
//         }
//       } else {
//         throw Exception("Failed to connect to Geocoding API");
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isGeocoding = false;
//         });
//       }
//     }
//   }

//   // Called when the map camera stops moving
//   void _onCameraIdle() {
//     debugPrint(
//       "📍 _onCameraIdle called, _userSelectedPlace = $_userSelectedPlace, _isProgrammaticCameraMove = $_isProgrammaticCameraMove",
//     );

//     // Reset the programmatic move flag
//     _isProgrammaticCameraMove = false;

//     // Don't reverse geocode if user just selected a place from search
//     if (_userSelectedPlace) {
//       debugPrint("📍 Skipping reverse geocode - user selected from search");
//       return;
//     }

//     debugPrint("📍 Starting reverse geocode from camera idle");
//     _geocodeTimer?.cancel();
//     _geocodeTimer = Timer(const Duration(milliseconds: 200), () {
//       if (_mapController != null) {
//         _mapController!.getVisibleRegion().then((bounds) {
//           final center = LatLng(
//             (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
//             (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
//           );
//           _currentLocation = center;
//           _reverseGeocode(center);
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
//     final double topPadding = MediaQuery.of(context).padding.top;

//     return Scaffold(
//       backgroundColor: AppStyle.appColor(context),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: widget.initialLocation,
//               zoom: 16.5,
//             ),
//             style: isDarkMode ? AppStyle.darkMapStyle : AppStyle.mapStyle,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: false,
//             onMapCreated: (controller) {
//               _mapController = controller;
//               _reverseGeocode(
//                 widget.initialLocation,
//               ); // Geocode initial location
//             },
//             onCameraMoveStarted: () {
//               _geocodeTimer?.cancel();

//               // Only reset if this is a user-initiated drag, not a programmatic move
//               if (!_isProgrammaticCameraMove) {
//                 setState(() {
//                   _isGeocoding = true;
//                   _userSelectedPlace =
//                       false; // Reset when user manually drags map
//                 });
//                 debugPrint(
//                   "📍 User started dragging map - resetting _userSelectedPlace",
//                 );
//               } else {
//                 debugPrint(
//                   "📍 Programmatic camera move started - keeping _userSelectedPlace",
//                 );
//               }
//             },
//             onCameraIdle: _onCameraIdle,
//           ),

//           // --- GLOWING EFFECT ---
//           Center(
//             child: Padding(
//               // Same padding as the pin to be concentric
//               padding: const EdgeInsets.only(bottom: 40.0),
//               child: ScaleTransition(
//                 scale: _glowAnimation,
//                 child: FadeTransition(
//                   opacity: Tween(begin: 1.0, end: 0.0).animate(_glowAnimation),
//                   child: Container(
//                     height: 80, // 2x the pin height
//                     width: 80,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       // Pulsing color
//                       color: AppStyle.primaryColor(context).withOpacity(0.4),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // --- END GLOWING EFFECT ---

//           // --- THE CENTER PIN ---
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 40.0),
//               child: SvgPicture.asset(
//                 "assets/icons/start_pin.svg", // Using your existing pin
//                 height: 40,
//                 color: AppStyle.primaryColor(context),
//               ),
//             ),
//           ),

//           // --- ADDED: SEARCH BAR ---
//           Positioned(
//             top: topPadding + 10.0, // 10dp padding below status bar
//             left: AppStyle.appPadding,
//             right: AppStyle.appPadding,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppStyle.appColor(context),
//                 borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: PlaceSearchField(
//                 showMapPicker: false,
//                 title: "Search for a place".tr,
//                 controller: _searchController,
//                 googleApiKey: googleMapApiKey,
//                 countryCode: 'tz', // You can parameterize this if needed
//                 onPlaceSelected: _onPlaceSelectedFromSearch,
//                 decoration: InputDecoration(
//                   prefixIcon: IconButton(
//                     icon: Icon(
//                       Icons.arrow_back,
//                       color: AppStyle.textColored(context),
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   hintText: 'Search for a place...'.tr,
//                   hintStyle: TextStyle(
//                     color: AppStyle.textColoredFade(context),
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
//                 ),
//               ),
//             ),
//           ),
//           // --- END ADDED ---

//           // --- MODIFIED: MY LOCATION BUTTON (Positioned below search) ---
//           Positioned(
//             // Position it below the search bar (topPadding + appBar + searchPadding + searchHeight + buttonPadding)
//             top: topPadding + kToolbarHeight + 10.0 + 65.0,
//             right: AppStyle.appPadding,
//             child: FloatingActionButton(
//               heroTag: "my_location_picker",
//               mini: true,
//               backgroundColor: AppStyle.appColor(context),
//               onPressed: () async {
//                 _mapController?.animateCamera(
//                   CameraUpdate.newCameraPosition(
//                     CameraPosition(target: widget.initialLocation, zoom: 16.5),
//                   ),
//                 );
//               },
//               child: Icon(
//                 Icons.my_location,
//                 color: AppStyle.primaryColor(context),
//               ),
//             ),
//           ),
//           // --- END MODIFIED ---

//           // --- BOTTOM CONFIRMATION SHEET ---
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(AppStyle.appPadding).copyWith(
//                 bottom:
//                     AppStyle.appPadding + MediaQuery.of(context).padding.bottom,
//               ),
//               decoration: BoxDecoration(
//                 color: AppStyle.appColor(context),
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(20),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (_isGeocoding)
//                     const Loading()
//                   else if (_selectedPlace != null) ...[
//                     Text(
//                       _selectedPlace!.mainText,
//                       style: TextStyle(
//                         fontSize: AppStyle.appFontSizeLG,
//                         fontWeight: FontWeight.bold,
//                         color: AppStyle.textColored(context),
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       _selectedPlace!.secondaryText,
//                       style: TextStyle(
//                         fontSize: AppStyle.appFontSize,
//                         color: AppStyle.textColoredFade(context),
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ] else
//                     Text(
//                       "Could not find address".tr,
//                       style: TextStyle(
//                         fontSize: AppStyle.appFontSizeLG,
//                         fontWeight: FontWeight.bold,
//                         color: AppStyle.errorColor(context),
//                       ),
//                     ),

//                   const SizedBox(height: AppStyle.appPadding),

//                   SizedBox(
//                     height: AppStyle.buttonHeight,
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: AppStyle.elevatedButtonStyle(context).copyWith(
//                         backgroundColor: WidgetStatePropertyAll(
//                           AppStyle.primaryColor(context),
//                         ),
//                       ),
//                       onPressed:
//                           (_selectedPlace == null ||
//                               _selectedPlace?.region == null)
//                           ? null // Disable button if no valid place is found
//                           : () {
//                               // Pop and return the selected 'Place' object
//                               Navigator.pop(context, _selectedPlace);
//                             },
//                       child: Text(widget.confirmButtonText.tr),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
