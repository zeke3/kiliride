import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kiliride/components/loading.dart';
import 'package:kiliride/components/place_search_field.dart';
import 'package:kiliride/screens/rider/pages/ride_booking.pg.dart';
import 'package:kiliride/screens/rider/screens/location_picker.scrn.dart';
import 'package:kiliride/shared/constants.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSearchPage extends StatefulWidget {
  final String? initialPickupLocation;
  final String? initialDestination;

  const LocationSearchPage({
    super.key,
    this.initialPickupLocation,
    this.initialDestination,
  });

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  bool _isPickupFocused = false;
  bool _isDestinationFocused = false;

  Place? _pickupPlace;
  Place? _destinationPlace;
  LatLng? _currentLocation;

  List<Place> _searchResults = [];
  List<Place> _history = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _pickupController.text = widget.initialPickupLocation ?? '';
    _destinationController.text = widget.initialDestination ?? '';

    _pickupFocusNode.addListener(() {
      setState(() {
        _isPickupFocused = _pickupFocusNode.hasFocus;
        if (_isPickupFocused) {
          _isDestinationFocused = false;
          if (_pickupController.text.isNotEmpty) {
            _searchPlaces(_pickupController.text);
          } else {
            _loadHistory();
          }
        }
      });
    });

    _destinationFocusNode.addListener(() {
      setState(() {
        _isDestinationFocused = _destinationFocusNode.hasFocus;
        if (_isDestinationFocused) {
          _isPickupFocused = false;
          if (_destinationController.text.isNotEmpty) {
            _searchPlaces(_destinationController.text);
          } else {
            _loadHistory();
          }
        }
      });
    });

    _getCurrentLocation();
    _loadHistory();

    // Auto-focus destination field on open
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _destinationFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
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
          if (_pickupController.text.isEmpty) {
            _pickupController.text = 'Current Location';
          }
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('location_search_history') ?? [];
    if (mounted) {
      setState(() {
        _history = historyJson.map((json) => Place.fromJsonString(json)).toList();
        _searchResults = _history;
      });
    }
  }

  Future<void> _saveToHistory(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    _history.removeWhere((p) => p.placeId == place.placeId);
    _history.insert(0, place);
    if (_history.length > 5) _history = _history.sublist(0, 5);
    final historyJson = _history.map((p) => p.toJsonString()).toList();
    await prefs.setStringList('location_search_history', historyJson);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = _history;
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String input) async {
    if (input.isEmpty || input.length < 2) {
      setState(() {
        _searchResults = _history;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleMapApiKey&components=country:tz';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          if (mounted) {
            setState(() {
              _searchResults = (data['predictions'] as List)
                  .map((p) => Place.fromJson(p))
                  .toList();
              _isSearching = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  Future<Place> _getPlaceDetails(Place preliminaryPlace) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${preliminaryPlace.placeId}&fields=geometry,address_components&key=$googleMapApiKey';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          String? country;
          String? region;

          final addressComponents = result['address_components'] as List?;
          if (addressComponents != null) {
            for (var component in addressComponents) {
              final types = component['types'] as List?;
              if (types != null) {
                if (types.contains('country')) {
                  country = component['long_name'];
                }
                if (types.contains('administrative_area_level_1')) {
                  region = component['long_name'];
                }
              }
            }
          }

          return preliminaryPlace.copyWith(
            latitude: location['lat'] as double,
            longitude: location['lng'] as double,
            country: country,
            region: region,
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }

    return preliminaryPlace;
  }

  void _onPickupPlaceSelected(Place place) async {
    final detailedPlace = await _getPlaceDetails(place);
    await _saveToHistory(detailedPlace);

    setState(() {
      _pickupPlace = detailedPlace;
      _pickupController.text = place.mainText;
      _pickupFocusNode.unfocus();
    });

    // Auto-focus destination after selecting pickup
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _destinationFocusNode.requestFocus();
      }
    });
  }

  void _onDestinationPlaceSelected(Place place) async {
    final detailedPlace = await _getPlaceDetails(place);
    await _saveToHistory(detailedPlace);

    setState(() {
      _destinationPlace = detailedPlace;
      _destinationController.text = place.mainText;
      _destinationFocusNode.unfocus();
    });

    // Navigate to ride booking page with destination
    // If no pickup location is selected, use current location
    if (_destinationPlace != null) {
      Place pickupToUse;

      if (_pickupPlace != null) {
        // Use the explicitly selected pickup location
        pickupToUse = _pickupPlace!;
      } else if (_currentLocation != null) {
        // Use current location as pickup
        pickupToUse = Place(
          placeId: 'current_location',
          mainText: 'Current Location',
          secondaryText: '',
          description: 'Current Location',
          types: [],
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
        );
      } else {
        // Cannot proceed without a pickup location
        return;
      }

      if (mounted) {
        // Navigate to ride booking page (keep location search in stack)
        Get.to(
          () => RideBookingPage(
            pickupPlace: pickupToUse,
            destinationPlace: _destinationPlace!,
          ),
          transition: Transition.zoom,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
  }

  void _openMapPickerForPickup() async {
    final LatLng initialPosition = _pickupPlace != null &&
            _pickupPlace!.latitude != null &&
            _pickupPlace!.longitude != null
        ? LatLng(_pickupPlace!.latitude!, _pickupPlace!.longitude!)
        : _currentLocation ?? const LatLng(-6.7924, 39.2083);

    final Place? selectedPlace = await Get.to(
      () => LocationPickerScreen(
        initialLocation: initialPosition,
        appBarTitle: 'Set Pick-up Location',
        confirmButtonText: 'Confirm Pick-up',
      ),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 350),
    );

    if (selectedPlace != null) {
      _onPickupPlaceSelected(selectedPlace);
    }
  }

  void _openMapPickerForDestination() async {
    final LatLng initialPosition = _destinationPlace != null &&
            _destinationPlace!.latitude != null &&
            _destinationPlace!.longitude != null
        ? LatLng(_destinationPlace!.latitude!, _destinationPlace!.longitude!)
        : _currentLocation ?? const LatLng(-6.7924, 39.2083);

    final Place? selectedPlace = await Get.to(
      () => LocationPickerScreen(
        initialLocation: initialPosition,
        appBarTitle: 'Set Destination',
        confirmButtonText: 'Confirm Destination',
      ),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 350),
    );

    if (selectedPlace != null) {
      _onDestinationPlaceSelected(selectedPlace);
    }
  }

  IconData _getIconForPlaceType(List<String> types) {
    if (types.contains('restaurant') || types.contains('food')) {
      return Icons.restaurant;
    }
    if (types.contains('store') || types.contains('shopping_mall')) {
      return Icons.store;
    }
    if (types.contains('lodging') || types.contains('hotel')) {
      return Icons.hotel;
    }
    if (types.contains('cafe')) return Icons.local_cafe;
    if (types.contains('airport')) return Icons.flight;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final bool showResults = _isPickupFocused || _isDestinationFocused;

    return Scaffold(
      backgroundColor: AppStyle.appColor(context),
      appBar: AppBar(
        backgroundColor: AppStyle.appColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Where to',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Location input fields
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Pick-up location field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isPickupFocused
                        ? Colors.white
                        : AppStyle.inputBackgroundColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPickupFocused
                          ? const Color.fromRGBO(31, 140, 249, 1)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _pickupController,
                          focusNode: _pickupFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Pick-up location',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      if (_pickupController.text.isNotEmpty && _isPickupFocused)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _pickupController.clear();
                              _searchResults = _history;
                            });
                          },
                        ),
                      if (!_isPickupFocused)
                        Icon(
                          Icons.my_location,
                          size: 20,
                          color: Colors.blue[400],
                        ),
                        if(_isPickupFocused)
                      GestureDetector(
                        onTap: _openMapPickerForPickup,
                        child: SvgPicture.asset('assets/icons/grey_map.svg'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Destination field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isDestinationFocused
                        ? Colors.white
                        : AppStyle.inputBackgroundColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isDestinationFocused
                          ? const Color.fromRGBO(31, 140, 249, 1)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: Colors.red[400],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _destinationController,
                          focusNode: _destinationFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Destination',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      if (_destinationController.text.isNotEmpty && _isDestinationFocused)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _destinationController.clear();
                              _searchResults = _history;
                            });
                          },
                        ),
                      if (_isDestinationFocused)
                      GestureDetector(
                        onTap: _openMapPickerForDestination,
                        child: SvgPicture.asset(
                          'assets/icons/grey_map.svg',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //  Divider(height: 1, color: AppStyle.dividerColor(context),),

          // Search results or history
          if (showResults)
            Expanded(
              child: _isSearching
                  ? const Center(child: Loading())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            _pickupController.text.isEmpty && _destinationController.text.isEmpty
                                ? 'Recent searches will appear here'
                                : 'No results found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final place = _searchResults[index];
                            final isFromHistory = _history.contains(place);
                            return Container(
                              decoration: BoxDecoration(
                                                                  border: Border(
                              bottom: BorderSide(
                                color: AppStyle.borderColor(context),
                                width: 1,
                              ),
                            ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppStyle.inputBackgroundColor(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isFromHistory
                                        ? Icons.history
                                        : _getIconForPlaceType(place.types),
                                    size: 24,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                title: Text(
                                  place.mainText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: place.secondaryText.isNotEmpty
                                    ? Text(
                                        place.secondaryText,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      )
                                    : null,
                                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                onTap: () {
                                  if (_isPickupFocused) {
                                    _onPickupPlaceSelected(place);
                                  } else if (_isDestinationFocused) {
                                    _onDestinationPlaceSelected(place);
                                  }
                                },
                              ),
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }
}
