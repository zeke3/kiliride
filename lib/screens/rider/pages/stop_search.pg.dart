// // Stop Search Page - simplified location search for adding stops
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:kiliride/components/loading.dart';
// import 'package:kiliride/components/place_search_field.dart';
// import 'package:http/http.dart' as http;
// import 'package:kiliride/shared/constants.dart';
// import 'package:kiliride/shared/styles.shared.dart';

// class _StopSearchPage extends StatefulWidget {
//   final Function(Place) onStopSelected;

//   const _StopSearchPage({required this.onStopSelected});

//   @override
//   State<_StopSearchPage> createState() => _StopSearchPageState();
// }

// class _StopSearchPageState extends State<_StopSearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Place> _searchResults = [];
//   bool _isSearching = false;
//   Timer? _debounce;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();

//     if (query.isEmpty) {
//       setState(() {
//         _searchResults = [];
//         _isSearching = false;
//       });
//       return;
//     }

//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       _searchPlaces(query);
//     });
//   }

//   Future<void> _searchPlaces(String input) async {
//     if (input.isEmpty || input.length < 2) {
//       setState(() {
//         _searchResults = [];
//         _isSearching = false;
//       });
//       return;
//     }

//     setState(() => _isSearching = true);

//     var url =
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleMapApiKey&components=country:tz';

//     try {
//       final response = await http
//           .get(Uri.parse(url))
//           .timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           if (mounted) {
//             setState(() {
//               _searchResults = (data['predictions'] as List)
//                   .map((p) => Place.fromJson(p))
//                   .toList();
//               _isSearching = false;
//             });
//           }
//         } else {
//           if (mounted) {
//             setState(() {
//               _searchResults = [];
//               _isSearching = false;
//             });
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Search error: $e');
//       if (mounted) {
//         setState(() {
//           _searchResults = [];
//           _isSearching = false;
//         });
//       }
//     }
//   }

//   Future<Place> _getPlaceDetails(Place preliminaryPlace) async {
//     final url =
//         'https://maps.googleapis.com/maps/api/place/details/json?place_id=${preliminaryPlace.placeId}&fields=geometry,address_components&key=$googleMapApiKey';

//     try {
//       final response = await http
//           .get(Uri.parse(url))
//           .timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           final result = data['result'];
//           final location = result['geometry']['location'];

//           return preliminaryPlace.copyWith(
//             latitude: location['lat'] as double,
//             longitude: location['lng'] as double,
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching place details: $e');
//     }

//     return preliminaryPlace;
//   }

//   void _onPlaceSelected(Place place) async {
//     final detailedPlace = await _getPlaceDetails(place);
//     widget.onStopSelected(detailedPlace);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppStyle.appColor(context),
//       appBar: AppBar(
//         backgroundColor: AppStyle.appColor(context),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Add stop',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: 'Search for a place',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           setState(() {
//                             _searchController.clear();
//                             _searchResults = [];
//                           });
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//               onChanged: _onSearchChanged,
//             ),
//           ),
//           Expanded(
//             child: _isSearching
//                 ? const Center(child: Loading())
//                 : _searchResults.isEmpty
//                 ? Center(
//                     child: Text(
//                       _searchController.text.isEmpty
//                           ? 'Search for a place to add as a stop'
//                           : 'No results found',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: _searchResults.length,
//                     itemBuilder: (context, index) {
//                       final place = _searchResults[index];
//                       return Container(
//                         decoration: BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               color: AppStyle.borderColor(context),
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: ListTile(
//                           leading: Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: AppStyle.inputBackgroundColor(context),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.location_on_outlined,
//                               size: 24,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           title: Text(
//                             place.mainText,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           subtitle: place.secondaryText.isNotEmpty
//                               ? Text(
//                                   place.secondaryText,
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey[600],
//                                   ),
//                                 )
//                               : null,
//                           trailing: const Icon(
//                             Icons.chevron_right,
//                             color: Colors.grey,
//                           ),
//                           onTap: () => _onPlaceSelected(place),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
