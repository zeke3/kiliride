import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:kiliride/models/notification.model.dart';
import 'package:kiliride/models/user.model.dart';
// import 'package:kiliride/models/user_verification.model.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/controllers/notification_handler.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DBService {
  final appDataRef = FirebaseFirestore.instance.collection('appData');
  final usersRef = FirebaseFirestore.instance.collection('users');
  final userVerificationRef = FirebaseFirestore.instance.collection(
    'userVerification',
  );

  final _firestore = FirebaseFirestore.instance;

  // Utility method to retry Firestore operations with exponential backoff
  Future<T> retryFirestoreOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    String operationName = 'Firestore operation',
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        retryCount++;

        // Check if this is a transient error and we have retries left
        bool isTransientError =
            e.toString().contains('unavailable') ||
            e.toString().contains('deadline-exceeded') ||
            e.toString().contains('internal') ||
            e.toString().contains('resource-exhausted') ||
            e.toString().contains('network') ||
            e.toString().contains('connection');

        if (isTransientError && retryCount < maxRetries) {
          // Exponential backoff: wait 1s, then 2s, then 4s
          int delaySeconds = pow(2, retryCount - 1).toInt();
          if (kDebugMode) {
            print(
              '$operationName failed (attempt $retryCount/$maxRetries), retrying in ${delaySeconds}s: $e',
            );
          }
          await Future.delayed(Duration(seconds: delaySeconds));
          continue;
        }

        // If we've exhausted retries or it's a non-transient error, rethrow
        if (kDebugMode) {
          print('$operationName failed after $retryCount attempts: $e');
        }
        rethrow;
      }
    }

    throw Exception('$operationName failed after $maxRetries attempts');
  }

  // Safe method to get user document with retry logic
  Future<DocumentSnapshot?> safeGetUserDocument(String uid) async {
    try {
      return await retryFirestoreOperation(
        () => usersRef.doc(uid).get(),
        operationName: 'Get user document',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user document for uid $uid: $e');
      }
      return null;
    }
  }

  // Safe method to check if user has notification tokens
  Future<bool> userHasNotificationTokens(String uid) async {
    try {
      final userDoc = await safeGetUserDocument(uid);
      if (userDoc == null || !userDoc.exists) {
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) {
        return false;
      }

      bool hasNotifToken =
          userData.containsKey('notifToken') &&
          userData['notifToken'] is String &&
          (userData['notifToken'] as String).isNotEmpty;

      bool hasFcmTokens =
          userData.containsKey('fcmTokens') &&
          userData['fcmTokens'] is List &&
          (userData['fcmTokens'] as List).isNotEmpty;

      return hasNotifToken && hasFcmTokens;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking notification tokens for uid $uid: $e');
      }
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // User related functions
  // -------------------------------------------------------------------------
  Future<void> createOrUpdateUserProfile({required UserModel user}) async {
    if (user.id == null) {
      throw Exception("User id cannot be null");
    }

    try {
      await usersRef.doc(user.id).set(user.toJson(), SetOptions(merge: true));
      print('User profile created/updated successfully for uid: ${user.id}');
    } catch (e) {
      print('Error creating/updating user profile: $e');
      throw e;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await usersRef.doc(uid).update(data);
      print('User profile updated successfully for uid: $uid');
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  Future<UserModel> updateUser({required UserModel user}) async {
    if (user.id == null) {
      throw Exception("User id cannot be null");
    }

    try {
      // Add an updated timestamp
      final updatedData = {
        ...user.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
        'dateUpdated': FieldValue.serverTimestamp(),
      };

      await usersRef.doc(user.id).set(updatedData, SetOptions(merge: true));

      // Fetch the latest user data after update
      final updatedUserDoc = await usersRef.doc(user.id).get();
      return UserModel.fromJson(updatedUserDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  Future<UserModel> updateUserFields({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Add an updated timestamp
      final updatedData = {
        ...data,
        'dateUpdated': FieldValue.serverTimestamp(),
      };

      await usersRef.doc(uid).update(updatedData);

      // Fetch the latest user data after update
      final updatedUserDoc = await usersRef.doc(uid).get();
      return UserModel.fromJson(updatedUserDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error updating user fields: $e');
      throw e;
    }
  }

  Future<String> getUserAvatarURL({required String uid}) async {
    try {
      final userDoc = await usersRef.doc(uid).get();

      if (!userDoc.exists) {
        print('User not found for uid: $uid');
        return ''; // Return empty string if user doesn't exist
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final avatarURL = userData['avatarURL'] as String?;

      return avatarURL ?? ''; // Return empty string if avatarURL is null
    } catch (e) {
      print('Error fetching user avatar URL for uid $uid: $e');
      return ''; // Return empty string on error
    }
  }

  Future<String> getUserPhoneNumber({required String uid}) async {
    try {
      final userDoc = await usersRef.doc(uid).get();

      if (!userDoc.exists) {
        print('User not found for uid: $uid');
        return ''; // Return empty string if user doesn't exist
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final phoneNumber = userData['phoneNumber'] as String?;

      return phoneNumber ?? ''; // Return empty string if phoneNumber is null
    } catch (e) {
      print('Error fetching user phone number for uid $uid: $e');
      return ''; // Return empty string on error
    }
  }

  // =========================================================================
  // USER VERIFICATION METHODS
  // Methods for managing user face verification and biometric data
  // =========================================================================

  /// Create or update user verification record with face embeddings
  // Future<void> createUserVerification({
  //   required UserVerificationModel verification,
  // }) async {
  //   try {
  //     // Generate document ID if not provided
  //     String docId = verification.id ?? userVerificationRef.doc().id;

  //     // Create verification with updated ID and timestamps
  //     final updatedVerification = verification.copyWith(
  //       id: docId,
  //       dateAdded: DateTime.now(),
  //       dateUpdated: DateTime.now(),
  //       isProduction: isProduction,
  //     );

  //     await retryFirestoreOperation(
  //       () => userVerificationRef
  //           .doc(docId)
  //           .set(updatedVerification.toJson(), SetOptions(merge: true)),
  //       operationName: 'Create user verification',
  //     );

  //     print(
  //       'User verification created successfully for uid: ${verification.uid}',
  //     );
  //   } catch (e) {
  //     print('Error creating user verification: $e');
  //     rethrow;
  //   }
  // }

  // /// Get user verification by user ID
  // Future<UserVerificationModel?> getUserVerification({
  //   required String uid,
  // }) async {
  //   try {
  //     final snapshot = await retryFirestoreOperation(
  //       () => userVerificationRef
  //           .where('uid', isEqualTo: uid)
  //           .where('isProduction', isEqualTo: isProduction)
  //           .where('isActive', isEqualTo: true)
  //           .orderBy('dateAdded', descending: true)
  //           .limit(1)
  //           .get(),
  //       operationName: 'Get user verification',
  //     );

  //     if (snapshot.docs.isEmpty) {
  //       return null;
  //     }

  //     return UserVerificationModel.fromJson(snapshot.docs.first.data());
  //   } catch (e) {
  //     print('Error getting user verification for uid $uid: $e');
  //     return null;
  //   }
  // }

  /// Update verification status
  Future<void> updateVerificationStatus({
    required String verificationId,
    required String status,
    DateTime? expiryDate,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'verificationStatus': status,
        'dateUpdated': FieldValue.serverTimestamp(),
      };

      if (expiryDate != null) {
        updateData['expiryDate'] = Timestamp.fromDate(expiryDate);
      }

      if (metadata != null) {
        updateData['metadata'] = metadata;
      }

      await retryFirestoreOperation(
        () => userVerificationRef.doc(verificationId).update(updateData),
        operationName: 'Update verification status',
      );

      print('Verification status updated successfully for ID: $verificationId');
    } catch (e) {
      print('Error updating verification status: $e');
      rethrow;
    }
  }

  /// Find potential face matches using embeddings similarity
  /// Returns list of users with similarity scores above threshold
  // Future<List<Map<String, dynamic>>> findFaceMatches({
  //   required List<double> queryEmbeddings,
  //   double similarityThreshold = 0.7,
  //   int limit = 10,
  // }) async {
  //   try {
  //     // Get all verified users for comparison
  //     final snapshot = await retryFirestoreOperation(
  //       () => userVerificationRef
  //           .where('verificationStatus', isEqualTo: 'verified')
  //           .where('isProduction', isEqualTo: isProduction)
  //           .where('isActive', isEqualTo: true)
  //           .get(),
  //       operationName: 'Find face matches',
  //     );

  //     List<Map<String, dynamic>> matches = [];

  //     for (var doc in snapshot.docs) {
  //       try {
  //         final verification = UserVerificationModel.fromJson(doc.data());
  //         double similarity = _calculateCosineSimilarity(
  //           queryEmbeddings,
  //           verification.faceEmbeddings,
  //         );

  //         if (similarity >= similarityThreshold) {
  //           matches.add({
  //             'verification': verification,
  //             'similarity': similarity,
  //             'distance': 1.0 - similarity,
  //           });
  //         }
  //       } catch (e) {
  //         print('Error processing verification document ${doc.id}: $e');
  //         continue;
  //       }
  //     }

  //     // Sort by similarity (highest first) and limit results
  //     matches.sort(
  //       (a, b) =>
  //           (b['similarity'] as double).compareTo(a['similarity'] as double),
  //     );
  //     return matches.take(limit).toList();
  //   } catch (e) {
  //     print('Error finding face matches: $e');
  //     return [];
  //   }
  // }

  // /// Verify a user's face against their stored verification
  // Future<Map<String, dynamic>> verifyUserFace({
  //   required String uid,
  //   required List<double> queryEmbeddings,
  //   double verificationThreshold = 0.8,
  // }) async {
  //   try {
  //     final verification = await getUserVerification(uid: uid);

  //     if (verification == null) {
  //       return {
  //         'success': false,
  //         'message': 'No verification record found for user',
  //         'similarity': 0.0,
  //       };
  //     }

  //     if (!verification.isValid) {
  //       return {
  //         'success': false,
  //         'message': 'User verification is not valid or has expired',
  //         'similarity': 0.0,
  //       };
  //     }

  //     double similarity = _calculateCosineSimilarity(
  //       queryEmbeddings,
  //       verification.faceEmbeddings,
  //     );

  //     bool isMatch = similarity >= verificationThreshold;

  //     return {
  //       'success': isMatch,
  //       'message': isMatch
  //           ? 'Face verification successful'
  //           : 'Face does not match stored verification',
  //       'similarity': similarity,
  //       'distance': 1.0 - similarity,
  //       'verification': verification,
  //     };
  //   } catch (e) {
  //     print('Error verifying user face: $e');
  //     return {
  //       'success': false,
  //       'message': 'Error during face verification: $e',
  //       'similarity': 0.0,
  //     };
  //   }
  // }

  // /// Get all verification records (admin function)
  // Future<List<UserVerificationModel>> getAllVerifications({
  //   String? status,
  //   int? limit,
  // }) async {
  //   try {
  //     Query query = userVerificationRef
  //         .where('isProduction', isEqualTo: isProduction)
  //         .orderBy('dateAdded', descending: true);

  //     if (status != null) {
  //       query = query.where('verificationStatus', isEqualTo: status);
  //     }

  //     if (limit != null) {
  //       query = query.limit(limit);
  //     }

  //     final snapshot = await retryFirestoreOperation(
  //       () => query.get(),
  //       operationName: 'Get all verifications',
  //     );

  //     return snapshot.docs
  //         .map(
  //           (doc) => UserVerificationModel.fromJson(
  //             doc.data() as Map<String, dynamic>,
  //           ),
  //         )
  //         .toList();
  //   } catch (e) {
  //     print('Error getting all verifications: $e');
  //     return [];
  //   }
  // }

  /// Delete user verification record
  Future<void> deleteUserVerification({required String verificationId}) async {
    try {
      await retryFirestoreOperation(
        () => userVerificationRef.doc(verificationId).delete(),
        operationName: 'Delete user verification',
      );

      print('User verification deleted successfully: $verificationId');
    } catch (e) {
      print('Error deleting user verification: $e');
      rethrow;
    }
  }

  /// Deactivate user verification (soft delete)
  Future<void> deactivateUserVerification({
    required String verificationId,
  }) async {
    try {
      await retryFirestoreOperation(
        () => userVerificationRef.doc(verificationId).update({
          'isActive': false,
          'dateUpdated': FieldValue.serverTimestamp(),
        }),
        operationName: 'Deactivate user verification',
      );

      print('User verification deactivated successfully: $verificationId');
    } catch (e) {
      print('Error deactivating user verification: $e');
      rethrow;
    }
  }

  /// Calculate cosine similarity between two embedding vectors
  double _calculateCosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw Exception(
        'Embedding dimensions do not match: ${a.length} vs ${b.length}',
      );
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  /// Get verification statistics (admin function)
  // Future<Map<String, dynamic>> getVerificationStats() async {
  //   try {
  //     final snapshot = await retryFirestoreOperation(
  //       () => userVerificationRef
  //           .where('isProduction', isEqualTo: isProduction)
  //           .get(),
  //       operationName: 'Get verification stats',
  //     );

  //     Map<String, int> statusCounts = {};
  //     int totalActive = 0;
  //     int totalExpired = 0;

  //     for (var doc in snapshot.docs) {
  //       try {
  //         final verification = UserVerificationModel.fromJson(doc.data());

  //         // Count by status
  //         statusCounts[verification.verificationStatus] =
  //             (statusCounts[verification.verificationStatus] ?? 0) + 1;

  //         // Count active vs inactive
  //         if (verification.isActive) totalActive++;

  //         // Count expired
  //         if (verification.isExpired) totalExpired++;
  //       } catch (e) {
  //         print('Error processing verification stats for doc ${doc.id}: $e');
  //         continue;
  //       }
  //     }

  //     return {
  //       'totalVerifications': snapshot.docs.length,
  //       'statusCounts': statusCounts,
  //       'totalActive': totalActive,
  //       'totalExpired': totalExpired,
  //       'lastUpdated': DateTime.now(),
  //     };
  //   } catch (e) {
  //     print('Error getting verification stats: $e');
  //     return {
  //       'totalVerifications': 0,
  //       'statusCounts': <String, int>{},
  //       'totalActive': 0,
  //       'totalExpired': 0,
  //       'lastUpdated': DateTime.now(),
  //     };
  //   }
  // }

}
