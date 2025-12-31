import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kiliride/components/loading.dart';
import 'package:kiliride/screens/rider/screens/location_picker.scrn.dart';
import 'package:kiliride/services/permission_service.service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSearchField extends StatefulWidget {
  final String googleApiKey;
  final void Function(Place) onPlaceSelected;
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final FormFieldValidator<String>? validator;
  final String? historyCacheKey;

  /// Whether to show the "Pick on Map" icon as a suffix. Defaults to true.
  final bool showMapPicker;

  // Scoping parameters
  final String? countryCode;
  final double? locationLat;
  final double? locationLng;
  final double? locationRadius;
  final String? title;
  final bool regionOnly;

  const PlaceSearchField({
    super.key,
    required this.googleApiKey,
    required this.onPlaceSelected,
    this.controller,
    this.decoration,
    this.validator,
    this.historyCacheKey,
    this.countryCode,
    this.locationLat,
    this.locationLng,
    this.locationRadius,
    this.title,
    this.regionOnly = false,
    this.showMapPicker = true, // --- NEW: Added parameter with default
  });

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  late final TextEditingController _controller;
  bool _isFetchingDetails = false;
  bool _isPickingOnMap = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  Future<void> _getPlaceDetailsAndFinalize(Place preliminaryResult) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${preliminaryResult.placeId}&fields=geometry,address_components&key=${widget.googleApiKey}';

    Place finalResult = preliminaryResult;

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          String? country;
          String? region;
          String? district;

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
                if (types.contains('administrative_area_level_2')) {
                  district = component['long_name'];
                }
              }
            }
          }
          finalResult = preliminaryResult.copyWith(
            latitude: location['lat'] as double,
            longitude: location['lng'] as double,
            country: country,
            region: region,
            district: district,
          );
        }
      }
    } catch (e) {
      debugPrint(
        "Error fetching place details, returning preliminary data: $e",
      );
    }

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      widget.onPlaceSelected(finalResult);
      setState(() => _isFetchingDetails = false);
    }
  }

  // (This function is unchanged)
  Future<void> _onPickOnMap() async {
    if (!mounted) return;

    final hasPermission = await PermissionService.handleLocationPermission(
      context,
    );
    if (!hasPermission) {
      Funcs.showSnackBar(
        message: "Location permission is required to use the map picker.",
        isSuccess: false,
      );
      return;
    }

    Position position;
    try {
      setState(() => _isPickingOnMap = true);
      Funcs.showLoadingDialog(
        context: context,
        message: "Getting your location...",
      );
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isPickingOnMap = false);
      Funcs.showSnackBar(
        message: "Could not get your current location: $e",
        isSuccess: false,
      );
      return;
    }

    if (!mounted) return;

    final newPlace = await Navigator.push<Place?>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: LatLng(position.latitude, position.longitude),
          appBarTitle: "Pick Location",
          confirmButtonText: "Confirm Location",
        ),
      ),
    );

    if (newPlace != null && mounted) {
      setState(() {
        _controller.text = newPlace.mainText;
      });
      widget.onPlaceSelected(newPlace);
    }

    setState(() => _isPickingOnMap = false);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  // --- MODIFIED: build() method
  @override
  Widget build(BuildContext context) {
    final bool isBusy = _isFetchingDetails || _isPickingOnMap;

    return TextFormField(
      controller: _controller,
      readOnly: true,
      style: TextStyle(color: isBusy ? Theme.of(context).disabledColor : null),
      decoration: (widget.decoration ?? const InputDecoration())
          .applyDefaults(Theme.of(context).inputDecorationTheme)
          .copyWith(
            hintText:
                (widget.decoration?.hintText ?? 'Tap to search for a place').tr,
            prefixIcon: widget.decoration?.prefixIcon,
            // --- MODIFIED: Conditional suffixIcon based on new parameter
            suffixIcon: widget.showMapPicker
                ? IconButton(
                    icon: Icon(
                      Icons.map_outlined,
                      color: AppStyle.primaryColor(context),
                    ),
                    onPressed: isBusy ? null : _onPickOnMap,
                  )
                : null, // If false, show nothing
          ),
      validator: widget.validator,
      onTap: isBusy
          ? null
          : () async {
              final preliminaryResult = await Navigator.push<Place?>(
                context,
                MaterialPageRoute(
                  builder: (context) => _PlaceSearchScreen(
                    apiKey: widget.googleApiKey,
                    countryCode: widget.countryCode,
                    locationLat: widget.locationLat,
                    locationLng: widget.locationLng,
                    locationRadius: widget.locationRadius,
                    historyCacheKey: widget.historyCacheKey,
                    title: widget.title,
                    regionOnly: widget.regionOnly,
                  ),
                ),
              );

              if (preliminaryResult != null && mounted) {
                setState(() {
                  _isFetchingDetails = true;
                  _controller.text = preliminaryResult.mainText;
                });
                Funcs.showLoadingDialog(
                  context: context,
                  message: "${"Getting details".tr}...",
                );
                _getPlaceDetailsAndFinalize(preliminaryResult);
              }
            },
    );
  }
}

//================================================================================
// Private Search Screen (MODIFIED)
//================================================================================
class _PlaceSearchScreen extends StatefulWidget {
  final String apiKey;
  final String? historyCacheKey;
  final String? countryCode;
  final double? locationLat;
  final double? locationLng;
  final double? locationRadius;
  final String? title;
  final bool regionOnly;

  const _PlaceSearchScreen({
    required this.apiKey,
    this.historyCacheKey,
    this.countryCode,
    this.locationLat,
    this.locationLng,
    this.locationRadius,
    this.title,
    required this.regionOnly,
  });

  @override
  State<_PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<_PlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Place> _predictions = [];
  List<Place> _history = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;

  static const _defaultHistoryKey = 'place_search_history';
  String get _historyKey => widget.historyCacheKey ?? _defaultHistoryKey;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    if (mounted) {
      setState(
        () => _history = historyJson
            .map((json) => Place.fromJsonString(json))
            .toList(),
      );
    }
  }

  Future<void> _saveToHistory(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    _history.removeWhere((p) => p.placeId == place.placeId);
    _history.insert(0, place);
    if (_history.length > 5) _history = _history.sublist(0, 5);
    final historyJson = _history.map((p) => p.toJsonString()).toList();
    await prefs.setStringList(_historyKey, historyJson);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    if (mounted) setState(() => _history = []);
  }

  void _onSearchChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _triggerSearch(input);
    });
  }

  Future<void> _triggerSearch(String input) async {
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }
    if (input.length < 2) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${widget.apiKey}';

    if (widget.regionOnly) {
      url += '&types=(regions)';
    }

    if (widget.countryCode != null && widget.countryCode!.isNotEmpty) {
      url += '&components=country:${widget.countryCode}';
    } else if (widget.locationLat != null &&
        widget.locationLng != null &&
        widget.locationRadius != null) {
      url +=
          '&locationbias=circle:${widget.locationRadius}@${widget.locationLat},${widget.locationLng}';
    }

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          if (mounted) {
            setState(
              () => _predictions = (data['predictions'] as List)
                  .map((p) => Place.fromJson(p))
                  .toList(),
            );
          }
        } else {
          if (mounted) setState(() => _errorMessage = data['error_message']);
        }
      } else {
        if (mounted) setState(() => _errorMessage = "Connection error.");
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "Network error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    if (types.contains('bank')) return Icons.account_balance;
    if (types.contains('hospital') ||
        types.contains('doctor') ||
        types.contains('pharmacy')) {
      return Icons.local_hospital;
    }
    return Icons.location_on_outlined;
  }

  Widget _buildHighlightedText(String text, BuildContext context) {
    final words = text.split(' ');
    if (words.isEmpty) {
      return Text(text);
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: words.first,
            style: TextStyle(
              color: AppStyle.primaryColor(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (words.length > 1)
            TextSpan(
              text: ' ${words.skip(1).join(' ')}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  // --- MODIFIED: build() method
  @override
  Widget build(BuildContext context) {
    Widget buildList(List<Place> places, {bool isHistory = false}) {
      return ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_getIconForPlaceType(place.types)),
            title: _buildHighlightedText(place.mainText, context),
            subtitle: Text(place.secondaryText),
            onTap: () {
              //  Always enabled tap
              if (!isHistory) _saveToHistory(place);
              Navigator.pop(context, place);
            },
          );
        },
      );
    }

    // --- MODIFIED: Refined buildBody logic
    Widget buildBody() {
      // Show history if the search is empty
      if (_searchController.text.isEmpty) {
        return buildList(_history, isHistory: true);
      }

      // Show error if one exists
      if (_errorMessage != null) {
        return Center(child: Text('Error: $_errorMessage'));
      }

      // If we are loading and have no results to show, show a spinner
      if (_isLoading && _predictions.isEmpty) {
        return Loading();
      }

      // If we are NOT loading and have no results, show "No results"
      if (!_isLoading &&
          _predictions.isEmpty &&
          _searchController.text.isNotEmpty) {
        return Center(child: Text('No results found.'.tr));
      }

      // Otherwise, show the predictions (stale or new)
      return buildList(_predictions);
    }

    return Scaffold(
      backgroundColor: AppStyle.appColor(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search ${widget.title ?? "Place"}',
          style: TextStyle(
            fontSize: AppStyle.appFontSizeLG,
            fontWeight: FontWeight.w500,
            color: AppStyle.textColored(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyle.appPadding),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              // --- REMOVED: enabled: !_isLoading ---
              // This is the fix that keeps the keyboard open
              decoration: InputDecoration(
                hintText: 'Enter an address'.tr,
                // --- NEW: Suffix icon for loading or clearing
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _triggerSearch(''); // Clear results
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),

            if (_searchController.text.isEmpty && _history.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyle.appPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _clearHistory,
                      child: Text('Clear'.tr),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppStyle.appGap),
            Expanded(child: buildBody()),
          ],
        ),
      ),
    );
  }
}

//================================================================================
// The data class for structured place information (No changes in this section)
//================================================================================
class Place {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;
  final List<String> types;
  final double? latitude;
  final double? longitude;
  final String? country;
  final String? region;
  final String? district;

  Place({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
    required this.types,
    this.latitude,
    this.longitude,
    this.country,
    this.region,
    this.district,
  });

  Place copyWith({
    double? latitude,
    double? longitude,
    String? country,
    String? region,
    String? district,
  }) => Place(
    placeId: placeId,
    mainText: mainText,
    secondaryText: secondaryText,
    description: description,
    types: types,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    country: country ?? this.country,
    region: region ?? this.region,
    district: district ?? this.district,
  );

  Map<String, dynamic> toJson() => {
    'place_id': placeId,
    'main_text': mainText,
    'secondary_text': secondaryText,
    'description': description,
    'types': types,
    'latitude': latitude,
    'longitude': longitude,
    'country': country,
    'region': region,
    'district': district,
  };

  factory Place.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>?;
    return Place(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
      mainText:
          json['main_text'] as String? ??
          structuredFormatting?['main_text'] as String? ??
          '',
      secondaryText:
          json['secondary_text'] as String? ??
          structuredFormatting?['secondary_text'] as String? ??
          '',
      types: List<String>.from(json['types'] as List? ?? []),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      country: json['country'] as String?,
      region: json['region'] as String?,
      district: json['district'] as String?,
    );
  }

  String toJsonString() => json.encode(toJson());
  factory Place.fromJsonString(String jsonString) =>
      Place.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
