import 'package:cloud_firestore/cloud_firestore.dart';

class TrustedContact {
  final String? id;
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String relationship;
  final DateTime? dateAdded;
  final DateTime? dateUpdated;

  TrustedContact({
    this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.relationship,
    this.dateAdded,
    this.dateUpdated,
  });

  // Getter for full name
  String get fullName => '$firstName $lastName';

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    // Convert dateAdded and dateUpdated from Timestamp to DateTime
    DateTime? dateAdded;
    if (json['dateAdded'] != null) {
      if (json['dateAdded'] is Timestamp) {
        dateAdded = (json['dateAdded'] as Timestamp).toDate();
      } else if (json['dateAdded'] is String) {
        try {
          dateAdded = DateTime.parse(json['dateAdded']);
        } catch (e) {
          // Invalid date string, leave as null
        }
      }
    }

    DateTime? dateUpdated;
    if (json['dateUpdated'] != null) {
      if (json['dateUpdated'] is Timestamp) {
        dateUpdated = (json['dateUpdated'] as Timestamp).toDate();
      } else if (json['dateUpdated'] is String) {
        try {
          dateUpdated = DateTime.parse(json['dateUpdated']);
        } catch (e) {
          // Invalid date string, leave as null
        }
      }
    }

    return TrustedContact(
      id: json['id'],
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      relationship: json['relationship'] ?? '',
      dateAdded: dateAdded,
      dateUpdated: dateUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'dateAdded': dateAdded != null ? Timestamp.fromDate(dateAdded!) : null,
      'dateUpdated': dateUpdated != null
          ? Timestamp.fromDate(dateUpdated!)
          : null,
    };
  }

  // Create a copy of the trusted contact with updated fields
  TrustedContact copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? relationship,
    DateTime? dateAdded,
    DateTime? dateUpdated,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      dateAdded: dateAdded ?? this.dateAdded,
      dateUpdated: dateUpdated ?? this.dateUpdated,
    );
  }

  static TrustedContact createFromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    // Handle dateAdded and dateUpdated
    DateTime? dateAdded;
    if (data['dateAdded'] != null) {
      if (data['dateAdded'] is Timestamp) {
        dateAdded = (data['dateAdded'] as Timestamp).toDate();
      } else if (data['dateAdded'] is DateTime) {
        dateAdded = data['dateAdded'] as DateTime;
      }
    }

    DateTime? dateUpdated;
    if (data['dateUpdated'] != null) {
      if (data['dateUpdated'] is Timestamp) {
        dateUpdated = (data['dateUpdated'] as Timestamp).toDate();
      } else if (data['dateUpdated'] is DateTime) {
        dateUpdated = data['dateUpdated'] as DateTime;
      }
    }

    return TrustedContact(
      id: documentId,
      userId: data['userId'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      relationship: data['relationship'] ?? '',
      dateAdded: dateAdded,
      dateUpdated: dateUpdated,
    );
  }

  @override
  String toString() {
    return 'TrustedContact{id: $id, fullName: $fullName, phoneNumber: $phoneNumber, relationship: $relationship}';
  }
}

// Enum for predefined relationships
enum RelationshipType {
  family('Family'),
  friend('Friend'),
  spouse('Spouse'),
  parent('Parent'),
  sibling('Sibling'),
  child('Child'),
  colleague('Colleague'),
  neighbor('Neighbor'),
  other('Other');

  const RelationshipType(this.displayName);
  final String displayName;

  static List<String> getAllDisplayNames() {
    return RelationshipType.values.map((e) => e.displayName).toList();
  }

  static RelationshipType? fromDisplayName(String displayName) {
    try {
      return RelationshipType.values.firstWhere(
        (e) => e.displayName.toLowerCase() == displayName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
