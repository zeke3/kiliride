// Route Editor Screen for managing stops
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kiliride/components/loading.dart';
import 'package:kiliride/components/place_search_field.dart';
import 'package:kiliride/shared/constants.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:http/http.dart' as http;

class RouteEditorScreen extends StatefulWidget {
  final Place pickupPlace;
  final Place destinationPlace;
  final List<Place> initialStops;

  const RouteEditorScreen({
    super.key,
    required this.pickupPlace,
    required this.destinationPlace,
    required this.initialStops,
  });

  @override
  State<RouteEditorScreen> createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends State<RouteEditorScreen> {
  late List<Place> _stops;
  late Place _destination;
  bool _isAddingStop = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Place> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _stops = List.from(widget.initialStops);
    _destination = widget.destinationPlace;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _addStop() {
    setState(() {
      _isAddingStop = true;
    });
    // Focus the search field
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocusNode.requestFocus();
    });
  }

  void _cancelAddStop() {
    setState(() {
      _isAddingStop = false;
      _searchController.clear();
      _searchResults = [];
      _isSearching = false;
    });
    _searchFocusNode.unfocus();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
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
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleMapApiKey&components=country:tz';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

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
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];

          return preliminaryPlace.copyWith(
            latitude: location['lat'] as double,
            longitude: location['lng'] as double,
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }

    return preliminaryPlace;
  }

  void _onPlaceSelected(Place place) async {
    final detailedPlace = await _getPlaceDetails(place);
    if (!mounted) return;
    setState(() {
      _stops.add(detailedPlace);
      _isAddingStop = false;
      _searchController.clear();
      _searchResults = [];
    });
    _searchFocusNode.unfocus();
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  void _removeDestination() {
    // When destination is removed, it becomes a regular stop
    setState(() {
      if (_stops.isNotEmpty) {
        _destination = _stops.removeLast();
      }
    });
  }

  void _reorderStops(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Create a combined list with all stops + destination
      final allStops = [..._stops, _destination];

      // Reorder the combined list
      final item = allStops.removeAt(oldIndex);
      allStops.insert(newIndex, item);

      // Split back into stops and destination
      _destination = allStops.removeLast();
      _stops = allStops;
    });
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: Loading());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Search for a place to add as a stop'
              : 'No results found',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final place = _searchResults[index];
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
                Icons.location_on_outlined,
                size: 24,
                color: Colors.grey[700],
              ),
            ),
            title: Text(
              place.mainText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: place.secondaryText.isNotEmpty
                ? Text(
                    place.secondaryText,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  )
                : null,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _onPlaceSelected(place),
          ),
        );
      },
    );
  }

  Widget _buildStopsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // All stops including destination are now part of the list
          ReorderableListView(
            onReorder: _reorderStops,
            buildDefaultDragHandles: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Regular stops
              ..._stops.asMap().entries.map((entry) {
                return _buildRouteItem(
                  key: ValueKey('stop_${entry.key}'),
                  icon: Icons.circle,
                  iconColor: Colors.orange[600]!,
                  text: entry.value.mainText,
                  isRemovable: true,
                  isDraggable: true,
                  onRemove: () => _removeStop(entry.key),
                  index: entry.key,
                );
              }),
              // Destination (last stop, can be reordered and removed)
              _buildRouteItem(
                key: const ValueKey('destination'),
                icon: Icons.circle,
                iconColor: Colors.red[600]!,
                text: _destination.mainText,
                isRemovable: true,
                isDraggable: true,
                onRemove: () => _removeDestination(),
                index: _stops.length,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.appColor(context),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppStyle.appColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your route',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Pickup location (fixed at top)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildRouteItem(
                    key: const ValueKey('pickup'),
                    icon: Icons.circle,
                    iconColor: Colors.green[600]!,
                    text: widget.pickupPlace.mainText,
                    isRemovable: false,
                    isDraggable: false,
                  ),
                ),
                if (_stops.length < 4)
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 24,
                      color: AppStyle.secondaryColor(context),
                    ),
                    onPressed: _addStop,
                    // padding: const EdgeInsets.only(left: 8),
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          // Search field (only visible when adding a stop)
          if (_isAddingStop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search for a place',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelAddStop,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

          // Content area - either search results or stops list
          Expanded(
            child: _isAddingStop ? _buildSearchResults() : _buildStopsList(),
          ),
          // Add stop button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'stops': _stops,
                    'destination': _destination,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.primaryColor(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem({
    required Key key,
    required IconData icon,
    required Color iconColor,
    required String text,
    required bool isRemovable,
    required bool isDraggable,
    VoidCallback? onRemove,
    int? index, // Add this for the drag listener
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: AppStyle.appGap / 2),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: AppStyle.appGap + 2,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppStyle.borderColor(context)),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 12, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDraggable)
                    ReorderableDragStartListener(
                      index: index!,
                      child: Icon(
                        Icons.drag_handle,
                        size: 24,
                        color: Colors.grey[400],
                      ),
                    )
                  else
                    const SizedBox(width: 24),
                ],
              ),
            ),
          ),
          // Remove button (only visible for removable items)
          if (isRemovable)
            IconButton(
              icon: Icon(Icons.remove_circle, size: 24, color: Colors.red[400]),
              onPressed: onRemove,
              padding: const EdgeInsets.only(left: 8),
              constraints: const BoxConstraints(),
            )
          else
            const SizedBox(width: AppStyle.appGap),
        ],
      ),
    );
  }
}
