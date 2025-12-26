import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kiliride/widgets/snack_bar.dart' as Funcs;

class PermissionService {
  /// MODIFIED: This function now requires a BuildContext to show the dialog.
  static Future<bool> handleLocationPermission(BuildContext context) async {
    try {
      // Is GPS/service on?
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Funcs.showSnackBar(
          context,
              'Location services are disabled. Please enable them to continue.',
        );
        return false;
      }

      // What’s our current permission state?
      var permission = await Geolocator.checkPermission();

      // If we’ve never requested (denied or undetermined), show our dialog FIRST:
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        // --- NEW: SHOW OUR CUSTOM DISCLOSURE ---
        // We must show our dialog *before* the system one.
        // We also check if the context is still valid before showing the dialog
        if (!context.mounted) return false;
        final bool didAcceptDisclosure = await _showLocationDisclosure(context);

        // If user pressed "Decline" on our dialog, just stop.
        if (!didAcceptDisclosure) {
          Funcs.showSnackBar(
            context, 'Location permission is required to find rides.',
          );
          return false;
        }
        // --- END OF NEW CODE ---

        // If they pressed "Allow", NOW we show the system request.
        permission = await Geolocator.requestPermission();
      }

      // Handle outright denials
      if (permission == LocationPermission.denied) {
        Funcs.showSnackBar(context, 'Location permissions are denied.');
        return false;
      }
      if (permission == LocationPermission.deniedForever) {
        Funcs.showSnackBar(
          context,
              'Location permissions are permanently denied. '
              'Please go into Settings to enable them.',
        );
        return false;
      }

      // Finally, check for allowed states
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }

      // (Just in case something weird happened)
      Funcs.showSnackBar(
        context, 'Unexpected location permission status: $permission',
      );
      return false;
    } catch (e) {
      Funcs.showSnackBar(context, 'Error checking location permission:\n$e');
      return false;
    }
  }

  /// --- NEW: THE PROMINENT DISCLOSURE DIALOG ---
  /// This is the dialog Google requires.
  static Future<bool> _showLocationDisclosure(BuildContext context) async {
    // IMPORTANT: Replace "Sasa Chat" with your app's actual name
    const String appName = "Sasa Ride";

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // User must make a choice
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Location Permission Required'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'To find drivers near you, track your ride, and calculate fares, $appName collects location data.',
                    ),
                    SizedBox(height: 10),
                    Text(
                      'This is used even when the app is closed or not in use during a ride.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Decline'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false); // User declined
                  },
                ),
                TextButton(
                  child: const Text('Allow'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true); // User allowed
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed for any reason
  }
  // --- END OF NEW FUNCTION ---

  /// This function is unchanged, but left in for completeness.
  static Future<void> handleNotificationPermission() async {
    final isAllowedToSendNotification = await AwesomeNotifications()
        .isNotificationAllowed();
    if (!isAllowedToSendNotification) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }
}
