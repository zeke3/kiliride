import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiliride/controllers/notification_handler.dart';
import 'package:dio/dio.dart';
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:kiliride/components/event_card.dart';
import 'package:kiliride/firebase_options.dart';
import 'package:kiliride/main.dart';
// import 'package:kiliride/screens/chat/chat.scrn.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/services/db.service.dart';
import 'package:kiliride/shared/device_identifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kiliride/shared/styles.shared.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class Funcs {
  static final Map<String, String> _cache = {};
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static formatDateRange({DateTime? startDate, DateTime? endDate}) {
    String formatYear(int year) => year.toString().substring(2);

    if (startDate == null && endDate == null) {
      return 'Select Date Range';
    } else if (startDate != null && endDate == null) {
      return '${startDate.day} ${getMonth(startDate.month)} - ${getMonth(endDate!.month)} ${endDate.day}, ${formatYear(endDate.year)}';
    } else if (startDate == null && endDate != null) {
      return '${startDate!.day} ${getMonth(startDate.month)}, ${formatYear(startDate.year)} - ${getMonth(endDate.month)} ${endDate.day}, ${formatYear(endDate.year)}';
    } else {
      return '${startDate!.day} ${getMonth(startDate.month)}, ${formatYear(startDate.year)} - ${getMonth(endDate!.month)} ${endDate.day}, ${formatYear(endDate.year)}';
    }
  }

  String getSubstringAfterFirstComma(String text) {
    // Check if the string contains a comma, and then split it
    if (text.contains(',')) {
      List<String> parts = text.split(',');
      // Remove the first part and trim to clean up any leading/trailing whitespace
      return parts.sublist(1).join(',').trim();
    } else {
      // Return the original text if there's no comma
      return text;
    }
  }

  /// Formats a time string from "HH:mm" to the desired format.
  ///
  /// [time] is the input time string, e.g., "20:00".
  /// [format] specifies the desired output format:
  ///   - "HH:mm"
  ///   - "HH:mm:ss"
  ///   - "HH:mm:ss.uuuuuu"
  ///
  /// Returns the formatted time string.
  ///
  /// Throws a [FormatException] if the input time is invalid.

  String formatTime({required String time, String desiredFormat = 'HH:mm'}) {
    // Define supported output formats
    const List<String> supportedFormats = [
      'HH:mm',
      'HH:mm:ss',
      'HH:mm:ss.uuuuuu',
    ];

    if (!supportedFormats.contains(desiredFormat)) {
      throw ArgumentError(
        'Unsupported format. Choose from: ${supportedFormats.join(', ')}',
      );
    }

    DateTime dateTime;

    // Attempt to parse as 24-hour format
    final RegExp twentyFourHourRegExp = RegExp(r'^(\d{2}):(\d{2})$');
    final RegExp twelveHourRegExp = RegExp(
      r'^(\d{1,2}):(\d{2})\s?(AM|PM)$',
      caseSensitive: false,
    );

    if (twentyFourHourRegExp.hasMatch(time)) {
      final match = twentyFourHourRegExp.firstMatch(time)!;
      final int hour = int.parse(match.group(1)!);
      final int minute = int.parse(match.group(2)!);

      // Validate hour and minute
      if (hour < 0 || hour > 23) {
        throw FormatException('Hour must be between 00 and 23.');
      }
      if (minute < 0 || minute > 59) {
        throw FormatException('Minute must be between 00 and 59.');
      }

      dateTime = DateTime(2000, 1, 1, hour, minute);
    } else if (twelveHourRegExp.hasMatch(time)) {
      final match = twelveHourRegExp.firstMatch(time)!;
      int hour = int.parse(match.group(1)!);
      final int minute = int.parse(match.group(2)!);
      final String period = match.group(3)!.toUpperCase();

      if (hour < 1 || hour > 12) {
        throw FormatException(
          'Hour must be between 01 and 12 for 12-hour format.',
        );
      }
      if (minute < 0 || minute > 59) {
        throw FormatException('Minute must be between 00 and 59.');
      }

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      dateTime = DateTime(2000, 1, 1, hour, minute);
    } else {
      throw FormatException(
        'Invalid time format. Expected "HH:mm" or "hh:mm AM/PM", got "$time".',
      );
    }

    // Format according to desired format
    String formattedTime;
    switch (desiredFormat) {
      case 'HH:mm':
        formattedTime = DateFormat('HH:mm').format(dateTime);
        break;
      case 'HH:mm:ss':
        formattedTime = DateFormat('HH:mm:ss').format(dateTime);
        break;
      case 'HH:mm:ss.uuuuuu':
        formattedTime =
            '${DateFormat('HH:mm:ss').format(dateTime)}.${dateTime.microsecond.toString().padLeft(6, '0')}';
        break;
      default:
        // This case should never be reached due to the earlier check
        throw ArgumentError('Unsupported format.');
    }

    return formattedTime;
  }

  /// Converts a time string from 24-hour format ("HH:mm:ss") to 12-hour format with AM/PM ("hh:mm a").
  ///
  /// Example:
  /// ```dart
  /// String time24 = "20:00:00";
  /// String time12 = convert24To12(time24); // "08:00 PM"
  /// ```
  static String convert24To12(String time24) {
    try {
      // Parse the input time string to a DateTime object
      final DateTime dateTime = DateFormat("HH:mm:ss").parseStrict(time24);

      // Format the DateTime object to the desired 12-hour format with AM/PM
      final String time12 = DateFormat("hh:mm a").format(dateTime);

      return time12;
    } on FormatException {
      throw FormatException(
        'Invalid time format. Expected "HH:mm:ss", got "$time24".',
      );
    }
  }

  String convertTo24Hour(String timeString) {
    try {
      // Check if the input is already in 24-hour format with or without seconds
      if (RegExp(r'^\d{2}:\d{2}(:\d{2})?$').hasMatch(timeString)) {
        // If the time contains seconds, format it to HH:mm
        final dateTime = DateFormat("HH:mm:ss").parse(timeString, true);
        return DateFormat("HH:mm").format(dateTime);
      }

      // Parse and convert from 12-hour format with AM/PM
      final dateTime = DateFormat("h:mm a").parse(timeString);
      return DateFormat("HH:mm").format(dateTime);
    } catch (e) {
      print("Error parsing time: $e");
      return "Invalid time";
    }
  }

  String formatPositionToJson(
    Position position, {
    String? startingName,
    String? endingName,
  }) {
    Map<String, String> positionMap = {
      'latitude': "${position.latitude}",
      'longitude': "${position.longitude}",
      'geocode': "${position.heading}",
      'latitudeDelta': "${position.altitude}",
      'longitudeDelta': "${position.altitude}",
      'senderLocation': "${startingName}",
      'receiverLocation': "${endingName}",
    };

    return jsonEncode(positionMap);
  }

  static getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      default:
        return 'Dec';
    }
  }

  static String formatDate({
    required DateTime date,
    required String formatType,
  }) {
    if (formatType == 'long') {
      return DateFormat('MMM dd yyyy').format(date);
    } else if (formatType == 'short') {
      return DateFormat('MMM d, yy').format(date);
    } else {
      throw ArgumentError(
        'Invalid formatType. Allowed values are "long" and "short"',
      );
    }
  }

String formatNumber(num number) {
    if (number >= 1000000000) {
      // Billions
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      // Millions
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      // Thousands
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      // Less than 1000
      return number.toString();
    }
  }

  String formatNumberWithSuffix({required num number}) {
    if (number >= 1000000000000) {
      return '${(number / 1000000000000).toStringAsFixed(1)}T';
    } else if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 9000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else {
      return number.toString();
    }
  }

  String formatNumberWithThousandSeparator({required num number}) {
    if (number >= 1000000000000) {
      return '${(number / 1000000000000)}T';
    } else if (number >= 1000000000) {
      return '${(number / 1000000000)}B';
    } else if (number >= 9000000) {
      return '${(number / 1000000)}M';
    } else {
      final formatter = NumberFormat('#,##0', 'en_US');
      return formatter.format(number);
    }

  }

  // formatNumber({required num number, TextStyle? style}) {
  //   if (number.abs() >= 1000000) {
  //     // return text with tooltip
  //     return Tooltip(
  //       message: formatNumberWithThousandSeparator(number: (number).round()),
  //       child: Text(
  //         formatNumberWithThousandSeparator(number: (number).round()),
  //         style: style,
  //       ),
  //     );
  //   } else {
  //     // return text with tooltip
  //     return Tooltip(
  //       message: formatNumberWithThousandSeparator(number: (number).round()),
  //       child: Text(
  //         formatNumberWithThousandSeparator(number: (number).round()),
  //         style: style,
  //       ),
  //     );
  //   }
  // }

  static void showSnackBar({
    required String message,
    bool? isSuccess,
    BuildContext? context,
  }) {
    // Determine properties based on the state (success, error, or info)
    final String title;
    final Color backgroundColor;
    final IconData iconData;

    if (isSuccess == true) {
      title = 'Success'.tr;
      backgroundColor = Colors.green.shade600;
      iconData = Icons.check_circle_outline;
    } else if (isSuccess == false) {
      title = 'Error'.tr;
      backgroundColor = Colors.red.shade700;
      iconData = Icons.error_outline;
    } else {
      title = 'Info'.tr;
      backgroundColor = Colors.blue.shade600;
      iconData = Icons.info_outline;
    }

    // Use Get.rawSnackbar for complete customisation
    Get.rawSnackbar(
      // The GestureDetector makes the entire snackbar tappable
      messageText: GestureDetector(
        onTap: () {
          // Immediately close the snackbar on tap
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(iconData, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // --- Styling for the snackbar itself ---
      backgroundColor: Colors
          .transparent, // Important: Make the default background transparent
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      duration: const Duration(
        seconds: 4,
      ), // It will auto-dismiss if not tapped
      isDismissible: true, // Allows swipe-to-dismiss as well
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  static String generateUUID() {
    const uuid = Uuid();
    return uuid.v4();
  }

  // random number generator limit 5
  static String generateRandomNumber() {
    final random = Random();
    final randomNumber = random.nextInt(99999);
    return randomNumber.toString();
  }

  static Future<String?> uploadImageToFirebaseStorage({
    required File imageFile,
    required String filename,
    required String folder,
  }) async {
    try {
      // Reference to a Firebase Storage location
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage
          .instance
          .ref()
          .child(folder);

      // Upload the file to Firebase Storage
      final firebase_storage.UploadTask uploadTask = storageRef
          .child(filename)
          .putFile(imageFile);
      // print("FILENAME: $filename");

      // Wait for the upload to complete and get the download URL
      final firebase_storage.TaskSnapshot storageSnapshot = await uploadTask;
      final String downloadURL = await storageSnapshot.ref.getDownloadURL();
      // print("DOWNLOAD URL: $downloadURL");

      return downloadURL;
    } catch (error) {
      print('Error uploading image: $error');
      return null;
    }
  }

  Future<String?> uploadImage({
    required File imageFile,
    required String folderName,
  }) async {
    // Upload the image to Firebase Storage
    String fileName =
        '$folderName/images/${DateTime.now().millisecondsSinceEpoch}';
    UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

    // Get the image URL
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<bool> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        return true;
      } else {
        print('Could not launch phone service - not available on this device');
        return false;
      }
    } catch (e) {
      print('Could not launch phone service: $e');
      return false;
    }
  }

  static Future<void> openLink({required String url}) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
    await launchUrl(emailLaunchUri);
  }

  /// Share content using the device's native sharing functionality
  Future<void> shareContent({
    required String subject,
    required String text,
    String? webUrl,
  }) async {
    try {
      // For mobile platforms, use Share.share from share_plus
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
          sharePositionOrigin: Rect.zero,
        ),
      );
    } catch (e) {
      print('Error sharing content: $e');
      // Fallback to URL launcher for web or if share fails
      if (webUrl != null) {
        await _fallbackShare(webUrl, text);
      }
    }
  }

  /// Fallback sharing method using URL schemes
  Future<void> _fallbackShare(String url, String text) async {
    try {
      // Try WhatsApp first
      final whatsappUrl =
          'whatsapp://send?text=${Uri.encodeComponent('$text $url')}';
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
        return;
      }

      // Try SMS
      final smsUrl = 'sms:?body=${Uri.encodeComponent('$text $url')}';
      if (await canLaunchUrl(Uri.parse(smsUrl))) {
        await launchUrl(Uri.parse(smsUrl));
        return;
      }

      // Try email
      final emailUrl =
          'mailto:?subject=${Uri.encodeComponent('Check out this job')}&body=${Uri.encodeComponent('$text $url')}';
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
        return;
      }

      // Finally, just open the URL
      await launchUrl(Uri.parse(url));
    } catch (e) {
      print('Error in fallback share: $e');
    }
  }

  static Future<void> launchURL({required String url}) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
      throw Exception('Could not launch $url');
    }
  }

  static String getDuoDateId({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return "${startDate.day}${startDate.month}${startDate.year}-${endDate.day}${endDate.month}${endDate.year}";
  }

  static String getDateId({required DateTime date}) {
    return "${date.day}${date.month}${date.year}";
  }

  static DateTime removeTime({required DateTime date}) {
    return DateTime(date.year, date.month, date.day);
  }

  static getRemainingDays({required DateTime date, required int days}) {
    final startingDays = days;
    final dueDate = date;
    final today = removeTime(date: DateTime.now());
    final difference = dueDate.difference(today).inDays;
    final remainingDays = difference > 0 ? difference : 0;
    final daysLeft = remainingDays > startingDays
        ? startingDays
        : remainingDays;
    return daysLeft;
  }

  static getVATAmount({required double amount, required double vatAmount}) {
    final value = amount * (vatAmount / (100 + vatAmount));
    return value;
  }

  static generateAccId({
    required String name,
    required DateTime date,
    required String type,
    required String businessId,
  }) {
    // we need to create id in a way that we increment the balance of the account in monthly basis, so we have to use date and any other important field to accomplish this
    // final id = accId ?? ("$name-${date.year}-${date.month}-$type-$businessId")
    //     .replaceAll(', ', '-').replaceAll(" ", "-").toLowerCase();

    final id = ("$name-${date.year}-${date.month}-$type-$businessId")
        .replaceAll(', ', '-')
        .replaceAll(" ", "-")
        .toLowerCase();
    return id;
  }

  Future<bool> processPayment({
    required String payNumber,
    required String packageId,
    required String uid,
    required String paymentMethod,
    required String endpointUrl,
    required String apiKey,
  }) async {
    final Uri url = Uri.parse(endpointUrl);
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer $apiKey', // assuming the API uses Bearer token for authentication
    };

    final Map<String, dynamic> body = {
      'payNumber': payNumber,
      'packageId': packageId,
      'uid': uid,
      'paymentMethod': paymentMethod,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      // Assuming the endpoint returns a JSON with a 'success' key indicating the operation's result
      return jsonResponse['success'] ?? false;
    } else {
      print(
        'Error processing payment: ${response.statusCode}, ${response.body}',
      );
      return false;
    }
  }

  void customSnackBar({
    required BuildContext context,
    required String message,
    String? type,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: type == 'error'
            ? AppStyle.errorColor(context)
            : AppStyle.primaryColor(context),
        content: Text(message.tr),
        action: SnackBarAction(
          label: 'Okay'.tr,
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      ),
    );
  }

  void comingSoonPrompt({required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coming soon'.tr),
        action: SnackBarAction(
          label: 'Okay'.tr,
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      ),
    );
  }

  void OkayPrompt({required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successful'.tr),
        action: SnackBarAction(
          label: 'Okay'.tr,
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      ),
    );
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!'.tr;
    }
    if (hour < 17) {
      return 'Good Afternoon!'.tr;
    }
    return 'Good Evening!'.tr;
  }

  static String getFormattedDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  // get time ago or hours ago or days ago or date, etc
  static String timeAgo({required DateTime date}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      // Using DateFormat to show 'Mon 10:00 AM' format for dates within a week
      return DateFormat('EEE hh:mm a').format(date);
    } else if (now.year == date.year) {
      // Using DateFormat for 'Mar 5' format for dates within the current year
      return DateFormat('MMM d').format(date);
    } else {
      // Using DateFormat for 'Mar 5, 2020' format for older dates
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  // static String generateStreamVideoToken(
  //     {required String userId, required String apiSecret}) {
  //   // Calculate timestamps
  //   final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  //   final weekInSeconds = 604800; // 7 days

  //   // Create JWT
  //   final jwt = JWT(
  //     {
  //       "iss": "https://pronto.getstream.io",
  //       "sub": "user/$userId",
  //       "user_id": userId,
  //       "validity_in_seconds": weekInSeconds,
  //       "iat": currentTime,
  //       "exp": currentTime + weekInSeconds,
  //     },
  //   );

  //   // Sign it
  //   try {
  //     return jwt.sign(SecretKey(apiSecret));
  //   } catch (e) {
  //     print('Error generating token: $e');
  //     rethrow;
  //   }
  // }

  static copyToClipboard({required String text}) {
    Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> saveIdToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('idToken', token);
  }

  Future<String?> getIdToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('idToken');
  }

  Future<void> saveAccessToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> removeAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }

  static String trimmedText(String text, int charLimit) {
    return text.length > charLimit
        ? '${text.substring(0, charLimit)}...'
        : text;
  }

  bool isShopOpen(String openingTime, String closingTime) {
    final currentTime = DateTime.now();
    // Convert opening and closing times to DateTime objects
    final openingDateTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      int.parse(openingTime.split(':')[0]),
      int.parse(openingTime.split(':')[1]),
    );
    final closingDateTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      int.parse(closingTime.split(':')[0]),
      int.parse(closingTime.split(':')[1]),
    );

    // Check if current time is within the opening hours
    return currentTime.isAfter(openingDateTime) &&
        currentTime.isBefore(closingDateTime);
  }

  Future<ui.Image> loadImage(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  // Future<BitmapDescriptor> createCustomMarkerBitmap(String time, String assetImagePath) async {
  //   final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   final Paint paint = Paint();

  //   // Define the size of the canvas
  //   const Size size = Size(150, 200);

  //   // Load the image from the assets
  //   final ui.Image image = await loadImage(assetImagePath);

  //   // Draw the image on the canvas
  //   paintImage(canvas: canvas, rect: Rect.fromLTWH(0, 0, size.width, size.height), image: image);

  //   // Only draw time if it is provided
  //   if (time.isNotEmpty) {
  //     // Prepare the text painter to determine the size of the text
  //     final TextPainter textPainter = TextPainter(
  //       text: TextSpan(
  //         text: time,
  //         style: const TextStyle(
  //           fontSize: 35,
  //           color: Colors.white,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       textDirection: ui.TextDirection.ltr,
  //       textAlign: TextAlign.center,
  //     );

  //     // Layout the text to get the size
  //     textPainter.layout();

  //     // Calculate the position for the text
  //     final Offset textOffset = Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2);

  //     // Draw the rectangle for the text background
  //     paint.color = AppStyle.primaryColor; // Replace with your actual primary color
  //     final Rect textBackgroundRect = Rect.fromLTWH(
  //       textOffset.dx - 10, // Padding to the left
  //       textOffset.dy - 10, // Padding to the top
  //       textPainter.width + 20, // Width of the text plus some padding
  //       textPainter.height + 20, // Height of the text plus some padding
  //     );
  //     final RRect roundedRectangle = RRect.fromRectAndRadius(textBackgroundRect, const Radius.circular(12));
  //     canvas.drawRRect(roundedRectangle, paint);

  //     // Draw the text on top of the rectangle
  //     textPainter.paint(canvas, textOffset);
  //   }

  //   // Convert canvas to image
  //   final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  //   final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  //   final Uint8List uint8list = byteData!.buffer.asUint8List();

  //   // Create a marker from the image
  //   return BitmapDescriptor.fromBytes(uint8list);
  // }

  Future<BitmapDescriptor> createCustomMarkerBitmap(
    String time,
    String label,
  ) async {
    // Define the size of the marker card
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    double val = 600;
    label == "destination" ? val = 600 : val = 160;
    Size size = Size(val, 80); // Size of the rectangle card

    // Draw the rectangle card
    final Paint paint = Paint()..color = Colors.white;
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);

    // Add border to the rectangle
    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, borderPaint);

    // Add text to the rectangle
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label == "destination" ? 'Arrival est. $time' : "Origin",
        style: const TextStyle(fontSize: 45, color: Colors.black),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width - 10);
    textPainter.paint(
      canvas,
      Offset(10, size.height / 2 - textPainter.height / 2),
    );

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final ByteData? byteData = await markerAsImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  double calculateZoomLevel(double distance) {
    const double a = -2.78;
    const double b = 16.21;
    return a * log(distance) / ln10 +
        b; // Dart uses ln for the natural logarithm; log(x) / ln(10) gives log base 10.
  }

  CameraPosition getCameraPosition(
    double startingLatitude,
    double startingLongitude,
    double destinationLatitude,
    double destinationLongitude,
    double distance,
  ) {
    double minLat = startingLatitude < destinationLatitude
        ? startingLatitude
        : destinationLatitude;
    double maxLat = startingLatitude > destinationLatitude
        ? startingLatitude
        : destinationLatitude;
    double minLng = startingLongitude < destinationLongitude
        ? startingLongitude
        : destinationLongitude;
    double maxLng = startingLongitude > destinationLongitude
        ? startingLongitude
        : destinationLongitude;

    CameraPosition cameraPosition = CameraPosition(
      target: LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
      zoom: calculateZoomLevel(distance),
    );

    return cameraPosition;
  }

  Future<String?> uploadAudioFile(String filePath) async {
    File file = File(filePath);
    String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(fileName);
      firebase_storage.UploadTask uploadTask = ref.putFile(file);
      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<String>> downloadAndSaveImages({
    required List<String> urls,
    required String messageId,
    required String deviceId,
    required String fileType,
  }) async {
    List<String> localPaths = [];

    try {
      // Get the directory for saving files
      final dir = await getApplicationDocumentsDirectory();
      final chatDirectoryPath = path.join(
        dir.path,
        'sasachat',
        'chats',
        '${fileType.toLowerCase()}',
      );
      final chatDirectory = Directory(chatDirectoryPath);

      // Create the directory if it doesn't exist
      if (!await chatDirectory.exists()) {
        await chatDirectory.create(recursive: true);
      }

      // Loop through the image URLs
      for (String url in urls) {
        // Get the file name and generate the local file path
        final fileName = path.basename(Uri.parse(url).path);
        final localFilePath = path.join(chatDirectoryPath, fileName);
        final existingFile = File(localFilePath);

        // Check if the file already exists locally
        if (await existingFile.exists()) {
          // If file exists, just add the local file path to the list
          localPaths.add(localFilePath);
        } else {
          // If the file doesn't exist, download it
          print("Downloading image from URL: $url");
          final uri = Uri.parse(url);
          final response = await http.get(uri);

          if (response.statusCode == 200) {
            // Write the downloaded image to the local file path
            final file = File(localFilePath);
            await file.writeAsBytes(response.bodyBytes);
            localPaths.add(localFilePath);
          } else {
            throw Exception(
              "Failed to download image with status code: ${response.statusCode}",
            );
          }
        }
      }

      // 5. Save all downloaded image file paths to Firestore
      await saveImagesFilePathsToFirestore(
        filePaths: localPaths,
        messageId: messageId,
        deviceId: deviceId,
        isDownloaded: true,
      );

      return localPaths; // Return the list of local file paths
    } catch (e) {
      print("Error downloading or saving images: $e");
      throw e;
    }
  }

  Future<String> getLocalFilePath(String chatId, String fileName) async {
    // Get the app's document directory.
    final appDir = await getApplicationDocumentsDirectory();

    // Construct the path step-by-step using `p.join` for platform-safe separators.
    // This yields a path like:
    // /data/data/co.tz.skyconnect.flex/app_flutter/sasachat/chats/files/chatFiles/<chatId>/<fileName>
    final filePath = path.join(
      appDir.path,
      'sasachat',
      'chats',
      'files',
      'chatFiles',
      chatId,
      fileName,
    );

    return filePath;
  }

  Future<String> downloadAndSaveFile({
    required String url,
    required String messageId,
    required String deviceId,
    required String fileType,
  }) async {
    try {
      // 1. Dynamically generate the local file path
      final dir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(Uri.parse(url).path);
      // print("FILE NAME: $fileName");
      final chatDirectoryPath = path.join(
        dir.path,
        'sasachat',
        'chats',
        '${fileType.toLowerCase()}',
      );
      final localFilePath = path.join(chatDirectoryPath, fileName);
      // print("FUNCS LOCAL FILE PATH: $localFilePath");
      final existingFile = File(localFilePath);

      // print("Checking file at path: $localFilePath");

      // 2. Check if the file already exists locally
      if (await existingFile.exists()) {
        // print("FILE EXISTS");
        // print("File already exists on device at path: $localFilePath");
        await saveFilePathToFirestore(
          filePath: localFilePath,
          messageId: messageId,
          deviceId: deviceId,
          isDownloaded: true,
        );
        return localFilePath; // Return the path if the file already exists locally
      }

      // 3. If not locally available, check Firestore for the file URL
      var messageSnapshot = await DbService().messagesRef.doc(messageId).get();
      if (messageSnapshot.exists) {
        var messageData = messageSnapshot.data();
        if (messageData != null && messageData['attachments'] != null) {
          url =
              messageData['attachments']['filePath']; // Use Firebase Storage URL for download
        }
      }

      // 4. Download the file from Firebase Storage
      print("Downloading file from URL: $url");
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Create the directory if it doesn't exist
        final chatDirectory = Directory(chatDirectoryPath);
        if (!await chatDirectory.exists()) {
          await chatDirectory.create(recursive: true);
        }

        // Write the downloaded file to the local storage
        final file = File(localFilePath);
        await file.writeAsBytes(response.bodyBytes);
        // print('Downloaded file saved to: ${file.path}');

        // 5. Update Firestore with the file path and download status
        await saveFilePathToFirestore(
          filePath: file.path,
          messageId: messageId,
          deviceId: deviceId,
          isDownloaded: true,
        );
        print("RETURNING: ${file.path}");
        return file.path;
      } else {
        throw Exception(
          "Failed to download audio file with status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error downloading or saving the file: $e");
      throw e;
    }
  }

  Future<void> saveImagesFilePathsToFirestore({
    required List<String> filePaths,
    required String messageId,
    required String deviceId,
    required bool isDownloaded,
  }) async {
    try {
      // Get the message snapshot from Firestore by message ID
      var messageSnapshot = await DbService().messagesRef
          .where("id", isEqualTo: messageId)
          .get();
      var messageRef = messageSnapshot.docs.first.reference;

      // Prepare the map for downloaded image file paths per device
      Map<String, dynamic> downloadedImagesMap = {
        'attachments.downloadedByUsers.$deviceId': {
          'isDownloaded': isDownloaded,
          'filePaths': filePaths, // Store the list of file paths
        },
      };

      // Update Firestore to mark the image file paths as downloaded for this user
      await messageRef.update(downloadedImagesMap);

      // print("Image file paths updated for device $deviceId: $isDownloaded");
    } catch (e) {
      print("Error saving image file paths to Firestore: $e");
    }
  }

  // Function to save file path to Firestore
  static Future<void> saveFilePathToFirestore({
    required String filePath,
    required String messageId,
    required String deviceId,
    required bool isDownloaded,
  }) async {
    try {
      var messageSnapshot = await DbService().messagesRef
          .where("id", isEqualTo: messageId)
          .get();
      var messageRef = messageSnapshot.docs.first.reference;
      // print("SAVING TO FIRESTORE");
      // Update Firestore to mark the file as downloaded for this user
      await messageRef.update({
        'attachments.downloadedByUsers.$deviceId':
            isDownloaded, // Update nested field for the specific user
      });

      // print("File download status updated for user $userId: $isDownloaded");
    } catch (e) {
      print("Error saving file path or download status to Firestore: $e");
    }
  }

  static Future<String?> uploadFileToFirebaseStorage({
    required File file,
    required String filename,
    required String folder,
  }) async {
    try {
      // Reference to a Firebase Storage location
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage
          .instance
          .ref()
          .child(folder);

      // Upload the file to Firebase Storage
      final firebase_storage.UploadTask uploadTask = storageRef
          .child(filename)
          .putFile(file);

      // Wait for the upload to complete and get the download URL
      final firebase_storage.TaskSnapshot storageSnapshot = await uploadTask;
      final String downloadURL = await storageSnapshot.ref.getDownloadURL();
      // print("DOWNLOAD URL: $downloadURL");

      return downloadURL;
    } catch (error) {
      print('Error uploading file: $error');
      return null;
    }
  }

  String getInitials(String name) {
    List<String> names = name.split(" ");
    String initials = "";

    if (names.isNotEmpty) {
      // Ensure the first part of the name is not empty
      if (names.first.isNotEmpty) {
        initials += names.first[0];
      }

      // Check for a last name and ensure it's not empty
      if (names.length > 1 && names.last.isNotEmpty) {
        initials += names.last[0];
      }
    }

    return initials.toUpperCase();
  }

  //Check if fine has passed
  bool hasFinePeriodPassed(DateTime dueDate, int finePeriodDays) {
    DateTime fineDueDate = dueDate.add(Duration(days: finePeriodDays));
    DateTime today = DateTime.now();

    // If today's date is after the fine due date, the fine period has passed
    return today.isAfter(fineDueDate);
  }

  double roundUpToTwoDecimalPlaces(double value) {
    return (value * 100).ceil() / 100;
  }

  double roundUpAndRemoveDecimals(double number) {
    return double.parse(number.ceil().toString());
  }

  //Send SMS
  void sendSMS({required String phoneNumber, required String message}) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'Could not launch $smsUri';
    }
  }

  Color generateRandomColor({required String id}) {
    Random random = Random(id.hashCode);
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Future<BitmapDescriptor> createCustomEventBitmap() async {
    // Load the image
    final ByteData data = await rootBundle.load("assets/img/event_home.png");
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 100,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  static String formatTimestampHumanReadable(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat(
      'MMMM dd, yyyy – hh:mm a',
    ).format(dateTime);
    return formattedDate;
  }

  // List<SoldTicketModel> convertToSoldTickets({var soldTicketsList}) {
  //   List<SoldTicketModel> soldTickets = [];
  //   for (var ticket in soldTicketsList) {
  //     var soldTicket =
  //         SoldTicketModel(ticketId: ticket['id'], quantity: ticket["quantity"]);
  //     soldTickets.add(soldTicket);
  //   }
  //   return soldTickets;
  // }

  String deliveryTrackingId({required String orderId}) {
    return orderId.substring(orderId.length - 7).toUpperCase();
  }

  // static Stream<QuerySnapshot> getUnreadNotifications() {
  //   String uid = AuthService().currentUser!.uid;
  //   return DbService().notificationsRef
  //       .where('uid', isEqualTo: uid)
  //       .where('isUnread', isEqualTo: true)
  //       .orderBy('dateUpdated', descending: true)
  //       .snapshots();
  // }

  static Future<Map<String, dynamic>> uploadImageAttachmentsToFirebaseStorage({
    required Map<String, dynamic> attachments,
    required String chatId,
  }) async {
    Map<String, dynamic> updatedAttachments = {
      'fileType': attachments['fileType'], // Keep the file type
      'images': [], // Initialize an empty list to store uploaded image URLs
      'downloadedByUsers': {},
    };

    List<File> images = attachments['images']; // List of image files

    // Loop through the list of images
    for (File image in images) {
      try {
        String localFilePath = image.path; // Local file path of the image
        String storageFilePath = path.join(
          "chatImages",
          sanitizeString(chatId), // Sanitize the chat ID to create a valid path
          sanitizeFileName(path.basename(localFilePath)), // Sanitize file name
        );

        // Upload the file to Firebase Storage and get the download URL
        String? downloadUrl = await uploadFileAndGetDownloadUrl(
          file: image,
          storageFilePath: storageFilePath, // Use the correct storage path
        );

        // If the download URL is obtained, add it to the list of images
        if (downloadUrl != null) {
          updatedAttachments['images'].add({
            'fileName': path.basename(localFilePath),
            'filePath': downloadUrl, // Firebase Storage URL
          });
          print('Image uploaded to Firebase Storage: $downloadUrl');
        } else {
          print('Failed to retrieve download URL for image.');
        }
      } catch (e) {
        print('Failed to upload image to Firebase Storage: $e');
      }
    }

    return updatedAttachments;
  }

  static Future<Map<String, dynamic>> uploadAttachmentToFirebaseStorage({
    required Map<String, dynamic> attachments,
    required String chatId,
  }) async {
    Map<String, dynamic> updatedAttachments = {};

    if (attachments.containsKey('filePath')) {
      String localFilePath =
          attachments['filePath']; // Local file path on device
      String storageFilePath = path.join(
        "chatFiles",
        sanitizeString(chatId),
        sanitizeFileName(path.basename(localFilePath)),
      ); // Firebase Storage path
      // print("STORAGE FILE PATH: $storageFilePath");
      try {
        // Create file object from the local file path
        File file = File(localFilePath);

        // Call method to upload file and get the download URL
        String? downloadUrl = await uploadFileAndGetDownloadUrl(
          file: file,
          storageFilePath: storageFilePath, // Use the correct storage path
        );

        // If download URL is obtained, update attachments
        if (downloadUrl != null) {
          updatedAttachments = {
            'fileName': path.basename(localFilePath),
            'filePath': downloadUrl, // Firebase Storage URL
            'fileType':
                attachments['fileType'], // Preserving other attachment details
            'downloadedByUsers': {},
          };
          print('File uploaded to Firebase Storage: $downloadUrl');
        } else {
          print('Failed to retrieve download URL.');
        }
      } catch (e) {
        print('Failed to upload attachment to Firebase Storage: $e');
      }
    }
    return updatedAttachments;
  }

  // Method to upload file to Firebase Storage and get the download URL
  static Future<String?> uploadFileAndGetDownloadUrl({
    required File file,
    required String storageFilePath,
  }) async {
    try {
      // Check if the file exists locally
      if (!file.existsSync()) {
        return null;
      }

      // Firebase Storage reference using the provided storage file path
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(storageFilePath);

      // Upload the file to Firebase Storage
      UploadTask uploadTask = ref.putFile(file);

      // Wait until the upload completes
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL of the uploaded file
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Return the download URL
      return downloadUrl;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getFilePath(String fileName) async {
    // Get the correct directory based on the platform (iOS/Android)
    final directory =
        await getApplicationDocumentsDirectory(); // For internal storage
    return {
      'appDirectory': directory,
      'localFilePath': '${directory.path}/$fileName',
    }; // This will give you the appropriate path
  }

  static Future<Directory> _getDir() async {
    return await getApplicationDocumentsDirectory();
  }

  static String generateUniqueFileName({
    required String fileExtension,
    required String prefix,
  }) {
    final now = DateTime.now();
    return '${prefix}_${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}.$fileExtension';
  }

  static Future<void> sendMessageWithFile({
    required String message,
    required String path,
    required String fileType,
    DocumentSnapshot? me,
    required dynamic chatData,
    required DocumentSnapshot userData,
    required String type,
    String? replyDataId,
    String? messageId,
    VoidCallback? clearCallback,
  }) async {
    // print("ENTERED FILE SENDING FUNCTION");
    String? filePath;
    String memberDocId = '';
    filePath = path;
    if (clearCallback != null) {
      clearCallback();
    }
    Map<String, dynamic> memberData = {};
    // print("FILE PATH: $filePath");

    try {
      if (chatData["chatType"] == "Individual") {
        var members = await DbService().membersRef
            .where('chatId', isEqualTo: chatData['id'])
            .where('uid', isNotEqualTo: userData.id)
            .limit(1)
            .get();

        if (members.docs.isNotEmpty) {
          memberDocId = members.docs.first.id;
          memberData = members.docs.first.data();
        } else {
          print("No members found.");
        }
      }

      var attachments = {
        'fileType': fileType, // 'Images', 'Videos', 'Audios', 'Files
        'filePath': filePath,
        'downloadedByUsers': {},
      };

      var notificationData = {
        "action_type": "message_received",
        // "senderId": AuthService().currentUser!.uid,
        "senderId": '', // REPLACE WITH REAL SENDER ID WHEN INTEGRATING
        "chatType": chatData['chatType'],
        "phoneNumber": userData['phoneNumber'],
        "chatData": chatData,
        "memberMapData": chatData['chatType'] == 'Individual'
            ? me?.data()
            : null,
      };

      // Send the message
      await DbService()
          .updateMessageDoc(
            messageId: messageId,
            chatType: chatData['chatType'],
            memberDocId: chatData['chatType'] == 'Individual'
                ? memberDocId
                : null,
            chatId: chatData['id'],
            uid: userData.id,
            senderName: userData['fullName'],
            avatarURL: userData['avatarURL'],
            message: message,
            branchName: null,
            replyId: replyDataId,
            type: filePath.isNotEmpty ? type : 'Text',
            dateAdded: DateTime.now(),
            attachments: filePath.isEmpty
                ? null
                : attachments, // This will be null for text messages
            status: 'Sent',
            // senderId: AuthService().currentUser!.uid,
            senderId: '', // REPLACE WITH REAL SENDER ID WHEN INTEGRATING
          )
          .whenComplete(() async {
            try {
              if (chatData["chatType"] == "Individual") {
                var members = await DbService().membersRef
                    .where('chatId', isEqualTo: chatData['id'])
                    .where('uid', isNotEqualTo: userData.id)
                    .get();

                if (members.docs.isNotEmpty) {
                  var user = await DbService().usersRef
                      .where('uid', isEqualTo: memberData["uid"])
                      .get();
                  // send notification to user using FCM if there are FCM Tokens
                  if (user.docs.isNotEmpty) {
                    final userDoc = user.docs[0].data() as Map<String, dynamic>;

                    // Get FCM tokens array, fallback to single token for backward compatibility
                    List<dynamic> fcmTokensRaw = userDoc['fcmTokens'] ?? [];
                    List<String> fcmTokens = fcmTokensRaw.cast<String>();

                    // If no tokens in array but has old notifToken, use that
                    if (fcmTokens.isEmpty && userDoc["notifToken"] != null) {
                      fcmTokens = [userDoc["notifToken"]];
                    }

                    if (fcmTokens.isNotEmpty) {
                      DbService().sendNotificationToAllDevices(
                        data: notificationData,
                        title: userData['fullName'],
                        body: type,
                        tokens: fcmTokens,
                        senderId: userData.id,
                        chatType: "Individual",
                        phoneNumber: userData['phoneNumber'],
                        chatId: chatData['id'],
                        actionType: 'message_received',
                        receiverId: memberData["uid"],
                      );
                    }
                  }
                }
              }

              if (chatData["chatType"] == "Community") {
                var members = await DbService().membersRef
                    .where('chatId', isEqualTo: chatData['id'])
                    .get();

                for (var member in members.docs) {
                  if (member["uid"] != userData.id) {
                    var user = await DbService().usersRef
                        .where('uid', isEqualTo: member["uid"])
                        .get();

                    // send notification to user using FCM if there are FCM tokens
                    if (user.docs.isNotEmpty && !member['isDeleted']) {
                      final userDoc = user.docs[0].data();

                      // Get FCM tokens array, fallback to single token for backward compatibility
                      List<dynamic> fcmTokensRaw = userDoc['fcmTokens'] ?? [];
                      List<String> fcmTokens = fcmTokensRaw.cast<String>();

                      // If no tokens in array but has old notifToken, use that
                      if (fcmTokens.isEmpty && userDoc["notifToken"] != null) {
                        fcmTokens = [userDoc["notifToken"]];
                      }

                      if (fcmTokens.isNotEmpty) {
                        DbService().sendNotificationToAllDevices(
                          data: notificationData,
                          title: userData['fullName'],
                          body: type,
                          tokens: fcmTokens,
                          senderId: userData.id,
                          chatType: "Community",
                          phoneNumber: userData['phoneNumber'],
                          chatId: chatData['id'],
                          actionType: 'message_received',
                          receiverId: member["uid"],
                        );
                      }
                    }
                  }
                }
              }
            } catch (e) {
              print("Error in whenComplete block: $e");
            }
          });
    } catch (e) {
      print("Error in sendMessageWithFile: $e");
    }
  }

  static Future<void> sendMessageWithImages({
    required String message,
    required List<File> images,
    required String fileType,
    DocumentSnapshot? me,
    required dynamic chatData,
    required DocumentSnapshot userData,
    required String type,
    String? replyDataId,
    VoidCallback? clearCallback,
    String? messageId,
  }) async {
    // print("ENTERED FILE SENDING FUNCTION");
    String memberDocId = '';
    if (clearCallback != null) {
      clearCallback();
    }
    Map<String, dynamic> memberData = {};
    // print("FILE PATH: $filePath");

    try {
      if (chatData["chatType"] == "Individual") {
        var members = await DbService().membersRef
            .where('chatId', isEqualTo: chatData['id'])
            .where('uid', isNotEqualTo: userData.id)
            .limit(1)
            .get();

        if (members.docs.isNotEmpty) {
          memberDocId = members.docs.first.id;
          memberData = members.docs.first.data();
        } else {
          print("No members found.");
        }
      }

      var attachments = {
        'fileType': fileType, // 'Images', 'Videos', 'Audios', 'Files
        'images': images,
        'downloadedByUsers': {},
      };

      var notificationData = {
        "action_type": "message_received",
        // "senderId": AuthService().currentUser!.uid,
        "senderId": '', // REPLACE WITH REAL SENDER ID WHEN INTEGRATING
        "chatType": chatData['chatType'],
        "phoneNumber": userData['phoneNumber'],
        "chatData": chatData,
        "memberMapData": chatData['chatType'] == 'Individual'
            ? me?.data()
            : null,
      };

      // Send the message
      await DbService()
          .updateMessageDoc(
            messageId: messageId,
            chatType: chatData['chatType'],
            memberDocId: chatData['chatType'] == 'Individual'
                ? memberDocId
                : null,
            chatId: chatData['id'],
            uid: userData.id,
            senderName: userData['fullName'],
            avatarURL: userData['avatarURL'],
            message: message,
            branchName: null,
            replyId: replyDataId,
            type: 'Image',
            dateAdded: DateTime.now(),
            attachments: attachments, // This will be null for text messages
            status: 'Sent',
            // senderId: AuthService().currentUser!.uid,
            senderId: '', // REPLACE WITH REAL SENDER ID WHEN INTEGRATING
          )
          .whenComplete(() async {
            try {
              if (chatData["chatType"] == "Individual") {
                var members = await DbService().membersRef
                    .where('chatId', isEqualTo: chatData['id'])
                    .where('uid', isNotEqualTo: userData.id)
                    .get();

                if (members.docs.isNotEmpty) {
                  var user = await DbService().usersRef
                      .where('uid', isEqualTo: memberData["uid"])
                      .get();
                  // send notification to user using FCM if there are FCM Tokens
                  if (user.docs.isNotEmpty) {
                    final userDoc = user.docs[0].data();

                    // Get FCM tokens array, fallback to single token for backward compatibility
                    List<dynamic> fcmTokensRaw = userDoc['fcmTokens'] ?? [];
                    List<String> fcmTokens = fcmTokensRaw.cast<String>();

                    // If no tokens in array but has old notifToken, use that
                    if (fcmTokens.isEmpty && userDoc["notifToken"] != null) {
                      fcmTokens = [userDoc["notifToken"]];
                    }

                    if (fcmTokens.isNotEmpty) {
                      DbService().sendNotificationToAllDevices(
                        data: notificationData,
                        title: userData['fullName'],
                        body: "Image",
                        tokens: fcmTokens,
                        senderId: userData.id,
                        chatType: "Individual",
                        phoneNumber: userData['phoneNumber'],
                        chatId: chatData['id'],
                        actionType: 'message_received',
                        receiverId: memberData["uid"],
                      );
                    }
                  }
                }
              }

              if (chatData["chatType"] == "Community") {
                var members = await DbService().membersRef
                    .where('chatId', isEqualTo: chatData['id'])
                    .get();

                for (var member in members.docs) {
                  if (member["uid"] != userData.id) {
                    var user = await DbService().usersRef
                        .where('uid', isEqualTo: member["uid"])
                        .get();

                    // send notification to user using FCM if there are FCM tokens
                    if (user.docs.isNotEmpty && !member['isDeleted']) {
                      final userDoc = user.docs[0].data();

                      // Get FCM tokens array, fallback to single token for backward compatibility
                      List<dynamic> fcmTokensRaw = userDoc['fcmTokens'] ?? [];
                      List<String> fcmTokens = fcmTokensRaw.cast<String>();

                      // If no tokens in array but has old notifToken, use that
                      if (fcmTokens.isEmpty && userDoc["notifToken"] != null) {
                        fcmTokens = [userDoc["notifToken"]];
                      }

                      if (fcmTokens.isNotEmpty) {
                        DbService().sendNotificationToAllDevices(
                          data: notificationData,
                          title: userData['fullName'],
                          body: "Image",
                          tokens: fcmTokens,
                          senderId: userData.id,
                          chatType: "Community",
                          phoneNumber: userData['phoneNumber'],
                          chatId: chatData['id'],
                          actionType: 'message_received',
                          receiverId: member["uid"],
                        );
                      }
                    }
                  }
                }
              }
            } catch (e) {
              print("Error in whenComplete block: $e");
            }
          });
    } catch (e) {
      print("Error in sendMessageWithFile: $e");
    }
  }

  static Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  static void sendMessage({
    String? messageId,
    required dynamic messageContent,
    required String notificationContent,
    required String type,
    DocumentSnapshot? me,
    required dynamic chatData,
    required DocumentSnapshot userData,
    required DocumentSnapshot? replyData,
    VoidCallback? clearCallback,
    required Map<String, dynamic>? attachments,
    VoidCallback? onSuccess,
  }) async {
    Map<String, dynamic> memberData = {};
    String memberDocId = '';
    if (chatData["chatType"] == "Individual") {
      var members = await DbService().membersRef
          .where('chatId', isEqualTo: chatData['id'])
          .where('uid', isNotEqualTo: userData.id)
          .where('isDeleted', isEqualTo: false)
          .limit(1)
          .get();
      memberDocId = members.docs.first.id;
      memberData = members.docs.first.data();
    }

    var notificationData = {
      "action_type": "message_received",
      // "senderId": AuthService().currentUser!.uid,
      "senderId": '', // REPLACE WITH REAL SENDER ID WHEN INTEGRATING
      "chatType": chatData['chatType'],
      "phoneNumber": userData['phoneNumber'],
      "chatData": chatData as Map<String, dynamic>,
      "memberMapData": chatData['chatType'] == 'Individual' ? me?.data() : null,
    };

    await DbService()
        .updateMessageDoc(
          messageId: messageId,
          chatType: chatData['chatType'],
          memberDocId: chatData['chatType'] == 'Individual'
              ? memberDocId
              : null,
          chatId: chatData['id'],
          uid: userData.id,
          // senderId: AuthService().currentUser!.uid,
          senderId: '', // REPLACE WITH REAL SENDER ID WHEN INTEGRATING
          senderName: userData['fullName'],
          avatarURL: userData['avatarURL'],
          message: messageContent,
          branchName: null,
          replyId: replyData?.id,
          type: type,
          dateAdded: DateTime.now(),
          attachments: attachments,
          status: 'Sent',
        )
        .whenComplete(() async {
          if (clearCallback != null) {
            clearCallback();
          }

          if (chatData["chatType"] == "Individual") {
            var user = await DbService().usersRef
                .where('uid', isEqualTo: memberData["uid"])
                .get();
            //send notification to user using FCM if there are FCM Tokens
            if (user.docs.isNotEmpty) {
              final userDoc = user.docs[0].data();

              // Get FCM tokens array, fallback to single token for backward compatibility
              List<dynamic> fcmTokensRaw = userDoc['fcmTokens'] ?? [];
              List<String> fcmTokens = fcmTokensRaw.cast<String>();

              // If no tokens in array but has old notifToken, use that
              if (fcmTokens.isEmpty && userDoc["notifToken"] != null) {
                fcmTokens = [userDoc["notifToken"]];
              }

              if (fcmTokens.isNotEmpty) {
                DbService().sendNotificationToAllDevices(
                  data: notificationData,
                  title: userData['fullName'],
                  body: notificationContent,
                  tokens: fcmTokens,
                  senderId: userData.id,
                  chatType: "Individual",
                  phoneNumber: userData['phoneNumber'],
                  chatId: chatData['id'],
                  actionType: 'message_received',
                  receiverId: memberData["uid"],
                );
              }
            }
          }
          if (chatData["chatType"] == "Community") {
            var members = await DbService().membersRef
                .where('chatId', isEqualTo: chatData['id'])
                .where('isDeleted', isEqualTo: false)
                .get();
            members.docs.forEach((member) async {
              if (member["uid"] != userData.id) {
                var user = await DbService().usersRef
                    .where('uid', isEqualTo: member["uid"])
                    .get();
                //send notification to user using FCM if there are FCM tokens
                if (user.docs.isNotEmpty && !member['isDeleted']) {
                  final userDoc = user.docs[0].data();

                  // Get FCM tokens array, fallback to single token for backward compatibility
                  List<dynamic> fcmTokensRaw = userDoc['fcmTokens'] ?? [];
                  List<String> fcmTokens = fcmTokensRaw.cast<String>();

                  // If no tokens in array but has old notifToken, use that
                  if (fcmTokens.isEmpty && userDoc["notifToken"] != null) {
                    fcmTokens = [userDoc["notifToken"]];
                  }

                  if (fcmTokens.isNotEmpty) {
                    DbService().sendNotificationToAllDevices(
                      data: notificationData,
                      title: chatData['name'],
                      body: notificationContent,
                      tokens: fcmTokens,
                      senderId: userData.id,
                      chatType: "Community",
                      phoneNumber: userData['phoneNumber'],
                      chatId: chatData['id'],
                      actionType: 'message_received',
                      receiverId: member["uid"],
                    );
                  }
                }
              }
            });
          }
          if (onSuccess != null) {
            onSuccess();
          }
        });
  }

  static String formatChatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dateTime.isAfter(today)) {
      // If the date is today, show the time with AM/PM
      return formatTimeWithAmPm(dateTime);
    } else if (dateTime.isAfter(yesterday)) {
      // If the date is yesterday, return "Yesterday"
      return 'Yesterday';
    } else {
      // Otherwise, show the date in MM/DD/YY format
      return formatDateSlashed(dateTime);
    }
  }

  // Time ago functions
  static String formatTimeWithAmPm(DateTime dateTime) {
    //For chat tile
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$formattedHour:$minute $period';
  }

  static String formatDateSlashed(DateTime dateTime) {
    final day = dateTime.day;
    final month = dateTime.month;
    final year = dateTime.year % 100; // Last two digits of the year
    return '$month/$day/$year';
  }

  static String formatTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime);
  }

  DateTime getToday() {
    DateTime now = DateTime.now();
    // Create a date-only DateTime object (time set to midnight)
    DateTime today = DateTime(now.year, now.month, now.day);
    return today;
  }

  DateTime getYesterday() {
    DateTime today = getToday();
    // Subtract one day from today
    DateTime yesterday = today.subtract(Duration(days: 1));
    return yesterday;
  }

  bool isYesterday(DateTime dateToCheck) {
    DateTime yesterday = getYesterday();
    // Normalize the dateToCheck to date-only
    DateTime normalizedDate = DateTime(
      dateToCheck.year,
      dateToCheck.month,
      dateToCheck.day,
    );
    return normalizedDate == yesterday;
  }

  static String sanitizeString(String input) {
    // Define a regular expression that matches any character that is not
    // a letter, digit, or underscore.
    final sanitized = input.replaceAll(RegExp(r'[^\w]+'), '_');

    // Optionally, you can trim leading/trailing underscores
    return sanitized.replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static String sanitizeFileName(String filename) {
    // Find the last dot in the filename
    final lastDotIndex = filename.lastIndexOf('.');

    // If there's no dot or the dot is the first character (e.g., ".gitignore"), treat the whole as name
    if (lastDotIndex <= 0) {
      return sanitizeString(filename);
    }

    // Split the filename into name and extension
    final namePart = filename.substring(0, lastDotIndex);
    final extensionPart = filename.substring(lastDotIndex); // includes the dot

    // Sanitize the name part
    final sanitizedName = sanitizeString(namePart);

    // Rejoin sanitized name with the original extension
    return '$sanitizedName$extensionPart';
  }

  // static startChat(
  //     {required String userPhoneNumber,
  //     required String memberPhoneNumber,
  //     required DocumentSnapshot userData,
  //     required String memberName,
  //     bool sendGroupLink = false,
  //     Map<String, dynamic>? messageData}) async {
  //   final receiverSnapshot =
  //       DbService().usersRef.where("phoneNumber", isEqualTo: memberPhoneNumber);

  //   final receiverDocs = await receiverSnapshot.get();
  //   final receiverData = receiverDocs.docs.first.data();

  //   // combine phone numbers
  //   final id = "$userPhoneNumber-$memberPhoneNumber";
  //   List<String> idList = id.split("-");

  //   List<String> reversedIdList = idList.reversed.toList();
  //   String reversedId = reversedIdList.join("-");

  //   //Get Reversed Id Chat Document
  //   final reversedChatDoc = await DbService().chatsRefs.doc(reversedId).get();

  //   //Get Normal Id Chat Document
  //   final chatDoc = await DbService().chatsRefs.doc(id).get();

  //   var chatData = chatDoc.data();
  //   var reversedChatData = reversedChatDoc.data();

  //   bool chatDeleted = chatData != null ? chatData['isDeleted'] : false;
  //   bool reversedChatDeleted =
  //       reversedChatData != null ? reversedChatData['isDeleted'] : false;

  //   if ((chatDoc.exists || reversedChatDoc.exists) &&
  //       !(chatDeleted || reversedChatDeleted)) {
  //     final existingChatDoc = chatDoc.exists ? chatDoc : reversedChatDoc;
  //     existingChatDoc.data();

  //     final meQuerySnapshot = await DbService()
  //         .membersRef
  //         .where("chatId", isEqualTo: id)
  //         .where("uid", isEqualTo: AuthService().currentUser!.uid)
  //         .limit(1)
  //         .get();
  //     final me = meQuerySnapshot.docs.first;

  //     if (messageData != null) {
  //       sendMessage(
  //           messageContent: messageData["messageContent"],
  //           notificationContent: messageData["notificationContent"],
  //           type: messageData["type"],
  //           me: me,
  //           chatData: existingChatDoc,
  //           userData: userData,
  //           replyData: null,
  //           attachments: messageData["attachments"]);

  //       //Send link
  //       if (sendGroupLink) {
  //         try {
  //           final senderMeQuerySnapshot = await DbService()
  //               .membersRef
  //               .where("chatId", isEqualTo: id)
  //               .where("uid", isNotEqualTo: AuthService().currentUser!.uid)
  //               .limit(1)
  //               .get();
  //           final senderMe = senderMeQuerySnapshot.docs.first;
  //           final senderUserQuerySnapshot = await DbService()
  //               .usersRef
  //               .where("uid", isEqualTo: senderMe['uid'])
  //               .limit(1)
  //               .get();
  //           final senderUserData = senderUserQuerySnapshot.docs.first;
  //           final communityLinkQuerySnapshot = await DbService()
  //               .communityLinksRef
  //               .where('chatId', isEqualTo: messageData["chatId"])
  //               .limit(1)
  //               .get();

  //           final communityLink = communityLinkQuerySnapshot.docs.first.data();
  //           final link = communityLink['link'];
  //           sendMessage(
  //               messageContent:
  //                   "$link\n\nJoin store community for more products",
  //               notificationContent: "Group link",
  //               type: "Text",
  //               me: senderMe,
  //               chatData: existingChatDoc,
  //               userData: senderUserData,
  //               replyData: null,
  //               attachments: null);
  //         } catch (e) {
  //           print("SENDING LINK ERROR: $e");
  //         }
  //       }
  //     }

  //     Navigator.pushReplacement(
  //         CustomNotificationHandler.navigatorKey.currentContext!,
  //         MaterialPageRoute(builder: (context) {
  //       return ChatScreen(
  //         chatData: existingChatDoc,
  //         userData: userData,
  //         memberMapData: receiverData,
  //       );
  //     }));
  //   } else {
  //     await DbService()
  //         .updateChatDoc(
  //       id: id,
  //       uid: AuthService().currentUser!.uid,
  //       receiverId: receiverDocs.docs.first.id,
  //       name: memberName,
  //       logoURL: null,
  //       category: null,
  //       initiator: userData["fullName"],
  //       type: "Private",
  //       chatType: "Individual",
  //       isBroadcast: false,
  //       description: null,
  //       location: null,
  //       hasGroupOptions: false,
  //       status: "Active",
  //       dateAdded: DateTime.now(),
  //       dateUpdated: DateTime.now(),
  //     )
  //         .whenComplete(() async {
  //       final chatData = await DbService().chatsRefs.doc(id).get();

  //       final meQuerySnapshot = await DbService()
  //           .membersRef
  //           .where("chatId", isEqualTo: id)
  //           .where("uid", isEqualTo: AuthService().currentUser!.uid)
  //           .limit(1)
  //           .get();
  //       final me = meQuerySnapshot.docs.first;

  //       if (messageData != null) {
  //         sendMessage(
  //             messageContent: messageData["messageContent"],
  //             notificationContent: messageData["notificationContent"],
  //             type: messageData["type"],
  //             me: me,
  //             chatData: chatData,
  //             userData: userData,
  //             replyData: null,
  //             attachments: messageData["attachments"]);

  //         //Send link
  //         if (sendGroupLink) {
  //           final senderMeQuerySnapshot = await DbService()
  //               .membersRef
  //               .where("chatId", isEqualTo: id)
  //               .where("uid", isNotEqualTo: AuthService().currentUser!.uid)
  //               .limit(1)
  //               .get();
  //           final senderMe = senderMeQuerySnapshot.docs.first;
  //           final senderUserQuerySnapshot = await DbService()
  //               .usersRef
  //               .where("uid", isEqualTo: senderMe['uid'])
  //               .limit(1)
  //               .get();
  //           final senderUserData = senderUserQuerySnapshot.docs.first;
  //           final communityLinkQuerySnapshot = await DbService()
  //               .communityLinksRef
  //               .where('chatId', isEqualTo: messageData["chatId"])
  //               .limit(1)
  //               .get();
  //           final communityLink = communityLinkQuerySnapshot.docs.first.data();
  //           final link = communityLink['link'];
  //           sendMessage(
  //               messageContent:
  //                   "$link\n\nJoin store community for more products",
  //               notificationContent: "Group link",
  //               type: "Text",
  //               me: senderMe,
  //               chatData: chatData,
  //               userData: senderUserData,
  //               replyData: null,
  //               attachments: null);
  //         }
  //       }

  //       Navigator.pushReplacement(
  //           CustomNotificationHandler.navigatorKey.currentContext!,
  //           MaterialPageRoute(builder: (context) {
  //         return ChatScreen(
  //           chatData: chatData,
  //           userData: userData,
  //           memberMapData: receiverData,
  //         );
  //       }));
  //     });
  //   }
  // }

  static int roundToTwoDecimalPlaces(double value) {
    return int.parse(value.toStringAsFixed(0));
  }

  // static Future<String> getFormattedAudioDuration(String filePath) async {
  //   final player = AudioPlayer();
  //   try {
  //     await player.setFilePath(filePath);
  //     Duration? duration = player.duration;
  //     if (duration != null) {
  //       return formatDuration(duration);
  //     } else {
  //       return "0:00";
  //     }
  //   } catch (e) {
  //     return "0:00";
  //   } finally {
  //     player.dispose();
  //   }
  // }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  static bool isValidUrl({required String url}) {
    try {
      Uri uri = Uri.parse(url);
      // Check if the scheme (protocol) is valid (http or https)
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static Future<void> saveMapToSharedPreferences({
    required Map<String, dynamic> map,
    required String key,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert Map to JSON String
    String jsonString = jsonEncode(map);

    // Save the JSON string
    await prefs.setString(key, jsonString);
  }

  static Future<Map<String, dynamic>> getMapFromSharedPreferences({
    required String key,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string
    String? jsonString = prefs.getString(key);

    if (jsonString != null) {
      // Convert JSON String back to Map
      return jsonDecode(jsonString);
    } else {
      return {}; // Return empty map if no value is found
    }
  }

  static Future firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print("HANDLIG FIREBASE MESSAGE IN BACKGROUND: ${message.messageId}");
  }

  // Fetch the FCM token
  static Future<String?> getFCMToken() async {
    try {
      // Ensure Firebase is initialized
      final String? token = await FirebaseMessaging.instance.getToken();

      return token;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting FCM Token: $e");
      }
      return null;
    }
  }

  static Future<void> registerNotification() async {
    const storage = FlutterSecureStorage();
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Check if user is authenticated before proceeding
      // final currentUser = AuthService().currentUser;
      // if (currentUser == null) {
      //   if (kDebugMode) {
      //     print('No authenticated user found');
      //   }
      //   return;
      // }
      final userId = ''; // REPLACE WITH REAL USER ID WHEN INTEGRATING
      if (Platform.isIOS) {
        await _handleIOSNotifications(messaging, storage, userId);
      } else {
        await _handleAndroidNotifications(messaging, storage, userId);
      }

      // Setup token refresh listener
      _setupTokenRefreshListener(messaging, storage, userId);
    } catch (e) {
      if (kDebugMode) {
        print("Error in registerNotification: $e");
      }
      // Only rethrow if not running on simulator
      if (!(Platform.isIOS && await _isIOSSimulator(messaging))) {
        rethrow;
      }
    }
  }

  static Future<bool> _isIOSSimulator(FirebaseMessaging messaging) async {
    try {
      final apnsToken = await messaging.getAPNSToken();
      return apnsToken?.contains('simulator') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _handleIOSNotifications(
    FirebaseMessaging messaging,
    FlutterSecureStorage storage,
    String userId,
  ) async {
    // Enable auto initialization
    await messaging.setAutoInitEnabled(true);

    // Request permissions
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User has not accepted permissions');
      }
      return;
    }

    // Check for simulator
    if (await _isIOSSimulator(messaging)) {
      if (kDebugMode) {
        print("Running on iOS simulator - using mock FCM token");
      }
      const mockToken = 'simulator-fcm-token';
      await _updateToken(mockToken, storage, userId);
      return;
    }

    // Get real token for physical device
    await _getFCMTokenAndUpdate(messaging, storage, userId);
  }

  static Future<void> _handleAndroidNotifications(
    FirebaseMessaging messaging,
    FlutterSecureStorage storage,
    String userId,
  ) async {
    await _getFCMTokenAndUpdate(messaging, storage, userId);
  }

  static Future<void> _getFCMTokenAndUpdate(
    FirebaseMessaging messaging,
    FlutterSecureStorage storage,
    String userId,
  ) async {
    String? newToken;
    int tokenAttempts = 0;
    const maxAttempts = 3;
    print("GETTING NEW FCM TOKEN");
    // while (newToken == null && tokenAttempts < maxAttempts) {
    //   try {
    //     newToken = await messaging.getToken();
    //     if (newToken != null) {
    //       await _updateToken(newToken, storage, userId);
    //     }
    //     break;
    //   } catch (e) {
    //     if (kDebugMode) {
    //       print("Attempt ${tokenAttempts + 1} failed to get FCM token: $e");
    //     }
    //     await Future.delayed(const Duration(seconds: 2));
    //     tokenAttempts++;
    //   }
    // }

    try {
      newToken = await messaging.getToken();
      print("FCM TOKEN OBTAINED: $newToken");
      if (newToken != null) {
        await _updateToken(newToken, storage, userId);
      }
      // break;
    } catch (e) {
      if (kDebugMode) {
        print("Attempt ${tokenAttempts + 1} failed to get FCM token: $e");
      }
      await Future.delayed(const Duration(seconds: 2));
      tokenAttempts++;
    }

    if (newToken == null && !Platform.isIOS) {
      throw Exception("Failed to obtain FCM token after $maxAttempts attempts");
    }
  }

  static Future<void> _updateToken(
    String token,
    FlutterSecureStorage storage,
    String userId,
  ) async {
    try {
      // Store token in secure storage
      await storage.write(key: "notifToken", value: token);

      // Update Firestore with both old and new token management
      await addTokenToUser(token, userId);

      if (kDebugMode) {
        print('Token updated successfully: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating token: $e");
      }
      rethrow;
    }
  }

  /// Adds a new FCM token to the user's fcmTokens array if it doesn't already exist
  static Future<void> addTokenToUser(String token, String userId) async {
    try {
      final userDoc = await DbService().usersRef.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> currentTokens = userData['fcmTokens'] ?? [];

        // Convert to List<String> and check if token already exists
        List<String> tokens = currentTokens.cast<String>();

        if (!tokens.contains(token)) {
          tokens.add(token);
          await userDoc.reference.update({
            'fcmTokens': tokens,
            'notifToken':
                token, // Keep the old field for backward compatibility
          });
          if (kDebugMode) {
            print('Token added to fcmTokens array: $token');
          }
        } else {
          // Update the single token field for consistency
          await userDoc.reference.update({'notifToken': token});
          if (kDebugMode) {
            print('Token already exists in fcmTokens array: $token');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding token to user: $e");
      }
      rethrow;
    }
  }

  /// Removes a specific FCM token from the user's fcmTokens array
  static Future<void> removeTokenFromUser(String token, String userId) async {
    try {
      final userDoc = await DbService().usersRef.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> currentTokens = userData['fcmTokens'] ?? [];

        // Convert to List<String> and remove the token
        List<String> tokens = currentTokens.cast<String>();
        tokens.remove(token);

        await userDoc.reference.update({
          'fcmTokens': tokens,
          'notifToken': tokens.isNotEmpty
              ? tokens.last
              : null, // Keep the most recent token for backward compatibility
        });

        if (kDebugMode) {
          print('Token removed from fcmTokens array: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error removing token from user: $e");
      }
      rethrow;
    }
  }

  /// Removes the current device's FCM token from the user's fcmTokens array
  static Future<void> removeCurrentDeviceToken(String userId) async {
    try {
      const storage = FlutterSecureStorage();
      final currentToken = await storage.read(key: "notifToken");

      if (currentToken != null) {
        await removeTokenFromUser(currentToken, userId);
        // Remove from local storage as well
        await storage.delete(key: "notifToken");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error removing current device token: $e");
      }
      rethrow;
    }
  }

  /// Migrates existing users from single notifToken to fcmTokens array
  /// This should be called once during app initialization to migrate existing data
  static Future<void> migrateUserTokensToArray(String userId) async {
    try {
      final userDoc = await DbService().usersRef.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Check if migration is needed
        if (userData['fcmTokens'] == null ||
            (userData['fcmTokens'] as List).isEmpty) {
          List<String> tokens = [];

          // If there's an existing notifToken, add it to the array
          if (userData['notifToken'] != null) {
            tokens.add(userData['notifToken']);
          }

          // Initialize the fcmTokens field
          await userDoc.reference.update({'fcmTokens': tokens});

          if (kDebugMode) {
            print(
              'User $userId migrated to fcmTokens array with ${tokens.length} tokens',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error migrating user tokens: $e");
      }
    }
  }

  /// Gets all FCM tokens for a user (backward compatible)
  static Future<List<String>> getUserFCMTokens(String userId) async {
    try {
      final userDoc = await DbService().usersRef.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Get FCM tokens array
        List<dynamic> fcmTokensRaw = userData['fcmTokens'] ?? [];
        List<String> fcmTokens = fcmTokensRaw.cast<String>();

        // If no tokens in array but has old notifToken, use that
        if (fcmTokens.isEmpty && userData["notifToken"] != null) {
          fcmTokens = [userData["notifToken"]];
        }

        return fcmTokens;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("Error getting user FCM tokens: $e");
      }
      return [];
    }
  }

  static void _setupTokenRefreshListener(
    FirebaseMessaging messaging,
    FlutterSecureStorage storage,
    String userId,
  ) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        // Don't update if running on simulator
        if (Platform.isIOS && await _isIOSSimulator(messaging)) {
          return;
        }
        await _updateToken(newToken, storage, userId);
      } catch (e) {
        if (kDebugMode) {
          print("Error in token refresh listener: $e");
        }
      }
    });
  }

  static String cleanNumber(String input) {
    // Remove all commas and any trailing non-digit characters (e.g., ' km')
    String cleaned = input
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s?[a-zA-Z]*$'), '');
    return cleaned;
  }

  static List<dynamic> removeWordAndPrefixes({
    required List<dynamic> searchTerms,
    required String wordToRemove,
  }) {
    // Clean and normalize the word to remove
    String cleanedWord = wordToRemove
        .trim()
        .replaceAll(RegExp(r'[^\w\s]+$'), '')
        .toLowerCase();

    // Filter the search terms
    return searchTerms.where((term) {
      // Clean and normalize the term
      String cleanedTerm = term
          .trim()
          .replaceAll(RegExp(r'[^\w\s]+$'), '')
          .toLowerCase();

      // Skip empty terms
      if (cleanedTerm.isEmpty) {
        return true;
      }

      // Exclude the term if it is a prefix of the word to remove
      return !cleanedWord.startsWith(cleanedTerm);
    }).toList();
  }

  static Future<Map<String, dynamic>?> getUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('user_data'); // Get the JSON string
    if (jsonString != null) {
      return jsonDecode(jsonString); // Convert the JSON string back to a Map
    }
    return null; // Return null if no value is found
  }

  static String convertToTitleCase(String input) {
    // Replace underscores with spaces to handle both cases
    String normalizedInput = input.replaceAll('_', ' ');

    // Split the string into words
    List<String> words = normalizedInput.split(' ');

    // Capitalize the first letter of each word
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) return ''; // Handle empty strings
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    // Join the words back with a space
    return capitalizedWords.join(' ');
  }

  static Future<Map<String, dynamic>> downloadFileWithDio({
    required String fileUrl,
    required String fileName,
    required String token,
  }) async {
    try {
      // Create an instance of Dio
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      // Get the application documents directory (safe for storing user-created files)
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // Start the download
      await dio.download(fileUrl, filePath);

      debugPrint('File downloaded to $filePath');

      // Return success = true and the file path
      return {"success": true, "filePath": File(filePath)};
    } catch (e) {
      debugPrint('Error downloading file: $e');

      // Instead of rethrowing, return a map indicating failure
      return {
        "success": false,
        "filePath": null,
        "error": e.toString(), // Optionally include the error message
      };
    }
  }

  static DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else if (date is DateTime) {
      return date;
    } else {
      throw Exception('Unexpected date format: $date');
    }
  }

  static String formatLastSeen({DateTime? lastSeen}) {
    if (lastSeen == null) return "last seen unknown";

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    // Get midnight times for comparisons
    final midnight = DateTime(now.year, now.month, now.day);
    final yesterdayMidnight = midnight.subtract(const Duration(days: 1));
    final weekAgo = now.subtract(const Duration(days: 7));
    final yearStart = DateTime(now.year, 1, 1);

    // Formatters
    final timeFormat = DateFormat('h:mm a'); // e.g. 3:45 PM
    final dateFormat = DateFormat('MMM d'); // e.g. Jan 15
    final fullDateFormat = DateFormat('MMM d, y'); // e.g. Jan 15, 2023

    // Active now / Just now (less than a minute ago)
    if (difference.inSeconds < 60) {
      return "online";
    }

    // Minutes ago (less than an hour)
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return "last seen ${minutes == 1 ? 'a minute' : '$minutes minutes'} ago";
    }

    // Hours ago (less than 4 hours)
    if (difference.inHours < 4) {
      final hours = difference.inHours;
      return "last seen ${hours == 1 ? 'an hour' : '$hours hours'} ago";
    }

    // Today
    if (lastSeen!.isAfter(midnight)) {
      return "last seen today at ${timeFormat.format(lastSeen!)}";
    }

    // Yesterday
    if (lastSeen!.isAfter(yesterdayMidnight)) {
      return "last seen yesterday at ${timeFormat.format(lastSeen!)}";
    }

    // Within last week
    if (lastSeen!.isAfter(weekAgo)) {
      return "last seen on ${DateFormat('EEEE').format(lastSeen!)} at ${timeFormat.format(lastSeen!)}";
    }

    // This year
    if (lastSeen!.isAfter(yearStart)) {
      return "last seen on ${dateFormat.format(lastSeen!)}";
    }

    // Previous years
    return "last seen on ${fullDateFormat.format(lastSeen!)}";
  }

  static String getSocialNetworkIcon(String url) {
    // Convert URL to lowercase for case-insensitive matching
    final lowerUrl = url.toLowerCase();

    // Remove protocol and www if present for cleaner matching
    String cleanUrl = lowerUrl
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'^www\.'), '');

    // Check for each social network
    if (cleanUrl.contains('whatsapp.com') ||
        cleanUrl.contains('wa.me') ||
        cleanUrl.contains('api.whatsapp.com')) {
      return 'assets/icons/whatsapp.svg';
    }

    if (cleanUrl.contains('linkedin.com')) {
      return 'assets/icons/linkedin.svg';
    }

    if (cleanUrl.contains('twitter.com') || cleanUrl.contains('x.com')) {
      return 'assets/icons/x.svg';
    }

    if (cleanUrl.contains('instagram.com')) {
      return 'assets/icons/instagram.svg';
    }

    if (cleanUrl.contains('facebook.com') ||
        cleanUrl.contains('fb.com') ||
        cleanUrl.contains('m.facebook.com')) {
      return 'assets/icons/facebook.svg';
    }

    if (cleanUrl.contains('youtube.com') || cleanUrl.contains('youtu.be')) {
      return 'assets/icons/youtube.svg';
    }

    if (cleanUrl.contains('tiktok.com') || cleanUrl.contains('vm.tiktok.com')) {
      return 'assets/icons/tiktok.svg';
    }

    // Default icon for unrecognized URLs
    return 'assets/icons/link.svg';
  }

  /// Displays a non-dismissible loading dialog with a custom message.
  static void showLoadingDialog({
    required BuildContext context,
    String message = "Loading...",
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must not dismiss it by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
          ),
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Text(message.tr),
            ],
          ),
        );
      },
    );
  }


  // static String formatTimeAgo(DateTime dateTime) {
  //    final difference = DateTime.now().difference(dateTime);
  //
  //    if (difference.inDays > 365) {
  //      return '${(difference.inDays / 365).floor()}y';
  //    } else if (difference.inDays > 30) {
  //      return '${(difference.inDays / 30).floor()}mo';
  //    } else if (difference.inDays > 0) {
  //      return '${difference.inDays}d';
  //    } else if (difference.inHours > 0) {
  //      return '${difference.inHours}h';
  //    } else if (difference.inMinutes > 0) {
  //      return '${difference.inMinutes}m';
  //    } else {
  //      return 'just now';
  //    }
  //  }

  //Work on it to make it reusable
  // void showConfirmationDialog(
  //     {required BuildContext context,
  //     required String selectedBranch,
  //     required String action,
  //     required String title,
  //     required String content,
  //     required Function onConfirm}) async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Create Link"),
  //         content: Text(
  //             "Do you want to create a link for $selectedBranch branch: ?"),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text(
  //               "Cancel",
  //               style: TextStyle(color: Colors.red),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text("Create"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               createLink(selectedBranch: selectedBranch);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
