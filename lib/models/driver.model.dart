import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final String id; // This will be the same as the user's UID
  final String fullName;
  final String gender;
  final String residentialAddress;
  final String nidaNumber;
  final String licenseNumber;
  final String selfieImageUrl;
  final String nidaFrontUrl;
  final String nidaBackUrl;
  final String licenseFrontUrl;
  final String licenseBackUrl;
  final String transactionPhone;
  final String status; // e.g., 'pending_approval', 'approved', 'disapproved'
  final String? rejectionReason; // Reason if status is 'disapproved'
  final bool isOnline;
  final String driverType; // 'Normal Ride' or 'Special Hire'
  final GeoPoint? currentLocation;
  final List<String> searchTerms;
  final Timestamp createdAt;
  final bool
  isOwner; // NEW: True if Fleet Owner/Special Hire, False if Invited Driver

  // Commission blocking fields
  final bool isBlocked;
  final String? blockReason;
  final Timestamp? blockedAt;
  final Timestamp? lastPaymentDate;
  final double totalCommissionDebt;
  final double totalCommissionPaid;

  DriverModel({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.residentialAddress,
    required this.nidaNumber,
    required this.licenseNumber,
    required this.selfieImageUrl,
    required this.nidaFrontUrl,
    required this.nidaBackUrl,
    required this.licenseFrontUrl,
    required this.licenseBackUrl,
    required this.transactionPhone,
    required this.status,
    this.rejectionReason,
    required this.isOnline,
    required this.driverType,
    this.currentLocation,
    required this.searchTerms,
    this.isOwner = false, // Default to false
    required this.createdAt,
    this.isBlocked = false,
    this.blockReason,
    this.blockedAt,
    this.lastPaymentDate,
    this.totalCommissionDebt = 0.0,
    this.totalCommissionPaid = 0.0,
  });

  /// Converts the DriverModel instance to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'gender': gender,
      'residentialAddress': residentialAddress,
      'nidaNumber': nidaNumber,
      'licenseNumber': licenseNumber,
      'selfieImageUrl': selfieImageUrl,
      'nidaFrontUrl': nidaFrontUrl,
      'nidaBackUrl': nidaBackUrl,
      'licenseFrontUrl': licenseFrontUrl,
      'licenseBackUrl': licenseBackUrl,
      'transactionPhone': transactionPhone,
      'status': status,
      'rejectionReason': rejectionReason,
      'isOnline': isOnline,
      'driverType': driverType,
      'currentLocation': currentLocation,
      'searchTerms': searchTerms,
      'createdAt': createdAt,
      'isOwner': isOwner,
      'isBlocked': isBlocked,
      'blockReason': blockReason,
      'blockedAt': blockedAt,
      'lastPaymentDate': lastPaymentDate,
      'totalCommissionDebt': totalCommissionDebt,
      'totalCommissionPaid': totalCommissionPaid,
    };
  }

  /// Factory constructor to create a DriverModel from a Firestore map.
  factory DriverModel.fromMap(Map<String, dynamic> data, String id) {
    return DriverModel(
      id: id,
      fullName: data['fullName'] ?? '',
      isOwner: data['isOwner'] ?? false,
      gender: data['gender'] ?? '',
      residentialAddress: data['residentialAddress'] ?? '',
      nidaNumber: data['nidaNumber'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      selfieImageUrl: data['selfieImageUrl'] ?? '',
      nidaFrontUrl: data['nidaFrontUrl'] ?? '',
      nidaBackUrl: data['nidaBackUrl'] ?? '',
      licenseFrontUrl: data['licenseFrontUrl'] ?? '',
      licenseBackUrl: data['licenseBackUrl'] ?? '',
      transactionPhone: data['transactionPhone'] ?? '',
      status: data['status'] ?? 'pending_approval',
      rejectionReason: data['rejectionReason'],
      isOnline: data['isOnline'] ?? false,
      driverType: data['driverType'] ?? 'Normal Ride',
      currentLocation: data['currentLocation'],
      searchTerms: List<String>.from(data['searchTerms'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isBlocked: data['isBlocked'] ?? false,
      blockReason: data['blockReason'],
      blockedAt: data['blockedAt'],
      lastPaymentDate: data['lastPaymentDate'],
      totalCommissionDebt:
          (data['totalCommissionDebt'] as num?)?.toDouble() ?? 0.0,
      totalCommissionPaid:
          (data['totalCommissionPaid'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Creates a copy of this DriverModel but with the given fields replaced with the new values.
  DriverModel copyWith({
    String? id,
    String? fullName,
    String? gender,
    String? residentialAddress,
    String? nidaNumber,
    String? licenseNumber,
    String? selfieImageUrl,
    String? nidaFrontUrl,
    String? nidaBackUrl,
    String? licenseFrontUrl,
    String? licenseBackUrl,
    String? transactionPhone,
    String? status,
    String? rejectionReason,
    bool? isOnline,
    String? driverType,
    GeoPoint? currentLocation,
    List<String>? searchTerms,
    Timestamp? createdAt,
    bool? isOwner, // NEW
    bool? isBlocked,
    String? blockReason,
    Timestamp? blockedAt,
    Timestamp? lastPaymentDate,
    double? totalCommissionDebt,
    double? totalCommissionPaid,
  }) {
    return DriverModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      nidaNumber: nidaNumber ?? this.nidaNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      selfieImageUrl: selfieImageUrl ?? this.selfieImageUrl,
      nidaFrontUrl: nidaFrontUrl ?? this.nidaFrontUrl,
      nidaBackUrl: nidaBackUrl ?? this.nidaBackUrl,
      licenseFrontUrl: licenseFrontUrl ?? this.licenseFrontUrl,
      licenseBackUrl: licenseBackUrl ?? this.licenseBackUrl,
      transactionPhone: transactionPhone ?? this.transactionPhone,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isOnline: isOnline ?? this.isOnline,
      driverType: driverType ?? this.driverType,
      currentLocation: currentLocation ?? this.currentLocation,
      searchTerms: searchTerms ?? this.searchTerms,
      createdAt: createdAt ?? this.createdAt,
      isOwner: isOwner ?? this.isOwner, // NEW
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      blockedAt: blockedAt ?? this.blockedAt,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      totalCommissionDebt: totalCommissionDebt ?? this.totalCommissionDebt,
      totalCommissionPaid: totalCommissionPaid ?? this.totalCommissionPaid,
    );
  }
}
