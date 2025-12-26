import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'dart:ui' as ui;

class  MapUtils{

  static double radsToDegrees(num rad) {
    return (rad * 180.0) / pi;
  }

  static double getRotation(LatLng start, LatLng end) {
  double latDifference    = (start.latitude - end.latitude).abs();
  double lngDifference    = (start.longitude - end.longitude).abs();
  double rotation = -1;

  if(start.latitude < end.latitude && start.longitude < end.longitude) {
  rotation = radsToDegrees(atan(lngDifference / latDifference)).toDouble();
  }
  else if (start.latitude >= end.latitude && start.longitude < end.longitude) {
  rotation = (90 - radsToDegrees(atan(lngDifference / latDifference)) + 90).toDouble();
  }
  else if(start.latitude >= end.latitude && start.longitude >= end.longitude) {
  rotation = (radsToDegrees(atan(lngDifference / latDifference)) + 180).toDouble();
  }
  else if (start.latitude < end.latitude && start.longitude >= end.longitude) {
  rotation =
  (90 - radsToDegrees(atan(lngDifference / latDifference)) + 270).toDouble();
  }

  return rotation;
}


}