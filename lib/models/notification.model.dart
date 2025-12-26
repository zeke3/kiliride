import 'package:cloud_firestore/cloud_firestore.dart';

class CustomNotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String actionType;
  final Map<String, dynamic> data;
  final String userId;
  final DateTime createdAt;
  final bool isRead;
  final bool isProduction; // For production/development data separation
  final String? jobId;
  final String? jobTitle;
  final String? senderId;
  final String? senderName;

  CustomNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.actionType,
    required this.data,
    required this.userId,
    required this.createdAt,
    this.isRead = false,
    this.isProduction = false, // Default to development
    this.jobId,
    this.jobTitle,
    this.senderId,
    this.senderName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'actionType': actionType,
      'data': data,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'isProduction': isProduction,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'senderId': senderId,
      'senderName': senderName,
    };
  }

  factory CustomNotificationModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert timestamps
    DateTime convertTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return CustomNotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      actionType: json['actionType'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      userId: json['userId'] ?? '',
      createdAt: convertTimestamp(json['createdAt']),
      isRead: json['isRead'] ?? false,
      isProduction: json['isProduction'] ?? false,
      jobId: json['jobId'],
      jobTitle: json['jobTitle'],
      senderId: json['senderId'],
      senderName: json['senderName'],
    );
  }

  CustomNotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    String? actionType,
    Map<String, dynamic>? data,
    String? userId,
    DateTime? createdAt,
    bool? isRead,
    bool? isProduction,
    String? jobId,
    String? jobTitle,
    String? senderId,
    String? senderName,
  }) {
    return CustomNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      actionType: actionType ?? this.actionType,
      data: data ?? this.data,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isProduction: isProduction ?? this.isProduction,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
    );
  }
}
