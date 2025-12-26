import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kiliride/controllers/notification_handler.dart';
import 'package:kiliride/services/notification.service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/controllers/notification_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/services/notification.service.dart';
import 'package:flutter/foundation.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:package_info_plus/package_info_plus.dart';


class DbService {
  final appDataRef = FirebaseFirestore.instance.collection('appData');
  final usersRef = FirebaseFirestore.instance.collection('users');
  final subscriptionsRef = FirebaseFirestore.instance.collection(
    'subscriptions',
  );
  final notificationsRef = FirebaseFirestore.instance.collection(
    'notifications',
  );
  final packagesRef = FirebaseFirestore.instance.collection('packages');
  final chatsRefs = FirebaseFirestore.instance.collection('chats');
  final membersRef = FirebaseFirestore.instance.collection('members');
  final messagesRef = FirebaseFirestore.instance.collection('messages');
  final contributionCategoriesRef = FirebaseFirestore.instance.collection(
    'contributionCategories',
  );
  final branchesRef = FirebaseFirestore.instance.collection('branches');
  final contributionsRef = FirebaseFirestore.instance.collection(
    'contributions',
  );
  final pollsRef = FirebaseFirestore.instance.collection('polls');
  final pollVotesRef = FirebaseFirestore.instance.collection('pollVotes');
  final contributionPaymentsRef = FirebaseFirestore.instance.collection(
    'contributionPayments',
  );
  final loansRef = FirebaseFirestore.instance.collection('loans');
  final reactionsRef = FirebaseFirestore.instance.collection('reactions');
  final communitySettingsRef = FirebaseFirestore.instance.collection(
    'communitySettings',
  );
  final loanRequestRef = FirebaseFirestore.instance.collection('loanRequest');
  final communityFinanceRef = FirebaseFirestore.instance.collection(
    'communityFinance',
  );
  final loanRepaymentRef = FirebaseFirestore.instance.collection(
    'loanRepayment',
  );
  final loanScheduleRef = FirebaseFirestore.instance.collection('loanSchedule');
  final contributionExpenseRef = FirebaseFirestore.instance.collection(
    'contributionExpense',
  );
  final communityPrivilegesRef = FirebaseFirestore.instance.collection(
    'privileges',
  );
  final communityRolesRef = FirebaseFirestore.instance.collection(
    'communityRoles',
  );
  final communityLinksRef = FirebaseFirestore.instance.collection(
    'communityLinks',
  );
  final communityFinesRef = FirebaseFirestore.instance.collection(
    'communityFines',
  );
  final memberFinesRef = FirebaseFirestore.instance.collection('memberFines');
  final loanPaymentRef = FirebaseFirestore.instance.collection('loanPayments');
  final eventRef = FirebaseFirestore.instance.collection('events');
  final eventTicketRef = FirebaseFirestore.instance.collection('eventTickets');
  final ticketSalesRef = FirebaseFirestore.instance.collection('ticketSales');
  final logsRef = FirebaseFirestore.instance.collection('logs');
  final wishlistRef = FirebaseFirestore.instance.collection('wishlist');
  final WriteBatch batch = FirebaseFirestore.instance.batch();
  Dio dio = Dio();
  final storage = FlutterSecureStorage();

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
            e.toString().contains('resource-exhausted');

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

  // get totals id
  String getTotalId({
    required String businessId,
    required String workerId,
    required DateTime date,
    required String name,
  }) {
    final value =
        "${Funcs.getDateId(date: date)}-${name.toLowerCase()}-$businessId-$workerId";
    return value;
  }

  List<String> generateSearchKeys({required List<String> list}) {
    final result = <String>[];

    for (final item in list) {
      final lowercaseItem = item.toLowerCase();
      for (var i = 1; i <= lowercaseItem.length; i++) {
        result.add(lowercaseItem.substring(0, i));
      }
    }

    return result;
  }

  List<String> generateSearchTerms({required List<String> terms}) {
    final result = <String>[];

    for (final item in terms) {
      final lowercaseItem = item.toLowerCase();
      for (var i = 1; i <= lowercaseItem.length; i++) {
        result.add(lowercaseItem.substring(0, i));
      }
    }

    return result;
  }

  List<String> _generateSubstrings(String text) {
    final List<String> substrings = [];
    for (int i = 1; i <= text.length; i++) {
      substrings.add(text.substring(0, i));
    }
    return substrings;
  }

  // user doc
  Future<void> updateUserDoc({
    required String uid,
    required String authType,
    required String? avatarURL,
    required String? birthDate,
    required String? email,
    required String? fullName,
    required String? gender,
    required bool? isProduction,
    required bool? isVerified,
    required DateTime? lastSeen,
    required String? notifToken,
    required String? phoneNumber,
    required String role,
    required String status,
    required String deviceUniqueId,
    DateTime? dateAdded,
    DateTime? dateUpdated,
    bool isDeleted = false,
    bool isOnline = true,
  }) async {
    final userDocRef = usersRef.doc(uid);

    // Prepare search terms
    List<String> terms = [];
    if (fullName != null) terms.add(fullName);
    if (phoneNumber != null) terms.add(phoneNumber);
    if (email != null) terms.add(email);
    if (role != null) terms.add(role);

    final searchTerms = generateSearchTerms(terms: terms);

    if (dateAdded == null || dateUpdated == null) {
      final userDoc = await userDocRef.get();
      final userData = userDoc.data();
      dateAdded ??= userData?['dateAdded'] is Timestamp
          ? (userData?['dateAdded'] as Timestamp).toDate()
          : userData?['dateAdded'];
      dateUpdated ??= userData?['dateUpdated'] is Timestamp
          ? (userData?['dateUpdated'] as Timestamp).toDate()
          : userData?['dateUpdated'];
    }
    // Update the document, checking if the device ID is already in the list
    await userDocRef.set(
      {
        'notifToken': notifToken,
        'authType': authType,
        'avatarURL': avatarURL,
        'birthDate': birthDate,
        'email': email,
        'fullName': fullName,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'role': role,
        'isVerified': isVerified,
        'isProduction': isProduction,
        'uid': uid,
        'status': status,
        'searchTerms': searchTerms,
        'isDeleted': isDeleted,
        'isOnline': isOnline,
        'lastSeen': lastSeen,
        'dateAdded': dateAdded,
        'dateUpdated': dateUpdated,
        // Use arrayUnion to add deviceUniqueId if not already in the array
        'userDevices': FieldValue.arrayUnion([deviceUniqueId]),
      },
      SetOptions(merge: true),
    ); // Use merge to prevent overwriting the whole document
  }

  // update subscription doc
  Future<void> updateSubscription({
    required String uid,
    required String workerId,
    required String packageId,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
    required String status,
    bool isDeleted = false,
    bool isDeletable = false,
    bool isOnline = true,
  }) async {
    final subDocRef = subscriptionsRef.doc(uid);

    List<String> terms = [];
    terms.add(type);

    terms.add(status);

    final searchTerms = generateSearchTerms(terms: terms);

    await subDocRef
        .set({
          'workerId': workerId,
          'packageId': packageId,
          'type': type,
          'startDate': startDate,
          'endDate': endDate,
          'amount': amount,
          'status': status,
          'searchTerms': searchTerms,
          'isDeleted': isDeleted,
          'isDeletable': isDeletable,
          'isOnline': isOnline,
          'dateAdded': FieldValue.serverTimestamp(),
          'dateUpdated': FieldValue.serverTimestamp(),
        })
        .whenComplete(() {
          if (kDebugMode) {
            print('Subscription doc updated');
          }
        });
  }

  // business doc
  Future<void> updateChatDoc({
    required String id,
    required String? uid,
    String? receiverId,
    required String? name,
    String? businessId,
    required String? logoURL,
    required String? category,
    required String? type,
    required String? chatType,
    required String? description,
    required String? location,
    required String status,
    required String initiator,
    required bool hasGroupOptions,
    required bool isBroadcast,
    String? communitySettingsId,
    String? communityFinanceId,
    String? communityBranch,
    List<dynamic>? branches,
    bool? hasFine,
    bool? hasInterest,
    bool? hasLoan,
    bool? hasBranches,
    bool? hasMonthlyFee,
    Map<String, dynamic>? roles,
    bool? hasJoiningFee,
    double? fineAmount,
    double? monthlyFeeAmount,
    double? availableLoanAmount,
    double? interestRate,
    double? joiningFeeAmount,
    int? finePeriod,
    String? fineTimeFrame,
    bool isDeleted = false,
    bool isDeletable = true,
    required DateTime dateAdded,
    required DateTime dateUpdated,
  }) async {
    final chatRef = chatsRefs.doc(id);
    // get user doc
    final userDoc = await usersRef.doc(uid).get();
    final receiverDoc = await usersRef.doc(receiverId).get();

    List<String> terms = [];
    if (name != null) terms.add(name);
    if (category != null) terms.add(category);
    if (type != null) terms.add(type);
    if (chatType != null) terms.add(chatType);
    if (description != null) terms.add(description);
    if (location != null) terms.add(location);
    if (userDoc['fullName'] != null) terms.add(userDoc['fullName']);
    if (receiverId != null) terms.add(receiverDoc['fullName']);
    terms.add(status);

    final searchTerms = generateSearchTerms(terms: terms);

    await chatRef
        .set({
          'id': id,
          'uid': uid,
          'name': name,
          'logoURL': logoURL,
          'category': category,
          'type': type,
          'chatType': chatType,
          'description': description,
          'businessId': businessId,
          'hasGroupOptions': hasGroupOptions,
          'isBroadcast': isBroadcast,
          'members': 0,
          'balance': 0,
          'location': location,
          'lastMessageId': null,
          'seenUserIds': [],
          'status': status,
          'initiator': initiator,
          'searchTerms': searchTerms,
          'isDeleted': isDeleted,
          'isDeletable': isDeletable,
          'dateAdded': dateAdded,
          'dateUpdated': dateUpdated,
        })
        .whenComplete(() async {
          // get user doc
          final userDoc = await usersRef.doc(uid).get();
          final receiverDoc = await usersRef.doc(receiverId).get();

          // we update Community participant doc
          if (receiverId == null) {
            await DbService().updateMemberDoc(
              chatSearchTerms: name,
              uid: uid!,
              chatId: id,
              communityBranch: communityBranch,
              role: "Admin",
              fullName: userDoc['fullName'],
              phoneNumber: userDoc['phoneNumber'],
              chatType: "Community",
              creditBalance: 0,
              totalMessages: 0,
              status: "Active",
              participantPhoneNumber: userDoc['phoneNumber'],
              participantName: userDoc['fullName'],
            );

            await DbService().updateCommunitySettings(
              id: communitySettingsId!, //Change the ID
              uid: uid,
              chatId: id,
              branches: branches,
              hasBranches: hasBranches,
              hasFine: hasFine,
              hasLoan: hasLoan,
              hasInterest: hasInterest,
              hasMonthlyFee: hasMonthlyFee,
              roles: roles,
              hasJoiningFee: hasJoiningFee,
              communityFinanceId: communityFinanceId,
              dateAdded: dateAdded,
              dateUpdated: dateUpdated,
              availableLoanAmount: availableLoanAmount,
              fineAmount: fineAmount,
              interestRate: interestRate,
              joiningFeeAmount: joiningFeeAmount,
              fineTimeFrame: fineTimeFrame,
              finePeriod: finePeriod,
              monthlyFeeAmount: monthlyFeeAmount,
            );

            if (kDebugMode) {
              print('chat doc updated');
            }
          } else {
            // we update Individual participant doc
            await DbService().updateMemberDoc(
              chatSearchTerms: name,
              uid: uid!,
              chatId: id,
              communityBranch: communityBranch,
              role: "Admin",
              fullName: userDoc['fullName'],
              phoneNumber: userDoc['phoneNumber'],
              chatType: "Individual",
              creditBalance: 0,
              totalMessages: 0,
              status: "Active",
              participantPhoneNumber: receiverDoc['phoneNumber'],
              participantName: receiverDoc['fullName'],
            );

            // we update participant doc
            await DbService().updateMemberDoc(
              chatSearchTerms: name,
              uid: receiverId,
              chatId: id,
              communityBranch: communityBranch,
              role: "Member",
              fullName: receiverDoc['fullName'],
              phoneNumber: receiverDoc['phoneNumber'],
              chatType: "Individual",
              creditBalance: 0,
              totalMessages: 0,
              status: "Active",
              participantPhoneNumber: userDoc['phoneNumber'],
              participantName: userDoc['fullName'],
            );

            if (kDebugMode) {
              print('chat doc updated');
            }
          }
        });
  }

  // delete community
  Future<void> deleteCommunityDoc({required String businessId}) async {
    // update isDeleted to true
    final communityDocRef = chatsRefs.doc(businessId);

    await communityDocRef
        .update({'isDeleted': true, 'dateUpdated': DateTime.now()})
        .whenComplete(() {
          if (kDebugMode) {
            print('chat doc deleted');
          }
        });
  }

  Future<void> removeUserFromGroup({required String memberId}) async {
    // Reference to the specific member document in the group
    DocumentReference memberDocRef = membersRef.doc(memberId);

    // Update the document instead of deleting
    await memberDocRef
        .update({
          'isDeleted': true, // Mark the member as deleted
          // Update the timestamp of this action
        })
        .whenComplete(() {
          if (kDebugMode) {
            print('Member marked as deleted in group');
          }
        })
        .catchError((error) {
          if (kDebugMode) {
            print('Failed to mark member as deleted: $error');
          }
        });

    final memberDocData = await memberDocRef.get();

    final communityDocRef = chatsRefs.doc(memberDocData["chatId"]);

    final communityData = await communityDocRef.get();

    await communityDocRef
        .update({'members': communityData["members"] - 1})
        .whenComplete(() {
          if (kDebugMode) {
            print('chat doc deleted');
          }
        });
  }

  Future<void> updateBalance({
    required String chatId,
    required double balance,
  }) async {
    final communityDocRef = chatsRefs.doc(chatId);
    await communityDocRef
        .update({'balance': balance, 'dateUpdated': DateTime.now()})
        .whenComplete(() {
          if (kDebugMode) {
            print('chat doc Updated');
          }
        });
  }

  // Total contribution amount across all contributions
  Stream<double> streamTotalContributedAmount(String chatId) {
    return contributionsRef
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .asyncMap((contributionSnapshot) async {
          double totalAmount = 0.0;

          // Iterate over each contribution document
          for (var contributionDoc in contributionSnapshot.docs) {
            String contributionId = contributionDoc
                .id; // Assuming the document ID is the contributionId

            // Fetch payments for this particular contributionId
            var paymentSnapshot = await DbService().contributionPaymentsRef
                .where('contributionId', isEqualTo: contributionId)
                .get();

            // Sum the amounts from all payment documents for this contribution
            double contributionTotal = paymentSnapshot.docs.fold(0.0, (
              sum,
              doc,
            ) {
              return sum + (doc.data()['amount'] as num).toDouble();
            });

            // Accumulate to the overall total
            totalAmount += contributionTotal;
          }

          return totalAmount;
        });
  }

  // Total contributed amount to specific contribution
  Stream<double> streamSpecificTotalContributedAmount({
    required String contributionId,
  }) {
    return contributionPaymentsRef
        .where('contributionId', isEqualTo: contributionId)
        .snapshots()
        .asyncMap((contributionPaymentSnapshot) async {
          double contributionPaymentTotal = contributionPaymentSnapshot.docs
              .fold(0.0, (sum, doc) {
                return sum + (doc.data()['amount'] as num).toDouble();
              });
          return contributionPaymentTotal;
        });
  }

  // Total chat balance across all contributions in a community
  Stream<double> streamTotalChatBalance(String chatId) {
    return contributionsRef
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .asyncMap((chatSnapshot) async {
          var chatDoc = await chatsRefs.doc(chatId).get();
          var chatData = chatDoc.data() as Map<String, dynamic>;
          return double.parse(chatData['balance'].toString());
        });
  }

  // Total contribution balnce to specific contribution
  Stream<double> streamSpecificContributionTotalBalance({
    required String contributionId,
  }) {
    return contributionsRef
        .where('id', isEqualTo: contributionId)
        .snapshots()
        .asyncMap((contributionPaymentSnapshot) async {
          var contributionDoc = await contributionsRef
              .doc(contributionId)
              .get();
          var contributionData = contributionDoc.data();
          print(contributionData?['balance'].runtimeType);
          // double contributionTotalBalance =
          //     contributionPaymentSnapshot.docs.fold(0.0, (sum, doc) {
          //   return sum + (doc.data()['balance'] as num).toDouble();
          // });
          // return contributionTotalBalance + contributionData?['balance'];
          return double.parse(contributionData!['balance'].toString());
          ;
        });
  }

  // Total contribution amount to specific contribution
  Stream<double> streamApprovedTotalLoanRequests({
    required String contributionId,
    required String chatId,
  }) {
    return loanRequestRef
        .where('chatId', isEqualTo: chatId)
        .where('contributionId', isEqualTo: contributionId)
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .asyncMap((loanRequestsSnapshot) async {
          double approvedLoanRequestsTotal = loanRequestsSnapshot.docs.fold(
            0.0,
            (sum, doc) {
              return sum + (doc.data()['loanAmount'] as num).toDouble();
            },
          );
          return approvedLoanRequestsTotal;
        });
  }

  // Total contribution amount across all contributions
  Stream<double> streamCommunityTotalLoans(String chatId) {
    return loanRequestRef
        .where('chatId', isEqualTo: chatId)
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .asyncMap((loanRequestSnapshot) async {
          double totalAmount = 0.0;

          double approvedLoanRequestsTotal = loanRequestSnapshot.docs.fold(
            0.0,
            (sum, doc) {
              return sum + (doc['loanAmount'] as num).toDouble();
            },
          );

          return approvedLoanRequestsTotal;
        });
  }

  // Total contribution amount to specific contribution
  Stream<double> streamSpecificContributionExpenseBalance({
    required String contributionId,
  }) {
    return contributionExpenseRef
        .where('contributionId', isEqualTo: contributionId)
        .snapshots()
        .asyncMap((contributionExpenseSnapshot) async {
          double contributionExpenseTotal = contributionExpenseSnapshot.docs
              .fold(0.0, (sum, doc) {
                return sum + (doc.data()['amount'] as num).toDouble();
              });
          return contributionExpenseTotal;
        });
  }

  // Total contribution amount across all contributions
  Stream<double> streamCommunityTotalExpenses(String chatId) {
    return contributionsRef
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .asyncMap((contributionSnapshot) async {
          double totalAmount = 0.0;

          // Iterate over each contribution document
          for (var contributionDoc in contributionSnapshot.docs) {
            String contributionId = contributionDoc
                .id; // Assuming the document ID is the contributionId

            QuerySnapshot contributionExpensesSnapshot = await DbService()
                .contributionExpenseRef
                .where('chatId', isEqualTo: chatId)
                .where('contributionId', isEqualTo: contributionId)
                .get();

            double contributionExpensesTotal = contributionExpensesSnapshot.docs
                .fold(0.0, (sum, doc) {
                  return sum + (doc['amount'] as num).toDouble();
                });

            totalAmount += contributionExpensesTotal;
          }
          return totalAmount;
        });
  }

  // Total contribution amount to specific contribution
  Stream<double> streamContributionReturnedLoans({
    required String contributionId,
    required String chatId,
  }) {
    return loanRequestRef
        .where('chatId', isEqualTo: chatId)
        .where('contributionId', isEqualTo: contributionId)
        .where('isPaid', isEqualTo: true)
        .snapshots()
        .asyncMap((loanRequestsSnapshot) async {
          double approvedLoanRequestsTotal = loanRequestsSnapshot.docs.fold(
            0.0,
            (sum, doc) {
              return sum + (doc.data()['loanAmount'] as num).toDouble();
            },
          );
          return approvedLoanRequestsTotal;
        });
  }

  // Total contribution amount across all contributions
  Stream<double> streamCommunityTotalReturns(String chatId) {
    return loanPaymentRef
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .asyncMap((loanPaymentSnapshot) async {
          double totalAmount = 0.0;

          double loanPaymentsTotal = loanPaymentSnapshot.docs.fold(0.0, (
            sum,
            doc,
          ) {
            return sum + (doc['amountPaid'] as num).toDouble();
          });
          return loanPaymentsTotal;
        });
  }

  Future<void> updateContributionBalance({
    required double amount,
    required String chatId,
    required String contributionId,
    required double balance, // This balance should already be updated balance
  }) async {
    final contributionDocRef = contributionsRef.doc(contributionId);
    final chatDocRef = await chatsRefs.doc(chatId).get();
    var chatData = chatDocRef.data() as Map<String, dynamic>;

    await contributionDocRef
        .update({'balance': balance, 'dateUpdated': DateTime.now()})
        .whenComplete(() {
          chatDocRef.reference.update({
            'balance': chatData['balance'] + amount,
            'dateUpdated': DateTime.now(),
          });
        });
  }

  Future<void> updateMemberDoc({
    required String uid,
    required String chatId,
    required String? communityBranch,
    required String? role,
    required String? fullName,
    required String? phoneNumber,
    required String? chatType,
    required double? creditBalance,
    required int? totalMessages,
    String? chatSearchTerms,
    // required double? creditBalance,
    required String status,
    bool isDeleted = false,
    String? participantPhoneNumber,
    String? participantName,
  }) async {
    var userSnapshot = await usersRef.doc(uid).get();
    var userData = userSnapshot.data() as Map<String, dynamic>;
    final memberDocRef = membersRef.doc(Funcs.generateUUID());
    List<String> chatIdKeywords = [];
    List<String> terms = [];
    if (role != null) terms.add(role);
    if (fullName != null) terms.add(fullName);
    if (phoneNumber != null) terms.add(phoneNumber);
    if (chatType != null) terms.add(chatType);
    if (participantName != null) terms.add(participantName);
    if (chatSearchTerms != null) terms.add(chatSearchTerms);
    terms.add(status);
    if (participantPhoneNumber != null) {
      chatIdKeywords.add(participantPhoneNumber);
      chatIdKeywords.add(phoneNumber!);
    }
    final searchTerms = generateSearchTerms(terms: terms);

    await memberDocRef
        .set({
          'uid': uid,
          'chatId': chatId,
          'chatIdKeywords': chatIdKeywords,
          'role': role,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'avatarURL': userData['avatarURL'],
          'chatType': chatType,
          'totalMessages': totalMessages,
          'creditBalance': creditBalance,
          'branchId': null,
          'communityBranch': communityBranch,
          'isLeader': false,
          'leaderRole': null,
          'hasPaidJoiningFee': false,
          'lastMessageId': 'defaultId',
          'lastMessageData': {},
          'unreadMessages': 0,
          'status': status,
          'searchTerms': searchTerms,
          'isDeleted': isDeleted,
          'dateAdded': DateTime.now(),
          'dateUpdated': DateTime.now(),
        })
        .whenComplete(() async {
          // update members count on chat
          var chatDoc = await chatsRefs.doc(chatId).get();
          var chatData = chatDoc.data() as Map<String, dynamic>;
          var searchTerms = chatData['searchTerms'];
          var fullNameTerms = generateSearchTerms(terms: [fullName!]);
          searchTerms.addAll(fullNameTerms);
          chatsRefs.doc(chatId).update({
            'members': FieldValue.increment(1),
            'searchTerms': searchTerms,
          });
          if (kDebugMode) {
            print('Participant doc updated');
          }
        });
  }

  // delete member
  Future<void> deleteMemberDoc({
    required String uid,
    required String chatId,
  }) async {
    // // update isDeleted to true
    final memberDocRef = membersRef.doc(uid);

    await memberDocRef
        .update({'isDeleted': true, 'dateUpdated': DateTime.now()})
        .whenComplete(() {
          if (kDebugMode) {
            print('Participant doc deleted');
          }
        });
  }

  Future<void> updateMessageDoc({
    bool? isNewContribution,
    String? messageId,
    required String uid,
    required String chatId,
    required String senderId,
    required String senderName,
    required String? avatarURL,
    required dynamic message,
    String? replyId,
    required String type,
    required Map<String, dynamic>? attachments,
    required String? branchName,
    required DateTime dateAdded,
    required String status,
    bool isDeleted = false,
    String? chatType,
    String? memberDocId,
  }) async {
    String id = "";

    if (messageId != null) {
      id = messageId;
    } else {
      id = Funcs.generateUUID();
    }

    final messageDocRef = messagesRef.doc(id);
    List<String> terms = [];

    if (type == 'Poll') {
      var pollQuestion = message['pollQuestion'];
      terms.add(pollQuestion);
    } else if (type == 'Contribution') {
      var contributionTitle = message['contributionData']['title'];
      terms.add(contributionTitle);
    } else {
      terms.add(message);
    }

    terms.add(senderName);
    terms.add(status);

    final searchTerms = generateSearchTerms(terms: terms);
    final List<Map> reactions = [
      {'reaction': 'like', 'count': 0},
      {'reaction': 'love', 'count': 0},
      {'reaction': 'haha', 'count': 0},
      {'reaction': 'wow', 'count': 0},
      {'reaction': 'sad', 'count': 0},
      {'reaction': 'angry', 'count': 0},
    ];

    Map<String, dynamic> updatedAttachments = attachments ?? {};

    // Check if attachments exist and upload to Firebase Storage if necessary
    if (attachments != null && attachments['type'] == null) {
      if (attachments['fileType'] == 'Images') {
        updatedAttachments =
            await Funcs.uploadImageAttachmentsToFirebaseStorage(
              attachments: attachments,
              chatId: chatId,
            );
      } else {
        updatedAttachments = await Funcs.uploadAttachmentToFirebaseStorage(
          attachments: attachments,
          chatId: chatId,
        );
      }
    }

    await messageDocRef
        .set({
          'id': id,
          'uid': uid,
          'chatId': chatId,
          'branchName': branchName,
          'senderId': senderId,
          'senderName': senderName,
          'avatarURL': avatarURL,
          'message': message,
          'attachments':
              updatedAttachments, // Use updated attachments with download URL
          'reactions': reactions,
          'replyId': replyId,
          'type': type,
          'status': status,
          'searchTerms': searchTerms,
          'isNewContribution': isNewContribution,
          'isDeleted': isDeleted,
          'dateAdded': dateAdded,
          'dateUpdated': dateAdded,
        })
        .whenComplete(() async {
          if (type != "Announcement") {
            // Update chat's last message id
            await chatsRefs.doc(chatId).update({
              'lastMessageData': {
                'messageId': messageDocRef.id,
                'text': message,
                'senderId': senderId,
                'senderName': senderName,
                'status': status,
                'type': type,
                'delivered': false,
                'dateAdded': DateTime.now(),
              },
              'dateUpdated': DateTime.now(),
            });

            // Update unread messages count for members

            if (chatType == "Community") {
              var members = await DbService().membersRef
                  .where('chatId', isEqualTo: chatId)
                  .get();

              for (var member in members.docs) {
                if (member['uid'] != uid) {
                  var memberSnapshot = await membersRef
                      .where('uid', isEqualTo: member['uid'])
                      .where('chatId', isEqualTo: chatId)
                      .get();

                  await memberSnapshot.docs.first.reference.update({
                    'unreadMessages': member['unreadMessages'] + 1,
                  });
                }
              }
            } else {
              var memberRef = membersRef.doc(memberDocId!);
              var memberSnapshot = await memberRef.get();
              var memberData = memberSnapshot.data() as Map;

              await memberRef.update({
                'unreadMessages': memberData['unreadMessages'] + 1,
              });
            }
          }

          if (kDebugMode) {
            print('message doc updated');
          }
        });
  }


  // delete chat
  Future<void> deleteChatDoc({required String chatId}) async {
    // update isDeleted to true
    final chatDocRef = chatsRefs.doc(chatId);

    await chatDocRef.update({'isDeleted': true, 'dateUpdated': DateTime.now()});
  }

  // update branch
  Future<void> updateBranchDoc({
    required String id,
    required String uid,
    required String chatId,
    required String name,
    required String? description,
    required DateTime dateAdded,
    required String status,
    bool isDeleted = false,
  }) async {
    final branchDocRef = branchesRef.doc(id);

    List<String> terms = [];

    terms.add(name);
    terms.add(description!);
    terms.add(status);

    final searchTerms = generateSearchTerms(terms: terms);

    await branchDocRef
        .set({
          'uid': uid,
          'chatId': chatId,
          'name': name,
          'description': description,
          'status': status,
          'searchTerms': searchTerms,
          'isDeleted': isDeleted,
          'dateAdded': dateAdded,
          'dateUpdated': dateAdded,
        })
        .whenComplete(() {
          if (kDebugMode) {
            print('branch doc updated');
          }
        });
  }

  // update branch
  Future<void> updateContriCatDoc({
    required String id,
    required String uid,
    required String chatId,
    required String name,
    required String? description,
    required DateTime dateAdded,
    required String status,
    bool isDeleted = false,
  }) async {
    final contributionCategoryDocRef = contributionCategoriesRef.doc(id);

    List<String> terms = [];

    terms.add(name);
    terms.add(description!);
    terms.add(status);

    final searchTerms = generateSearchTerms(terms: terms);

    await contributionCategoryDocRef
        .set({
          'uid': uid,
          'chatId': chatId,
          'name': name,
          'description': description,
          'status': status,
          'searchTerms': searchTerms,
          'isDeleted': isDeleted,
          'dateAdded': dateAdded,
          'dateUpdated': dateAdded,
        })
        .whenComplete(() {
          if (kDebugMode) {
            print('branch doc updated');
          }
        });
  }

  // update contribution
  Future<void> updateContribution({
    required String id,
    required String uid,
    required String chatId,
    required String? branchId,
    required String? categoryId,
    required String? message,
    required String? title,
    required double? amount,
    required String? branchName,
    required bool hasFine,
    required DateTime dateAdded,
    required String status,
    bool? isCreating,
    bool isDeleted = false,
  }) async {
    final contributionDocRef = contributionsRef.doc(id);

    List<String> terms = [];

    terms.add(message!);
    terms.add(status);

    final searchTerms = generateSearchTerms(terms: terms);

    if (isCreating != null) {
      await contributionDocRef
          .set({
            'id': id,
            'uid': uid,
            'chatId': chatId,
            'branchId': branchId,
            'branchName': branchName,
            'title': title,
            'categoryId': categoryId,
            'message': message,
            'balance': 0,
            'amount': amount,
            'status': status,
            'hasFine': hasFine,
            'searchTerms': searchTerms,
            'isDeleted': isDeleted,
            'dateAdded': dateAdded,
            'dateUpdated': dateAdded,
          })
          .whenComplete(() {
            if (kDebugMode) {
              print('branch doc updated');
            }
          });
    } else {
      await contributionDocRef
          .set({
            'id': id,
            'uid': uid,
            'chatId': chatId,
            'branchId': branchId,
            'title': title,
            'categoryId': categoryId,
            'message': message,
            'amount': amount,
            'status': status,
            'searchTerms': searchTerms,
            'isDeleted': isDeleted,
            'dateAdded': dateAdded,
            'dateUpdated': dateAdded,
          })
          .whenComplete(() {
            if (kDebugMode) {
              print('branch doc updated');
            }
          });
    }
  }

  // update contribution
  Future<void> updatePoll({
    required String id,
    required String uid,
    required String chatId,
    required String? branchId,
    required String message,
    required List options,
    required DateTime dateAdded,
    required String status,
    bool isDeleted = false,
  }) async {
    final pollDocRef = pollsRef.doc(id);

    List<String> terms = [];

    terms.add(message!);
    terms.add(status);

    final searchTerms = generateSearchTerms(terms: terms);

    await pollDocRef.set({
      'uid': uid,
      'chatId': chatId,
      'branchId': branchId,
      'message': message,
      'options': options,
      'status': status,
      'searchTerms': searchTerms,
      'isDeleted': isDeleted,
      'dateAdded': dateAdded,
      'dateUpdated': dateAdded,
    });
  }

  // update contribution
  Future<void> updatePollVote({
    required String id,
    required String pollId,
    required String uid,
    required Map option,
    required List pollOptions,
    required DateTime dateAdded,
  }) async {
    final pollVoteDocRef = pollVotesRef.doc(id);

    await pollVoteDocRef
        .set({
          'pollId': pollId,
          'uid': uid,
          'option': option['option'],
          'dateAdded': dateAdded,
          'dateUpdated': dateAdded,
        })
        .whenComplete(() async {
          // update poll option votes and option for a specific option map in the list of options
          final optionIndex = pollOptions.indexWhere(
            (element) => element['option'] == option['option'],
          );
          final optionData = pollOptions[optionIndex];
          final optionVotes = optionData['votes'];
          pollOptions[optionIndex]['votes'] = optionVotes + 1;
          await DbService().pollsRef.doc(pollId).update({
            'options': pollOptions,
          });
          if (kDebugMode) {
            print('poll vote doc updated');
          }
        });
  }

  String createUserVoteId({required String uid, required String messageId}) {
    return "$uid-$messageId";
  }

  // update contribution
  Future<void> updateContributionPayment({
    required String id,
    required String chatId,
    required String contributionId,
    required String uid,
    required double amount,
    required bool isConfirmed,
    required DateTime dateAdded,
  }) async {
    // final contributionDocRef = await contributionsRef.doc(contributionId).get();
    // var contributionsData = contributionDocRef.data() as Map<String, dynamic>;
    // var contributionBalance = contributionsData['balance'];

    // contributionDocRef.reference.update({
    //   'balance': contributionBalance + amount,
    // }).whenComplete(() {
    //   Funcs.showSnackBar(context: CustomNotificationHandler.navigatorKey.currentContext!,
    //       message: "Contribution has been paid", isSuccess: true);
    // });

    final contributionPaymentDocRef = contributionPaymentsRef.doc(id);

    await contributionPaymentDocRef
        .set({
          'id': id,
          'chatId': chatId,
          'contributionId': contributionId,
          'uid': uid,
          'isConfirmed': isConfirmed,
          'amount': amount,
          'dateAdded': dateAdded,
          'dateUpdated': dateAdded,
        })
        .whenComplete(() async {
          if (kDebugMode) {
            print('Contribution doc updated');
          }
        });
  }

  // update contribution
  Future<void> updateReaction({
    required String messageId,
    required String uid,
    required String reaction,
    required DateTime dateAdded,
  }) async {
    final reactionDocRef = reactionsRef.doc(Funcs.generateUUID());

    // first check if reaction exists by using uid and messageId it it exist we will update instead
    final reactionDoc = await reactionsRef
        .where('uid', isEqualTo: uid)
        .where('messageId', isEqualTo: messageId)
        .get();
    final reactionDocExist = reactionDoc.docs.isNotEmpty;

    if (!reactionDocExist) {
      await reactionDocRef
          .set({
            'uid': uid,
            'messageId': messageId,
            'reaction': reaction,
            'dateAdded': dateAdded,
            'dateUpdated': dateAdded,
          })
          .whenComplete(() async {
            // update message on reactions field
            final messageDocRef = messagesRef.doc(messageId);
            final messageDoc = await messageDocRef.get();
            final reactions = messageDoc['reactions'];
            final reactionIndex = reactions.indexWhere(
              (element) => element['reaction'] == reaction,
            );
            final reactionData = reactions[reactionIndex];
            final reactionCount = reactionData['count'];
            reactions[reactionIndex]['count'] = reactionCount + 1;
            await messageDocRef.update({'reactions': reactions});

            if (kDebugMode) {
              print('reaction doc updated');
            }
          });
    } else {
      // update reaction
      final reactionId = reactionDoc.docs.first.id;
      final reactionDocRef = reactionsRef.doc(reactionId);
      await reactionDocRef
          .update({'reaction': reaction, 'dateUpdated': dateAdded})
          .whenComplete(() async {
            // update message on reactions field if reaction is different change if it is the same do nothing
            final messageDocRef = messagesRef.doc(messageId);
            final messageDoc = await messageDocRef.get();
            final reactions = messageDoc['reactions'];
            final reactionIndex = reactions.indexWhere(
              (element) => element['reaction'] == reaction,
            );
            final reactionData = reactions[reactionIndex];
            final reactionCount = reactionData['count'];

            if (reactionData['reaction'] != reaction) {
              // update reaction count
              reactions[reactionIndex]['count'] = reactionCount + 1;
              // update reaction
              reactions[reactionIndex]['reaction'] = reaction;
            } else {}

            if (kDebugMode) {
              print('reaction doc updated');
            }
          });
    }
  }

  Stream<String> getUserNameByPhoneNumber(String phoneNumber) {
    return usersRef
        .where('phoneNumber', isEqualTo: phoneNumber)
        .where('status', isEqualTo: 'Active')
        .limit(1)
        .snapshots()
        .map((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            var userData = querySnapshot.docs.first.data();
            return userData['fullName'] as String? ?? "Unknown";
          } else {
            return "Unknown";
          }
        })
        .handleError((error) {
          if (kDebugMode) {
            print(error.toString());
          }
          return "Unknown"; // Return "Unknown" in case of any error
        });
  }


  void sendNotification({
    required String title,
    required String body,
    required String token,
    required String senderId,
    required String receiverId,
    required String chatType,
    required String phoneNumber,
    required String chatId,
    required String actionType,
    required dynamic data,
  }) async {
    //Data format for sending notification
    // data = {
    //   "action_type": actionType,
    //   "senderId": senderId,
    //   "chatType": chatType,
    //   "phoneNumber": phoneNumber,
    /// Add other data fields as needed
    // };

    var projectId = 'thinking-digit-368121';
    var notificationUrl2 =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    var notificationAccessToken = await NotificationService.getAccessToken();

    var notification = {
      "message": {
        "token": token,
        "notification": {"body": body, "title": title},
        "android": {
          "notification": {"sound": "default"},
        },
        "apns": {
          "payload": {
            "aps": {"sound": "default"},
          },
        },
        "data": data,
      },
    };

    try {
      Response response = await dio.post(
        notificationUrl2,
        data: notification,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $notificationAccessToken',
          },
          followRedirects: false,
          maxRedirects: 5,
          validateStatus: (status) {
            return status != null && status < 500; // Handle responses < 500
          },
        ),
      );

      // ACTION TYPES
      //1. ride_request
      //2. loan_request (Done)
      //3. loan_approved (Done)
      //4. loan_denied (Done)
      //5. loan_payment
      //6. loan_finished (Done)
      //7. loan_payment_confirmed (Done)
      //8. contribution_made (Done)
      //9. contribution_confirmed (Done)
      //10. ownership_change (Done)
      //11. member_fined (Done)
      //12. fine_payment_confirmed (Done)
      //13. expense_made(Done)
      //14. event_created (Done)
      //15. ticket_payment (Done)
      //16. ticket_confirmed (Done)
      //17. message_received (Done)

      // print("NOTIFICATION SENT");
      if (actionType == 'loan_request' ||
          actionType == 'loan_approved' ||
          actionType == 'loan_denied' ||
          actionType == 'loan_payment' ||
          actionType == 'loan_finished' ||
          actionType == 'loan_payment_confirmed' ||
          actionType == 'contribution_made' ||
          actionType == 'contribution_confirmed' ||
          actionType == 'member_fined' ||
          actionType == 'expense_made' ||
          actionType == 'event_created' ||
          actionType == 'ticket_payment' ||
          actionType == 'ticket_confirmed' ||
          actionType == 'ownership_change' ||
          actionType == 'fine_payment_confirmed') {
        await updateNotification(
          title: title,
          body: body,
          actionType: actionType,
          chatId: chatId,
          receiverId: receiverId,
          chatType: chatType,
        );
      }

      if (response.statusCode == 200) {
        print('Notification sent successfully!');
      } else if (response.statusCode == 401) {
        // If token expired, refresh token and retry
        print('Access token expired, refreshing token...');
        notificationAccessToken = await NotificationService.refreshToken();

        // Retry the request with the new token
        Response retryResponse = await dio.post(
          notificationUrl2,
          data: notification,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $notificationAccessToken',
            },
            followRedirects: false,
            maxRedirects: 5,
            validateStatus: (status) {
              return status != null && status < 500;
            },
          ),
        );

        if (retryResponse.statusCode == 200) {
          print('Notification sent successfully on retry!');
        } else {
          print('Failed to send notification on retry: ${retryResponse.data}');
        }
      } else {
        print('Failed to send notification: ${response.data}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Sends notifications to all FCM tokens associated with a user
  void sendNotificationToAllDevices({
    required String title,
    required String body,
    required List<String> tokens,
    required String senderId,
    required String receiverId,
    required String chatType,
    required String phoneNumber,
    required String chatId,
    required String actionType,
    required dynamic data,
  }) async {
    if (tokens.isEmpty) {
      print('No FCM tokens found for user $receiverId');
      return;
    }

    var projectId = 'thinking-digit-368121';
    var notificationUrl2 =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    var notificationAccessToken = await NotificationService.getAccessToken();

    // Send notification to each token
    for (String token in tokens) {
      var notification = {
        "message": {
          "token": token,
          "notification": {"body": body, "title": title},
          "android": {
            "notification": {"sound": "default"},
          },
          "apns": {
            "payload": {
              "aps": {"sound": "default"},
            },
          },
          "data": data,
        },
      };

      try {
        Response response = await dio.post(
          notificationUrl2,
          data: notification,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $notificationAccessToken',
            },
            followRedirects: false,
            maxRedirects: 5,
            validateStatus: (status) {
              return status != null && status < 500;
            },
          ),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully to token: $token');
        } else if (response.statusCode == 401) {
          // If token expired, refresh token and retry
          print('Access token expired, refreshing token...');
          notificationAccessToken = await NotificationService.refreshToken();

          // Retry the request with the new token
          Response retryResponse = await dio.post(
            notificationUrl2,
            data: notification,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $notificationAccessToken',
              },
              followRedirects: false,
              maxRedirects: 5,
              validateStatus: (status) {
                return status != null && status < 500;
              },
            ),
          );

          if (retryResponse.statusCode == 200) {
            print('Notification sent successfully on retry to token: $token');
          } else {
            print(
              'Failed to send notification on retry to token $token: ${retryResponse.data}',
            );
          }
        } else {
          print(
            'Failed to send notification to token $token: ${response.data}',
          );
          // If this is an invalid token error, we might want to remove it from the user's tokens
          if (response.statusCode == 400 &&
              response.data.toString().contains('INVALID_ARGUMENT')) {
            print('Invalid token detected: $token. Consider removing it.');
            // Optionally remove invalid token here
          }
        }
      } catch (e) {
        print('Error sending notification to token $token: $e');
      }
    }

    // Only save to notifications collection once (not for each token)
    if (actionType == 'loan_request' ||
        actionType == 'loan_approved' ||
        actionType == 'loan_denied' ||
        actionType == 'loan_payment' ||
        actionType == 'loan_finished' ||
        actionType == 'loan_payment_confirmed' ||
        actionType == 'contribution_made' ||
        actionType == 'contribution_confirmed' ||
        actionType == 'member_fined' ||
        actionType == 'expense_made' ||
        actionType == 'event_created' ||
        actionType == 'ticket_payment' ||
        actionType == 'ticket_confirmed' ||
        actionType == 'ownership_change' ||
        actionType == 'fine_payment_confirmed') {
      await updateNotification(
        title: title,
        body: body,
        actionType: actionType,
        chatId: chatId,
        receiverId: receiverId,
        chatType: chatType,
      );
    }
  }

  //clear chat
  Future<void> clearChat({required String chatId}) async {
    // update isDeleted to true
    final chatDocRef = chatsRefs.doc(chatId);

    await chatDocRef.update({'lastMessageId': null}).whenComplete(() {
      if (kDebugMode) {
        print('Chat has been cleared');
      }
    });

    //delete all member docs where chatId is equal to chatId
    final membersDoc = await membersRef
        .where('chatId', isEqualTo: chatId)
        .get();

    for (final member in membersDoc.docs) {
      await member.reference.update({
        'isDeleted': true,
        'dateUpdated': DateTime.now(),
      });
    }

    //delete all messages docs where chatId is equal to chatId
    final messagesDoc = await messagesRef
        .where('chatId', isEqualTo: chatId)
        .get();

    for (final message in messagesDoc.docs) {
      await message.reference.update({
        'isDeleted': true,
        'dateUpdated': DateTime.now(),
      });
    }

    //delete chat doc
    await chatDocRef.update({'isDeleted': true, 'dateUpdated': DateTime.now()});
  }

  // updating community settings
  Future<void> updateCommunitySettings({
    required String id,
    required String uid,
    required String chatId,
    required List<dynamic>? branches,
    required bool? hasBranches,
    required bool? hasFine,
    required bool? hasInterest,
    required bool? hasLoan,
    required Map<String, dynamic>? roles,
    required bool? hasJoiningFee,
    required bool? hasMonthlyFee,
    required String? communityFinanceId,
    required double? availableLoanAmount,
    required double? fineAmount,
    required double? interestRate,
    required double? joiningFeeAmount,
    required double? monthlyFeeAmount,
    required String? fineTimeFrame,
    required int? finePeriod,
    required DateTime dateAdded,
    required DateTime dateUpdated,
  }) async {
    final communitySettingsDocRef = communitySettingsRef.doc(id);

    await communitySettingsDocRef
        .set({
          'id': id,
          'uid': uid,
          'chatId': chatId,
          'roles': roles,
          'branches': branches,
          'hasBranches': hasBranches,
          'hasFine': hasFine,
          'hasLoan': hasLoan,
          'hasInterest': hasInterest,
          'hasJoiningFee': hasJoiningFee,
          'hasMonthlyFee': hasMonthlyFee,
          'dateAdded': dateAdded,
          'dateUpdated': dateUpdated,
        })
        .whenComplete(() async {
          await updateCommunityFinance(
            id: communityFinanceId!,
            chatId: chatId,
            uid: uid,
            availableLoanAmount: hasLoan! ? availableLoanAmount! : null,
            fineAmount: hasFine! ? fineAmount : null,
            interestRate: hasInterest! ? interestRate : null,
            joiningFeeAmount: hasJoiningFee! ? joiningFeeAmount : null,
            finePeriod: hasFine ? finePeriod : null,
            fineTimeFrame: hasFine ? fineTimeFrame : null,
            monthlyFeeAmount: hasMonthlyFee! ? monthlyFeeAmount : null,
            dateAdded: dateAdded,
            dateUpdated: dateUpdated,
          );
          print("UPDATED COMMUNITY SETTINGS");
        });
  }

  //update loan request
  Future<void> updateLoanRequest({
    required String id,
    required String uid,
    required String chatId,
    required String? contributionId,
    required int period,
    required String timeFrame,
    required double loanAmount,
    required bool approved,
    required String status,
    required DateTime dateAdded,
    required DateTime dateUpdated,
    String? approverId,
    DateTime? dateApproved,
    DateTime? fineDueDate,
  }) async {
    List<String> terms = [];
    terms.add(loanAmount.toString());

    final searchTerms = generateSearchTerms(terms: terms);

    final loanRequestDocRef = loanRequestRef.doc(id);
    double? interestRate;

    QuerySnapshot financeSnapshot = await DbService().communityFinanceRef
        .where('chatId', isEqualTo: chatId)
        .get();

    if (financeSnapshot.docs.isEmpty) {
      throw Exception("Finance document not found");
    }

    var financeDoc = financeSnapshot.docs.first;

    if (financeSnapshot.docs.isNotEmpty) {
      interestRate = financeDoc['interestRate'];
    } else {
      interestRate = null;
    }

    DocumentReference financeDocRef = DbService().communityFinanceRef.doc(
      financeDoc.id,
    );

    double financeDocAvailableLoanAmount = financeDoc['availableLoanAmount'];

    /* Count down for returning the first payment of
      the loan should start after the loan has been approved (When dateApproved != null).
      Loan schedule table should also be created when loan is approved
    */

    if (financeDocAvailableLoanAmount >= loanAmount) {
      //New amount available for loan
      var availableLoanAmount = financeDocAvailableLoanAmount - loanAmount;

      //Update amount available for loan in a community
      await financeDocRef.update({
        'availableLoanAmount': availableLoanAmount,
        'dateUpdated': DateTime.now(),
      });

      await loanRequestDocRef
          .set({
            'id': id,
            'uid': uid,
            'contributionId': null,
            'searchTerms': searchTerms,
            'approverId': approverId,
            'chatId': chatId,
            'timeFrame': timeFrame, // It is either(monthly, years)
            'period': period, // Period in numbers
            'loanAmount': loanAmount,
            'interestRate': interestRate,
            'isApproved': approved,
            'status': status, //(approved, denied, pending)
            'dateApproved': dateApproved,
            'reason': null,
            'finishedPayment': false,
            'isPaid': false,
            'paidAmount': 0,
            'loanCreditBalance': 0,
            'remainingAmount': 0,
            'dueDate': null,
            'dateAdded': dateAdded,
            'dateUpdated': dateUpdated,
            'fineDueDate': fineDueDate,
          })
          .whenComplete(() {
            Funcs.showSnackBar(
              context: CustomNotificationHandler.navigatorKey.currentContext!,
              isSuccess: true,
              message: "Loan request was sent successfully",
            );
          });
    } else {
      Funcs.showSnackBar(
        context: CustomNotificationHandler.navigatorKey.currentContext!,
        message: "Available amount for loan is not sufficient",
        isSuccess: false,
      );
    }
  }

  //update community finance (This goes during group creation and other places)
  Future<void> updateCommunityFinance({
    required String id,
    required String chatId,
    required String uid,
    required double? availableLoanAmount,
    required double? fineAmount,
    required double? interestRate,
    required double? joiningFeeAmount,
    required double? monthlyFeeAmount,
    required String? fineTimeFrame,
    required int? finePeriod,
    required DateTime dateAdded,
    required DateTime dateUpdated,
  }) async {
    final communityFinanceDocRef = communityFinanceRef.doc(id);
    await communityFinanceDocRef
        .set({
          'id': id,
          'uid': uid,
          'chatId': chatId,
          'availableLoanAmount': availableLoanAmount,
          'fineAmount': fineAmount,
          'finePeriod': finePeriod,
          'joiningFeeAmount': joiningFeeAmount,
          'monthlyFeeAmount': monthlyFeeAmount,
          'interestRate': interestRate,
          'fineTimeFrame': fineTimeFrame,
          'dateAdded': dateAdded,
          'dateUpdated': dateUpdated,
        })
        .whenComplete(() {
          print("COMMUNITY FINANCE HAS BEEN UPDATED");
        });
  }

  //update loan repayment
  Future<void> updateLoanPayment({
    required String id,
    required String chatId,
    required String? contributionId,
    required String loanRequestId,
    required String uid,
    required double amountPaid,
    required DateTime dateAdded,
    required DateTime dateUpdated,
  }) async {
    final loanRepaymentDocRef = loanRepaymentRef.doc(id);

    /*
    When a member makes payment or when a member misses
    a monthly payment loanschedule table shoud be updated.
    The outstanding payment should be compared to the amount paid so that
    proper adjustments shuould be done at the loan schedule table
     */

    await loanRepaymentDocRef
        .set({
          'id': id,
          'uid': uid,
          'chatId': chatId,
          'contributionId': null,
          'amountPaid': amountPaid,
          'loanRequestId': loanRequestId,
          // 'joiningFeeAmount': joiningFeeAmount,
          'dateAdded': dateAdded,
          'dateUpdated': dateUpdated,
        })
        .whenComplete(() {
          print("COMMUNITY FINANCE HAS BEEN UPDATED");
        });
  }

  //update loan schedule
  Future<void> updateLoanSchedule({
    required String id,
    required String chatId,
    required String? contributionId,
    required String loanRequestId,
    required String loaneeId, // A person who received loan
    required double debtRemaining,
    required double interestDueAtTheEndOfTheYear,
    required double capitalRepaidAtTheEndOfTheYear,
    required double
    loanOutstandingAtTheEndOfTheYear, //This becomes the new debtRemainng after schedule is updated
    required bool
    paid, //Status for checking if the payment has been covered fot that specific month
    required DateTime dateAdded,
    required DateTime dateUpdated,
    String? loanPaymentId,
  }) async {
    final loanScheduleDocRef = loanScheduleRef.doc(id);

    await loanScheduleDocRef.set({
      'id': id,
      'chatId': chatId,
      'contributionId': null,
      'loanRequestId': loanRequestId,
      'loanPaymentId': loanPaymentId,
      'loaneeId': loaneeId,
      'debtRemaining': debtRemaining,
      'interestDueAtTheEndOfTheYear': interestDueAtTheEndOfTheYear,
      'capitalRepaidAtTheEndOfTheYear': capitalRepaidAtTheEndOfTheYear,
      'loanOutstandingAtTheEndOfTheYear': loanOutstandingAtTheEndOfTheYear,
      'paid': paid,
      'dateAdded': dateAdded,
      'dateUpdated': dateUpdated,
    });
  }

  Future<void> approveLoan({
    required String chatId,
    required String? contributionId,
    required bool approved,
    required String status,
    required String? reason,
    required String loanRequestId,
    required String approverId,
  }) async {
    DocumentReference loanRequestDocRef = DbService().loanRequestRef.doc(
      loanRequestId,
    );
    DocumentSnapshot loanDocumentSnapshot = await loanRequestDocRef.get();

    if (!loanDocumentSnapshot.exists) {
      throw Exception("Loan request not found");
    }

    Map<String, dynamic> loanRequestData =
        loanDocumentSnapshot.data() as Map<String, dynamic>;

    QuerySnapshot financeSnapshot = await DbService().communityFinanceRef
        .where('chatId', isEqualTo: chatId)
        .get();

    if (financeSnapshot.docs.isEmpty) {
      throw Exception("Finance document not found");
    }

    final financeDoc = financeSnapshot.docs.first;
    DateTime today = DateTime.now();

    //Updating fineDueDate
    var finePeriodDays = financeDoc['finePeriod'] * 30;
    DateTime fineDueDate = today.add(Duration(days: finePeriodDays));
    DateTime dateAdded = (loanRequestData['dateAdded'] as Timestamp).toDate();
    String timeframe = loanRequestData['timeFrame'];
    int period = loanRequestData['period'];

    int days;
    if (timeframe == 'Monthly') {
      days = period * 30; // Approximate month as 30 days
    } else if (timeframe == 'Yearly') {
      days = period * 365; // Approximate year as 365 days
    } else {
      throw Exception('Invalid timeframe: $timeframe');
    }

    // Calculate the due date
    DateTime dueDate = dateAdded.add(Duration(days: days));

    await loanRequestDocRef.update({
      'isApproved': approved,
      'status': status, // (approved, denied, pending)
      'fineDueDate': fineDueDate,
      'reason': reason,
      'dueDate': dueDate,
      'approverId': approverId,
      'dateApproved': DateTime.now(),
      'dateUpdated': DateTime.now(),
    });

    // After updating the loan request, handle loan schedule creation
    await _initializeLoanSchedule(
      loanRequestData: loanRequestData,
      chatId: chatId,
      contributionId: null,
      loanRequestId: loanRequestId,
      dateAdded: DateTime.now(),
      dateUpdated: DateTime.now(),
    );
  }

  //Loan schedule table
  Future<void> _initializeLoanSchedule({
    required Map<String, dynamic> loanRequestData,
    required String chatId,
    required String? contributionId,
    required String loanRequestId,
    required DateTime dateAdded,
    required DateTime dateUpdated,
  }) async {
    double loanAmount = loanRequestData['loanAmount'];
    double interestRate = loanRequestData['interestRate'] / 100;
    int period = loanRequestData['period'];

    double leverAnnualPayment =
        loanAmount / ((1 - pow(1 + interestRate, -period)) / interestRate);

    double inteRestAmount = loanAmount * interestRate;
    double actualDebtAmount = loanAmount + inteRestAmount;
    double debtRemaining = loanAmount;

    for (int n = 1; n <= period; n++) {
      double interestAmount = debtRemaining * interestRate;
      double capitalRepaid = leverAnnualPayment - interestAmount;
      double loanOutstanding = debtRemaining - capitalRepaid;

      // Update dateAdded and dateUpdated dynamically within the loop
      DateTime dateAdded = DateTime.now();
      DateTime dateUpdated = DateTime.now();

      DocumentReference scheduleDocRef = DbService().loanScheduleRef.doc();

      batch.set(scheduleDocRef, {
        'paymentId': Funcs.generateUUID(),
        'loanRequestId': loanRequestId,
        'contributionId': null,
        'actualDebtAmount': actualDebtAmount,
        'loaneeId': loanRequestData['uid'],
        'debtRemaining': debtRemaining,
        'interestDueAtTheEndOfTheYear': interestAmount,
        'capitalRepaidAtTheEndOfTheYear': capitalRepaid,
        'loanOutstandingAtTheEndOfTheYear': loanOutstanding,
        'paid': false,
        'isConfirmed': false,
        'amountPaid': 0,
        'amountExtra': 0,
        'dateAdded': dateAdded,
        'dateUpdated': dateUpdated,
      });
      double loanOutstandingInterestAmount = loanOutstanding * interestRate;
      actualDebtAmount =
          loanOutstanding +
          loanOutstandingInterestAmount; // Update for the next period
      debtRemaining = loanOutstanding;
    }

    try {
      await batch.commit().whenComplete(() async {
        // Setting Loan remaining amount
        double remainingAmount =
            Funcs().roundUpAndRemoveDecimals(leverAnnualPayment) * period;
        await loanRequestRef.doc(loanRequestId).update({
          'remainingAmount': remainingAmount,
          'dateUpdated': DateTime.now(),
        });
        Funcs.showSnackBar(
          context: CustomNotificationHandler.navigatorKey.currentContext!,
          message: "Loan has been approved".tr,
          isSuccess: true,
        );
      });
      print("Loan Schedule table has been written successfully!");
    } catch (e) {
      print("ERROR writing Loan Schedule table batch: $e");
    }
  }

  //Recalculate loan schedule table
  Future<void> recalculateLoanSchedule({
    required Map<String, dynamic> loanRequestData,
    required String chatId,
    required String? contributionId,
    required String loanRequestId,
    required double newLoanAmount,
    required DateTime dateAdded,
    required DateTime dateUpdated,
  }) async {
    double loanAmount = newLoanAmount;
    double interestRate = loanRequestData['interestRate'] / 100;
    int period = loanRequestData['period'];

    double leverAnnualPayment =
        loanAmount / ((1 - pow(1 + interestRate, -period)) / interestRate);

    double inteRestAmount = loanAmount * interestRate;
    double actualDebtAmount = loanAmount + inteRestAmount;
    double debtRemaining = loanAmount;

    for (int n = 1; n <= period; n++) {
      double interestAmount = debtRemaining * interestRate;
      double capitalRepaid = leverAnnualPayment - interestAmount;
      double loanOutstanding = debtRemaining - capitalRepaid;

      // Update dateAdded and dateUpdated dynamically within the loop
      DateTime dateAdded = DateTime.now();
      DateTime dateUpdated = DateTime.now();

      DocumentReference scheduleDocRef = DbService().loanScheduleRef.doc();

      batch.set(scheduleDocRef, {
        'paymentId': Funcs.generateUUID(),
        'loanRequestId': loanRequestId,
        'contributionId': null,
        'actualDebtAmount': actualDebtAmount,
        'loaneeId': loanRequestData['uid'],
        'debtRemaining': debtRemaining,
        'interestDueAtTheEndOfTheYear': interestAmount,
        'capitalRepaidAtTheEndOfTheYear': capitalRepaid,
        'loanOutstandingAtTheEndOfTheYear': loanOutstanding,
        'paid': false,
        'isConfirmed': false,
        'dateAdded': dateAdded,
        'dateUpdated': dateUpdated,
      });

      double loanOutstandingInterestAmount = loanOutstanding * interestRate;
      actualDebtAmount =
          loanOutstanding +
          loanOutstandingInterestAmount; // Update for the next period
      debtRemaining = loanOutstanding;
    }

    try {
      await batch.commit().whenComplete(() async {
        // Setting Loan remaining amount
        double remainingAmount =
            Funcs().roundUpAndRemoveDecimals(leverAnnualPayment) * period;
        await loanRequestRef.doc(loanRequestId).update({
          'remainingAmount': remainingAmount,
          'dateUpdated': DateTime.now(),
        });

        Funcs.showSnackBar(
          context: CustomNotificationHandler.navigatorKey.currentContext!,
          message: "Loan has been approved".tr,
          isSuccess: true,
        );
      });
      print("Loan Schedule table has been written successfully!");
    } catch (e) {
      print("ERROR writing Loan Schedule table batch: $e");
    }
  }

  //Get loan schedules for the table
  Future<List<Map<String, dynamic>>> getLoanSchedules(
    String loaneeId,
    String? contributionId,
    String loanRequestId,
  ) async {
    try {
      QuerySnapshot querySnapshot = await loanScheduleRef
          .where('loaneeId', isEqualTo: loaneeId)
          // .where('contributionId', isEqualTo: contributionId)
          .where('loanRequestId', isEqualTo: loanRequestId)
          // .orderBy('dateAdded', descending: true)
          .orderBy('loanOutstandingAtTheEndOfTheYear', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("ERROR: $e");
      return [];
    }
  }

  Future<void> deleteUnpaidLoanSchedules({
    required String userId,
    required String? contributionDocId,
    required String loanRequestId,
  }) async {
    try {
      // Fetch the documents matching the query
      QuerySnapshot loanScheduleSnapshot = await DbService().loanScheduleRef
          .where('loaneeId', isEqualTo: userId)
          // .where('contributionId', isEqualTo: contributionDocId)
          .where('loanRequestId', isEqualTo: loanRequestId)
          .where('paid', isEqualTo: false)
          .orderBy('loanOutstandingAtTheEndOfTheYear', descending: true)
          .get();

      // Iterate through the documents and delete each one
      for (QueryDocumentSnapshot doc in loanScheduleSnapshot.docs) {
        await doc.reference.delete();
      }

      print("Unpaid loan schedules successfully deleted.");
    } catch (e) {
      print("Error deleting unpaid loan schedules: $e");
    }
  }

  // Checking loan schedule payments
  Future<bool> checkAllPaymentsMade(String loanRequestId) async {
    try {
      // Reference to the loan schedule collection
      CollectionReference loanScheduleRef = DbService().loanScheduleRef;

      // Query to get all documents with the specific loanRequestId
      QuerySnapshot querySnapshot = await loanScheduleRef
          .where('loanRequestId', isEqualTo: loanRequestId)
          .get();

      // Check if all documents have been paid
      bool allPaid = querySnapshot.docs.every((doc) => doc['paid'] == true);

      return allPaid;
    } catch (e) {
      print('Error checking payment status: $e');
      return false;
    }
  }

  //update loan repayment
  Future<void> updateContributionExpense({
    required String id,
    required String chatId,
    required String contributionId,
    required String uid,
    required double amount,
    required String title,
    required String category,
    required String description,
  }) async {
    final contributionExpenseDocRef = contributionExpenseRef.doc(id);

    List<String> terms = [];
    terms.add(category);
    terms.add(description);
    terms.add(title);

    final searchTerms = generateSearchTerms(terms: terms);
    QuerySnapshot contributionQuerySnapshot = await DbService().contributionsRef
        .where('id', isEqualTo: contributionId)
        .where('chatId', isEqualTo: chatId)
        .get();

    var chatOocRef = chatsRefs.doc(chatId);
    var chatSnapshot = await chatOocRef.get();
    var chatData = chatSnapshot.data() as Map<String, dynamic>;
    Map<String, dynamic> contributionData =
        contributionQuerySnapshot.docs.first.data() as Map<String, dynamic>;

    if (contributionData['balance'] >= amount) {
      await contributionExpenseDocRef
          .set({
            'id': id,
            'uid': uid,
            'chatId': chatId,
            'contributionId': contributionId,
            'category': category,
            'title': title,
            'description': description,
            'amount': amount,
            'searchTerms': searchTerms,
            'dateAdded': DateTime.now(),
            'dateUpdated': DateTime.now(),
          })
          .whenComplete(() {
            Funcs.showSnackBar(
              context: CustomNotificationHandler.navigatorKey.currentContext!,
              message: "Expense has been added successfully".tr,
              isSuccess: true,
            );

            //Remaining balance
            double balance = contributionData['balance'] - amount;

            //Update contribution balance
            contributionQuerySnapshot.docs.first.reference.update({
              'balance': balance,
              'dateUpdated': DateTime.now(),
            });

            //Update chat balance
            chatOocRef.update({
              'balance': chatData['balance'] - amount,
              'dateUpdated': DateTime.now(),
            });
          });
    } else {
      Funcs.showSnackBar(
        context: CustomNotificationHandler.navigatorKey.currentContext!,
        message: "${contributionData['title']} has no sufficient funds".tr,
        isSuccess: false,
      );
    }
  }

  Future<void> updateMemberCreditBalance({
    required String chatId,
    required String memberId,
    required double amount,
    required String type,
  }) async {
    QuerySnapshot memberQuerySnapshot = await DbService().membersRef
        .where('chatId', isEqualTo: chatId)
        .where('uid', isEqualTo: memberId)
        .where('chatType', isEqualTo: 'Community')
        .get();

    Map<String, dynamic> memberData =
        memberQuerySnapshot.docs.first.data() as Map<String, dynamic>;

    double newMemberCreditBalance = 0;
    if (type == 'assisting' || type == 'paying') {
      newMemberCreditBalance = memberData['creditBalance'] - amount;
    } else if (type == 'adding') {
      newMemberCreditBalance = memberData['creditBalance'] + amount;
    }

    memberQuerySnapshot.docs.first.reference
        .update({
          'creditBalance': newMemberCreditBalance,
          'dateUpdated': DateTime.now(),
        })
        .whenComplete(() {
          Funcs.showSnackBar(
            context: CustomNotificationHandler.navigatorKey.currentContext!,
            message: "Credit balance has been updated successfully".tr,
            isSuccess: true,
          );
        });
  }

  Future<void> updateContributionWithCreditBalance({
    required String chatId,
    required String contributionId,
    required String memberId,
    required String type, //assisting, paying
    String? recipientId,
  }) async {
    QuerySnapshot memberQuerySnapshot = await DbService().membersRef
        .where('chatId', isEqualTo: chatId)
        .where('uid', isEqualTo: memberId)
        .where('chatType', isEqualTo: 'Community')
        .get();
    Map<String, dynamic> memberData =
        memberQuerySnapshot.docs.first.data() as Map<String, dynamic>;
    double memberCreditBalance = memberData['creditBalance'];

    QuerySnapshot contributionQuerySnapshot = await DbService().contributionsRef
        .where('id', isEqualTo: contributionId)
        .where('chatId', isEqualTo: chatId)
        .get();
    Map<String, dynamic> contributionData =
        contributionQuerySnapshot.docs.first.data() as Map<String, dynamic>;
    double contributionAmount = contributionData['amount'];

    //check if credit balance is sufficient
    if (memberCreditBalance >= contributionAmount) {
      if (type == 'assisting') {
        //Update recipient contribution
        await DbService().updateContributionPayment(
          id: Funcs.generateUUID(),
          chatId: chatId,
          contributionId: contributionId,
          uid: recipientId!,
          amount: contributionAmount,
          isConfirmed: true, //should I confirm directly?
          dateAdded: DateTime.now(),
        );

        //Update helper credit balance
        await DbService().updateMemberCreditBalance(
          chatId: chatId,
          memberId: memberId,
          amount: contributionAmount,
          type: type,
        );
      } else {
        await DbService().updateContributionPayment(
          id: Funcs.generateUUID(),
          chatId: chatId,
          contributionId: contributionId,
          uid: memberId,
          amount: contributionAmount,
          isConfirmed: true, //should I confirm directly?
          dateAdded: DateTime.now(),
        );

        //update member credit balance
        await DbService().updateMemberCreditBalance(
          chatId: chatId,
          memberId: memberId,
          amount: contributionAmount,
          type: type,
        );
      }
    } else {
      Funcs.showSnackBar(
        context: CustomNotificationHandler.navigatorKey.currentContext!,
        message: "Insufficient credit balance".tr,
        isSuccess: false,
      );
    }
  }

  Future<void> contributeForMember(
  // Assisting member contribution
  {
    required String chatId,
    required String contributionId,
    required String helperId,
    required String recipientId,
    required String uid,
  }) async {
    if (helperId == recipientId) {
      Funcs.showSnackBar(
        context: CustomNotificationHandler.navigatorKey.currentContext!,
        message: "You can't assist yourself",
        isSuccess: false,
      );
    } else {
      QuerySnapshot contributionQuerySnapshot = await DbService()
          .contributionsRef
          .where('id', isEqualTo: contributionId)
          .where('chatId', isEqualTo: chatId)
          .get();
      Map<String, dynamic> contributionData =
          contributionQuerySnapshot.docs.first.data() as Map<String, dynamic>;
      double contributionAmount = contributionData['amount'];

      QuerySnapshot helperQuerySnapshot = await DbService().membersRef
          .where('chatId', isEqualTo: chatId)
          .where('uid', isEqualTo: helperId)
          .where('chatType', isEqualTo: 'Community')
          .get();
      Map<String, dynamic> helperData =
          helperQuerySnapshot.docs.first.data() as Map<String, dynamic>;
      double helperCreditBalance = helperData['creditBalance'];
      //check if credit balance is sufficient
      if (helperCreditBalance >= contributionAmount) {
        await DbService().updateContributionWithCreditBalance(
          chatId: chatId,
          contributionId: contributionId,
          memberId: helperId,
          type: 'assisting',
          recipientId: recipientId,
        );
      } else {
        Funcs.showSnackBar(
          context: CustomNotificationHandler.navigatorKey.currentContext!,
          message: "Insufficient credit balance".tr,
          isSuccess: false,
        );
      }
    }
  }

  Future<double> getChatBalance({required String chatId}) async {
    QuerySnapshot contributionQuerySnapshot = await DbService().contributionsRef
        .where('chatId', isEqualTo: chatId)
        .get();

    double contributionBalanceTotal = contributionQuerySnapshot.docs.fold(0.0, (
      sum,
      doc,
    ) {
      final docData = doc.data() as Map<String, dynamic>;
      final balance = docData['balance'];
      if (balance != null && balance is num) {
        return sum + balance.toDouble();
      }
      return sum;
    });

    return contributionBalanceTotal;
  }

  Future<Map<String, dynamic>> getCommunityFinance({
    required String chatId,
  }) async {
    QuerySnapshot querySnapshot = await DbService().communityFinanceRef
        .where('chatId', isEqualTo: chatId)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return {};
    }
    return querySnapshot.docs.first.data() as Map<String, dynamic>;
  }


  Future<void> addLog({
    required String userId,
    required String? eventType,
    required Map<String, dynamic>? eventDetails,
    required String severity,
    required String message,
  }) async {
    // Get device info
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    late final String model;
    late final String osVersion;

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model;
      osVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.model;
      osVersion = iosInfo.systemVersion;
    } else {
      model = 'Unknown';
      osVersion = 'Unknown';
    }

    // Get app version
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    await logsRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
      'eventType': eventType,
      'eventDetails': eventDetails,
      'deviceInfo': {
        'model': model,
        'osVersion': osVersion,
        'appVersion': packageInfo.version,
      },
      'severity': severity,
      'message': message,
    });
  }

  Future<void> updateNotification({
    required String title,
    required String body,
    required String actionType,
    required String chatId,
    required String chatType,
    required String receiverId,
    Map<String, dynamic>? data,
  }) async {
    // String uid = AuthService().currentUser!.uid;
    String id = Funcs.generateUUID();

    var notificationRef = notificationsRef.doc(id);
    await notificationRef.set({
      'id': id,
      'title': title,
      'body': body,
      'actionType': actionType,
      'chatId': chatId,
      'chatType': chatType,
      'data': data,
      'uid': receiverId,
      'isUnread': true,
      'dateAdded': DateTime.now(),
      'dateUpdated': DateTime.now(),
    });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    // String uid = AuthService().currentUser!.uid;
    String uid = ''; // REPLACE WITH APPROPRIATE VALUE IF NEEDED
    var notificationRef = notificationsRef.doc(notificationId);
    await notificationRef.update({'read': true, 'dateUpdated': DateTime.now()});
  }

  //Adding field in docs only where the field doesn't exist
  Future<void> addFieldInCollection({
    required String collectionName,
    required String fieldName,
    required dynamic fieldValue,
  }) async {
    try {
      // Retrieve all documents from the collection
      var collectionSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get();

      for (var collectionDoc in collectionSnapshot.docs) {
        try {
          // Get the document data
          var docData = collectionDoc.data() as Map<String, dynamic>;

          // Check if the field already exists
          if (!docData.containsKey(fieldName)) {
            // If the field doesn't exist, update the document by adding the new field
            await FirebaseFirestore.instance
                .collection(collectionName)
                .doc(collectionDoc.id)
                .set(
                  {fieldName: fieldValue},
                  SetOptions(merge: true),
                ); // Use merge to only add the new field
          }
        } catch (e) {
          // Catch and log any errors that occur during individual document update
          print('Failed to update document ${collectionDoc.id}: $e');
        }
      }
    } catch (e) {
      // Catch and log any errors that occur during the collection retrieval
      print('Failed to retrieve collection: $e');
    }
  }

  //Adding field in map in docs and updating value for current key
  Future<void> addFieldInMapInCollection({
    required String collectionName,
    required String
    mapFieldName, // The top-level map field name (e.g., lastMessageData)
    required String
    mapKeyName, // The key in the map where you want to add/modify the field (e.g., dateAdded)
    required dynamic
    mapFieldValue, // The value you want to set for the key in the map
  }) async {
    try {
      // Retrieve all documents from the collection
      var collectionSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get();

      for (var collectionDoc in collectionSnapshot.docs) {
        try {
          // Check if the top-level map field exists
          var docData = collectionDoc.data() as Map<String, dynamic>;
          if (docData.containsKey(mapFieldName)) {
            var fieldMap = docData[mapFieldName];

            // Ensure that the top-level field is indeed a map
            if (fieldMap is Map<String, dynamic>) {
              // Update the specific key within the map using nested fields update
              await FirebaseFirestore.instance
                  .collection(collectionName)
                  .doc(collectionDoc.id)
                  .update({'$mapFieldName.$mapKeyName': mapFieldValue});
            }
          } else {
            // If the map doesn't exist, create a new one with the specified key and value
            await FirebaseFirestore.instance
                .collection(collectionName)
                .doc(collectionDoc.id)
                .set(
                  {
                    mapFieldName: {mapKeyName: mapFieldValue},
                  },
                  SetOptions(merge: true),
                ); // Merge to ensure only the field gets added
          }
        } catch (e) {
          // Catch and log any errors that occur during individual document update
          print('Failed to update document ${collectionDoc.id}: $e');
        }
      }
    } catch (e) {
      // Catch and log any errors that occur during the collection retrieval
      print('Failed to retrieve collection: $e');
    }
  }

  //Update field in all docs
  Future<void> updateFieldInAllDocuments({
    required String collectionName,
    required String fieldName,
    required dynamic newValue,
  }) async {
    try {
      // Retrieve all documents from the collection
      var collectionSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get();

      // Iterate over each document in the collection
      for (var collectionDoc in collectionSnapshot.docs) {
        try {
          // Update the field in the current document
          await FirebaseFirestore.instance
              .collection(collectionName)
              .doc(collectionDoc.id)
              .update({fieldName: newValue});

          print(
            'Field "$fieldName" updated in document "${collectionDoc.id}".',
          );
        } catch (e) {
          print('Failed to update document ${collectionDoc.id}: $e');
        }
      }
    } catch (e) {
      print('Failed to retrieve collection: $e');
    }
  }

  //Update field by using conditions
  Future<void> updateFieldByReplacementInAllDocuments({
    required String collectionName,
    required String fieldName,
    required dynamic conditionedValue,
    required String conditionedField,
    required dynamic oldValue,
    required dynamic newValue,
  }) async {
    //Conditioned field and Conditioned value are used for filtering the document to only where you want to update the field

    try {
      // Retrieve all documents from the collection
      var collectionSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get();

      // Iterate over each document in the collection
      for (var collectionDoc in collectionSnapshot.docs) {
        try {
          // Update the field in the current document
          if (collectionDoc.data()[conditionedField] == conditionedValue &&
              collectionDoc.data()[fieldName] == oldValue) {
            await FirebaseFirestore.instance
                .collection(collectionName)
                .doc(collectionDoc.id)
                .update({fieldName: newValue});
            print(
              'Field "$fieldName" updated in document "${collectionDoc.id}".',
            );
          }
        } catch (e) {
          print('Failed to update document ${collectionDoc.id}: $e');
        }
      }
    } catch (e) {
      print('Failed to retrieve collection: $e');
    }
  }

}
