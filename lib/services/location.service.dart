// import 'package:dio/dio.dart';
// import 'package:flexi/provider/constants.dart';
// import 'package:google_places_autocomplete_text_field/model/place_details.dart'
//     as place_details;

// Future<String> getPlaceAddress(double lat, double lng) async {
//   final dio = Dio();
//   final url =
//       'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleMapApiKey';

//   try {
//     final response = await dio.get(url);

//     if (response.statusCode == 200) {
//       final responseData = response.data;
//       if (responseData['results'] != null &&
//           responseData['results'].isNotEmpty) {
//         return responseData['results'][0]['formatted_address'];
//       }
//     }
//     return 'Unknown location';
//   } catch (e) {
//     print('Dio error: $e');
//     return 'FAILED TO GET LOCATION';
//   }
// }

// Future<place_details.Geometry> getLatLngFromPlaceIdValue(String placeId) async {
//   try {
//     final apiUrl =
//         'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapApiKey';

//     final dio = Dio();

//     final response = await dio.get(apiUrl);


//     if (response.statusCode == 200) {

//       print('Full Response: ${response.toString()}');

//       try {
//         final data = response.data;
//         final location = data['result']['geometry']['location'];
//         final latitude = location['lat'];
//         final longitude = location['lng'];

//         return place_details.Geometry(
//           location: place_details.Location(lat: latitude, lng: longitude),
//         );
//       } catch (e) {
//         print('Error decoding JSON: $e');
//         return place_details.Geometry(
//             location: place_details.Location(lat: 0, lng: 0));
//       }
//     } else {
//       print('Error getting lat lng from place id: ${response.statusCode}');
//       return place_details.Geometry(
//           location: place_details.Location(lat: 0, lng: 0));
//     }
//   } catch (error) {
//     print('Error getting lat lng from place id: $error');
//     return place_details.Geometry(
//         location: place_details.Location(lat: 0, lng: 0));
//   }
// }

// Future<String> getLocationName(double latitude, double longitude) async {
//   final url = 'https://nominatim.openstreetmap.org/reverse.php?lat=$latitude&lon=$longitude&format=jsonv2';
//   final dio = Dio();

//   try {
//     final response = await dio.get(url);
//     if (response.statusCode == 200) {
//       return response.data['display_name'] ;
//     } else {
//       print("Error fetching location: ${response.statusCode}");
//       return "Error";
//     }
//   } catch (error) {
//     print("Error fetching location: $error");
//     return "Error fetching location";
//   }
// }