import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a vehicle registered by a driver in Firestore
class DriverVehicle {
  final String? id;
  final String driverId;
  final String vehicleType;
  final String? vehicleName;
  final String makeAndModel;
  final String? registrationNumber;
  final int? seats;
  final String? fuelType;
  final List<String> features;
  final double? basePrice;
  final double? ratePerDay; // ADDED
  final double? ratePerKm; // ADDED
  final List<String> acceptedHireTypes; // ADDED: ['Day', 'Km']

  // RESTORED FIELDS
  final String? chargeType;
  final double? chargeRate;
  final String? regionOfOperation;
  final List<String>? availabilityDays;
  final String insuranceType;
  final String legalPapersUrl;
  final String insuranceDocsUrl;
  final String frontImageUrl;
  final String sideImageUrl;
  final String rearImageUrl;
  final String? otherImageUrl;
  final String hireType;
  final String? color;
  final bool booked;
  final Timestamp createdAt;
  final List searchTerms;
  final List<String> serviceTypes;
  final String? district;
  final GeoPoint? vehicleLocation;
  final String? status;

  DriverVehicle({
    this.id,
    required this.driverId,
    required this.vehicleType,
    this.vehicleName,
    required this.makeAndModel,
    this.registrationNumber,
    this.seats,
    this.fuelType,
    required this.features,
    this.basePrice,
    this.chargeType,
    this.chargeRate,
    this.regionOfOperation,
    this.availabilityDays,
    required this.insuranceType,
    required this.legalPapersUrl,
    required this.insuranceDocsUrl,
    required this.frontImageUrl,
    required this.sideImageUrl,
    required this.rearImageUrl,
    this.otherImageUrl,
    required this.hireType,
    this.color,
    required this.booked,
    required this.createdAt,
    required this.searchTerms,
    required this.serviceTypes,
    this.district,
    this.vehicleLocation,
    this.status,
    this.ratePerDay, // ADDED
    this.ratePerKm, // ADDED
    this.acceptedHireTypes = const [], // ADDED
  });

  /// Converts the DriverVehicle instance to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'vehicleType': vehicleType,
      'vehicleName': vehicleName,
      'makeAndModel': makeAndModel,
      'registrationNumber': registrationNumber,
      'seats': seats,
      'fuelType': fuelType,
      'features': features,
      'basePrice': basePrice,
      'chargeType': chargeType,
      'chargeRate': chargeRate,
      'regionOfOperation': regionOfOperation,
      'availabilityDays': availabilityDays,
      'insuranceType': insuranceType,
      'legalPapersUrl': legalPapersUrl,
      'insuranceDocsUrl': insuranceDocsUrl,
      'frontImageUrl': frontImageUrl,
      'sideImageUrl': sideImageUrl,
      'rearImageUrl': rearImageUrl,
      'otherImageUrl': otherImageUrl,
      'hireType': hireType,
      'color': color,
      'booked': booked,
      'searchTerms': searchTerms,
      'createdAt': createdAt,
      'serviceTypes': serviceTypes,
      'district': district,
      'vehicleLocation': vehicleLocation,
      'status': status,
      'ratePerDay': ratePerDay, // ADDED
      'ratePerKm': ratePerKm, // ADDED
      'acceptedHireTypes': acceptedHireTypes, // ADDED
    };
  }

  /// Factory constructor to create an instance from a map.
  factory DriverVehicle.fromMap(Map<String, dynamic> data, String id) {
    // Backward compatibility: If serviceTypes is missing, use vehicleType if it looks like a service
    List<String> services = [];
    if (data['serviceTypes'] != null) {
      services = List<String>.from(data['serviceTypes']);
    } else {
      // Fallback: If no serviceTypes, assume the old vehicleType was actually the service type
      // (e.g. 'Wedding Convoy', 'Transfers')
      if (data['vehicleType'] != null) {
        services.add(data['vehicleType']);
      }
    }

    // Backward compatibility for pricing
    double? rPerDay = data['ratePerDay'] != null
        ? double.parse(data['ratePerDay'].toString())
        : null;
    double? rPerKm = data['ratePerKm'] != null
        ? double.parse(data['ratePerKm'].toString())
        : null;
    List<String> hireTypes = data['acceptedHireTypes'] != null
        ? List<String>.from(data['acceptedHireTypes'])
        : [];

    // Migrate old format if new fields are empty
    if (hireTypes.isEmpty) {
      if (data['chargeRate'] != null) {
        // If old chargeType was 'Per Hour' (rare/not implemented fully), we might map to day?
        // But predominantly it was 'Per Km'.
        // Let's assume 'Per Km' if chargeType says so or if missing.
        if (data['chargeType'] == 'Per Km' || data['chargeType'] == null) {
          rPerKm = double.tryParse(data['chargeRate'].toString());
          hireTypes.add('Km');
        } else if (data['chargeType'] == 'Day Hire') {
          // hypothetical old value
          rPerDay = double.tryParse(data['chargeRate'].toString());
          hireTypes.add('Day');
        } else {
          // Default fallback
          rPerKm = double.tryParse(data['chargeRate'].toString());
          hireTypes.add('Km');
        }
      }
    }

    return DriverVehicle(
      id: id,
      driverId: data['driverId'] ?? '',
      vehicleType: data['vehicleType'] ?? '',
      vehicleName: data['vehicleName'],
      makeAndModel: data['makeAndModel'] ?? '',
      registrationNumber: data['registrationNumber'],
      seats: data['seats'],
      fuelType: data['fuelType'],
      features: List<String>.from(data['features'] ?? []),
      basePrice: data['basePrice'] == null
          ? null
          : double.parse(data['basePrice'].toString()),
      chargeType: data['chargeType'],
      chargeRate: data['chargeRate'] == null
          ? null
          : double.parse(data['chargeRate'].toString()),
      regionOfOperation: data['regionOfOperation'],
      availabilityDays: data['availabilityDays'] != null
          ? List<String>.from(data['availabilityDays'])
          : null,
      insuranceType: data['insuranceType'] ?? '',
      legalPapersUrl: data['legalPapersUrl'] ?? '',
      insuranceDocsUrl: data['insuranceDocsUrl'] ?? '',
      frontImageUrl: data['frontImageUrl'] ?? '',
      sideImageUrl: data['sideImageUrl'] ?? '',
      rearImageUrl: data['rearImageUrl'] ?? '',
      otherImageUrl: data['otherImageUrl'],
      hireType: data['hireType'] ?? 'Normal Ride',
      color: data['color'] ?? "N/A",
      booked: data['booked'] ?? false,
      searchTerms: data['searchTerms'] ?? [],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      serviceTypes: services,
      district: data['district'],
      vehicleLocation: data['vehicleLocation'],
      // Default status to 'active' for older vehicles that don't have a status field
      status: data['status'] ?? 'active',
      ratePerDay: rPerDay,
      ratePerKm: rPerKm,
      acceptedHireTypes: hireTypes,
    );
  }
}
