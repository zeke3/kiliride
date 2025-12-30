import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kiliride/components/place_search_field.dart';
import 'package:kiliride/components/text_field_title.dart';
import 'package:kiliride/models/driver.model.dart';
import 'package:kiliride/models/vehicle.model.dart';
import 'package:kiliride/shared/constants.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:kiliride/components/loading.dart';
import 'package:kiliride/components/file_upload_button.dart';
import 'package:path/path.dart' as path;
import 'package:kiliride/services/db.service.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';

class BecomeADriverScreen extends StatefulWidget {
  final DocumentSnapshot? userData;
  final int initialStep;
  final String? preselectedDriverType; // Optional: Lock selection
  final String? invitationId; // NEW: Track invitation ID

  const BecomeADriverScreen({
    super.key,
    required this.userData,
    this.initialStep = 0,
    this.preselectedDriverType,
    this.invitationId,
  });

  @override
  _BecomeADriverScreenState createState() => _BecomeADriverScreenState();
}

class _BecomeADriverScreenState extends State<BecomeADriverScreen> {
  late final PageController _pageController;
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _vehicleInfoFormKey = GlobalKey<FormState>();

  int _currentPageIndex = 0;
  bool _isSubmitting = false;
  bool _isLoading = false;

  // Existing driver data for editing
  DriverModel? _existingDriver;
  DriverVehicle? _existingVehicle;

  // Personal Info Controllers
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _nidaController = TextEditingController();
  final _licenseController = TextEditingController();
  PhoneNumber? _transactionPhoneNumber;
  String? _selectedGender;
  String? _selectedDriverType;

  // Vehicle Info Controllers
  String? _selectedVehicleType;
  String? _selectedMakeModel;
  final _regNumberController = TextEditingController();
  final _otherMakeModelController =
      TextEditingController(); // For "Other" option
  String? _selectedInsuranceType;
  String? _selectedVehicleColor;

  // Vehicle color options with hex values for visual display
  final Map<String, Color> _vehicleColors = {
    'White': const Color(0xFFFFFFFF),
    'Black': const Color(0xFF000000),
    'Silver': const Color(0xFFC0C0C0),
    'Gray': const Color(0xFF808080),
    'Red': const Color(0xFFDC143C),
    'Blue': const Color(0xFF1E90FF),
    'Green': const Color(0xFF228B22),
    'Yellow': const Color(0xFFFFD700),
    'Orange': const Color(0xFFFF8C00),
    'Brown': const Color(0xFF8B4513),
  };

  // State for holding picked files
  File? _nidaFrontFile,
      _nidaBackFile,
      _licenseFrontFile,
      _licenseBackFile,
      _selfieFile;
  File? _legalPapersFile,
      _insuranceDocsFile,
      _frontViewFile,
      _sideViewFile,
      _rearViewFile,
      _otherDocFile;

  // Vehicle types and models to include delivery options
  final List<String> _rideVehicleTypes = ['Sasa', 'Bajaj', 'Boda'];
  final List<String> _deliveryVehicleTypes = [
    'Boda Send',
    'Guta Send',
    'Carrier Send',
  ];

  final Map<String, List<String>> _vehicleMakesAndModels = {
    'Sasa': [
      'Toyota IST',
      'Toyota Passo',
      'Toyota Vitz',
      'Toyota Raum',
      'Suzuki Swift',
      'Suzuki Alto',
      'Honda Fit',
      'Nissan March',
      'Nissan Note',
      'Other',
    ],
    'Bajaj': ['Bajaj RE', 'Bajaj Maxima', 'TVS King', 'Piaggio Ape', 'Other'],
    'Boda': [
      'Boxer BM 150',
      'TVS Star HLX',
      'Honda Ace',
      'Haojue',
      'Sanlg',
      'Other',
    ],
    'Boda Send': [
      'Boxer BM 150',
      'TVS Star HLX',
      'Honda Ace',
      'Haojue',
      'Sanlg',
      'Other',
    ],
    'Guta Send': ['TVS King Cargo', 'Piaggio Ape Cargo', 'Other'],
    'Carrier Send': ['Suzuki Carry', 'Daihatsu Hijet', 'Other'],
  };
  List<String> _currentVehicleTypes = [];
  List<String> _currentModels = [];

  DriverVehicle? _newVehicleData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialStep);
    _currentPageIndex = widget.initialStep;

    _pageController.addListener(() {
      if (mounted && _pageController.page!.round() != _currentPageIndex) {
        setState(() {
          _currentPageIndex = _pageController.page!.round();
        });
      }
    });
    // _loadInitialData();
  }

  void _updateVehicleTypeList() {
    setState(() {
      _selectedVehicleType = null;
      _selectedMakeModel = null;
      if (_selectedDriverType == 'Normal Ride') {
        _currentVehicleTypes = _rideVehicleTypes;
      } else if (_selectedDriverType == 'Delivery') {
        _currentVehicleTypes = _deliveryVehicleTypes;
      } else {
        _currentVehicleTypes = [];
      }
    });
  }

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (widget.preselectedDriverType != null) {
      _selectedDriverType = widget.preselectedDriverType;
      _updateVehicleTypeList();
    }

    _fullNameController.text =
        widget.userData!['fullName'] ?? user.displayName ?? '';
    _selectedGender = widget.userData!['gender'];

    final initialPhoneStr = widget.userData!['phoneNumber'] ?? user.phoneNumber;
    if (initialPhoneStr != null && initialPhoneStr.isNotEmpty) {
      try {
        _transactionPhoneNumber = PhoneNumber.parse(initialPhoneStr);
      } catch (e) {
        if (kDebugMode) print("Could not parse initial phone number: $e");
        _transactionPhoneNumber = PhoneNumber(isoCode: IsoCode.TZ, nsn: '');
      }
    } else {
      _transactionPhoneNumber = PhoneNumber(isoCode: IsoCode.TZ, nsn: '');
    }

    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(user.uid)
          .get();

      if (driverDoc.exists) {
        _existingDriver = DriverModel.fromMap(driverDoc.data()!, driverDoc.id);

        _fullNameController.text = _existingDriver!.fullName;
        _addressController.text = _existingDriver!.residentialAddress;
        _nidaController.text = _existingDriver!.nidaNumber;
        _licenseController.text = _existingDriver!.licenseNumber;
        _selectedGender = _existingDriver!.gender;
        _selectedDriverType = _existingDriver!.driverType;
        _updateVehicleTypeList(); // Update vehicle list based on loaded driver type

        if (_existingDriver!.transactionPhone.isNotEmpty) {
          try {
            _transactionPhoneNumber = PhoneNumber.parse(
              _existingDriver!.transactionPhone,
            );
          } catch (e) {
            if (kDebugMode) {
              print("Could not parse existing driver phone number: $e");
            }
          }
        }

        if (_selectedDriverType != 'Special Hire') {
          final vehicleQuery = await FirebaseFirestore.instance
              .collection('vehicles')
              .where('driverId', isEqualTo: user.uid)
              .limit(1)
              .get();

          if (vehicleQuery.docs.isNotEmpty) {
            final vehicleDoc = vehicleQuery.docs.first;
            _existingVehicle = DriverVehicle.fromMap(
              vehicleDoc.data(),
              vehicleDoc.id,
            );
            _selectedVehicleType = _existingVehicle!.vehicleType;

            if (_selectedVehicleType != null &&
                _vehicleMakesAndModels.containsKey(_selectedVehicleType)) {
              _currentModels = _vehicleMakesAndModels[_selectedVehicleType]!;
            }

            final existingModel = _existingVehicle!.makeAndModel;
            if (_currentModels.contains(existingModel)) {
              _selectedMakeModel = existingModel;
            } else {
              _selectedMakeModel = 'Other';
              _otherMakeModelController.text = existingModel;
            }

            _regNumberController.text =
                _existingVehicle!.registrationNumber ?? '';
            _selectedInsuranceType = _existingVehicle!.insuranceType;
            // Don't set color if it's "N/A" (old default value)
            _selectedVehicleColor = _existingVehicle!.color == "N/A"
                ? null
                : _existingVehicle!.color;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error loading initial driver data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _nidaController.dispose();
    _licenseController.dispose();
    _regNumberController.dispose();
    _otherMakeModelController.dispose();
    super.dispose();
  }

  Future<String?> _uploadFile(File? file, String storagePath) async {
    if (file == null) return null;
    try {
      final fileName = path.basename(file.path);
      final ref = FirebaseStorage.instance.ref().child(
        '$storagePath/$fileName',
      );
      return await (await ref.putFile(file)).ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) print("File upload error: $e");
      return null;
    }
  }

  Future<void> _submitApplication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Funcs.showSnackBar(
        message: "Error: You must be logged in.",
        isSuccess: false,
      );
      return;
    }

    if (_currentPageIndex == 0 &&
        !_personalInfoFormKey.currentState!.validate()) {
      return;
    }
    if (_currentPageIndex == 1 &&
        !_vehicleInfoFormKey.currentState!.validate()) {
      return;
    }

    // --- NEW: Confirmation for Role Change ---
    if (_existingDriver != null &&
        _selectedDriverType != _existingDriver!.driverType) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Change Driver Role?'.tr),
          content: Text(
            'Are you sure you want to switch from ${_existingDriver!.driverType} to $_selectedDriverType? This may affect your vehicle requirements and pending bookings.'
                .tr,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Confirm'.tr),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }
    // --- END NEW ---

    // Validate vehicle images are mandatory
    if (_currentPageIndex == 1 &&
        (_selectedDriverType == 'Normal Ride' ||
            _selectedDriverType == 'Delivery')) {
      if (_frontViewFile == null &&
          (_existingVehicle?.frontImageUrl == null ||
              _existingVehicle!.frontImageUrl.isEmpty)) {
        Funcs.showSnackBar(
          message: "Please upload front view image of your vehicle",
          isSuccess: false,
        );
        return;
      }
      if (_sideViewFile == null &&
          (_existingVehicle?.sideImageUrl == null ||
              _existingVehicle!.sideImageUrl.isEmpty)) {
        Funcs.showSnackBar(
          message: "Please upload side view image of your vehicle",
          isSuccess: false,
        );
        return;
      }
      if (_rearViewFile == null &&
          (_existingVehicle?.rearImageUrl == null ||
              _existingVehicle!.rearImageUrl.isEmpty)) {
        Funcs.showSnackBar(
          message: "Please upload rear view image of your vehicle",
          isSuccess: false,
        );
        return;
      }

      // Validate Inside Car image (only if not Boda)
      final bool isBoda =
          _selectedVehicleType?.toLowerCase().contains('boda') ?? false;
      if (!isBoda) {
        if (_otherDocFile == null &&
            (_existingVehicle?.otherImageUrl == null ||
                _existingVehicle!.otherImageUrl!.isEmpty)) {
          Funcs.showSnackBar(
            message: "Please upload interior view image of your vehicle",
            isSuccess: false,
          );
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    Funcs.showLoadingDialog(
      context: context,
      message: _existingDriver != null
          ? 'Updating information...'
          : 'Submitting application...',
    );

    DriverVehicle? vehicleData;

    try {
      Future<String?> uploadOrKeepUrl(
        File? file,
        String? existingUrl,
        String path,
      ) async {
        return file != null ? await _uploadFile(file, path) : existingUrl;
      }

      String finalMakeModelForDriver = _selectedMakeModel ?? '';
      if (_selectedDriverType != 'Special Hire' &&
          _selectedMakeModel == 'Other') {
        finalMakeModelForDriver = _otherMakeModelController.text.trim();
      } else if (_selectedDriverType != 'Special Hire') {
        finalMakeModelForDriver = _selectedMakeModel!;
      }

      final userId = user.uid;
      final personalDocsPath = 'driver_documents/$userId';
      final personalUploads = await Future.wait([
        uploadOrKeepUrl(
          _nidaFrontFile,
          _existingDriver?.nidaFrontUrl,
          personalDocsPath,
        ),
        uploadOrKeepUrl(
          _nidaBackFile,
          _existingDriver?.nidaBackUrl,
          personalDocsPath,
        ),
        uploadOrKeepUrl(
          _licenseFrontFile,
          _existingDriver?.licenseFrontUrl,
          personalDocsPath,
        ),
        uploadOrKeepUrl(
          _licenseBackFile,
          _existingDriver?.licenseBackUrl,
          personalDocsPath,
        ),
        uploadOrKeepUrl(
          _selfieFile,
          _existingDriver?.selfieImageUrl,
          personalDocsPath,
        ),
      ]);

      final List<String> driverSearchTerms = DbService().generateSearchTerms(
        terms: [
          _fullNameController.text,
          finalMakeModelForDriver,
          _selectedVehicleType ?? '',
        ],
      );

      final driverData = DriverModel(
        id: userId,
        fullName: _fullNameController.text.trim(),
        gender: _selectedGender!,
        residentialAddress: _addressController.text.trim(),
        nidaNumber: _nidaController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        transactionPhone: _transactionPhoneNumber!.international,
        // Reset status to pending_approval if previously disapproved and resubmitting
        status: _existingDriver?.status == 'disapproved'
            ? 'pending_approval'
            : (_existingDriver?.status ?? 'pending_approval'),
        // Clear rejection reason on resubmission
        rejectionReason: null,
        isOnline: _existingDriver?.isOnline ?? false,
        driverType: _selectedDriverType!,
        createdAt: _existingDriver?.createdAt ?? Timestamp.now(),
        isOwner:
            _selectedDriverType !=
            'Special Hire', // Set to true for owners (Normal/Delivery)
        nidaFrontUrl: personalUploads[0] ?? '',
        nidaBackUrl: personalUploads[1] ?? '',
        licenseFrontUrl: personalUploads[2] ?? '',
        licenseBackUrl: personalUploads[3] ?? '',
        selfieImageUrl: personalUploads[4] ?? '',
        searchTerms: driverSearchTerms,
      );

      // Get the map from the model
      final Map<String, dynamic> driverDataMap = driverData.toMap();

      // Add the specific vehicleType (e.g., "Boda", "Sasa") for querying
      if (_selectedDriverType == 'Normal Ride' ||
          _selectedDriverType == 'Delivery') {
        // _selectedVehicleType will be "Sasa", "Boda Send", etc.
        driverDataMap['vehicleType'] = _selectedVehicleType;
      } else {
        // Explicitly set to null if they are Special Hire
        driverDataMap['vehicleType'] = null;
      }

      final batch = FirebaseFirestore.instance.batch();
      final driverDocRef = FirebaseFirestore.instance
          .collection('drivers')
          .doc(userId);

      if (_existingDriver != null) {
        // Use the modified map
        batch.update(driverDocRef, driverDataMap);
      } else {
        // Use the modified map
        batch.set(driverDocRef, driverDataMap);
      }

      // updating user full name to user doc from become driver form

      // 1. Get a reference to the user's document in the 'users' collection
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      // 2. Get the new full name
      final String newFullName = _fullNameController.text.trim();

      // 3. Get existing data from the widget's userData to rebuild search terms
      //    (This ensures your search terms in the 'users' doc stay accurate)
      final String? existingEmail = widget.userData!['email'];
      final String? existingPhone = widget.userData!['phoneNumber'];
      final String? existingRole = widget.userData!['role'];

      // 4. Generate the new search terms for the 'users' doc
      List<String> userSearchTermsList = [newFullName];
      if (existingEmail != null) userSearchTermsList.add(existingEmail);
      if (existingPhone != null) userSearchTermsList.add(existingPhone);
      if (existingRole != null) userSearchTermsList.add(existingRole);

      final List<String> userSearchTerms = DbService().generateSearchTerms(
        terms: userSearchTermsList,
      );

      // 5. Add the update operation to the same batch
      batch.update(userDocRef, {
        'fullName': newFullName,
        'searchTerms': userSearchTerms,
        'dateUpdated': FieldValue.serverTimestamp(),
      });

      // updating user full name to user doc from become driver form/

      if (_selectedDriverType == 'Normal Ride' ||
          _selectedDriverType == 'Delivery') {
        String finalMakeModel = _selectedMakeModel!;
        if (_selectedMakeModel == 'Other') {
          finalMakeModel = _otherMakeModelController.text.trim();
        }

        final vehicleDocsPath = 'vehicle_documents/$userId';
        final vehicleUploads = await Future.wait([
          uploadOrKeepUrl(
            _legalPapersFile,
            _existingVehicle?.legalPapersUrl,
            vehicleDocsPath,
          ),
          uploadOrKeepUrl(
            _insuranceDocsFile,
            _existingVehicle?.insuranceDocsUrl,
            vehicleDocsPath,
          ),
          uploadOrKeepUrl(
            _frontViewFile,
            _existingVehicle?.frontImageUrl,
            vehicleDocsPath,
          ),
          uploadOrKeepUrl(
            _sideViewFile,
            _existingVehicle?.sideImageUrl,
            vehicleDocsPath,
          ),
          uploadOrKeepUrl(
            _rearViewFile,
            _existingVehicle?.rearImageUrl,
            vehicleDocsPath,
          ),
          uploadOrKeepUrl(
            _otherDocFile,
            _existingVehicle?.otherImageUrl,
            vehicleDocsPath,
          ),
        ]);

        final List<String> vehicleSearchTerms = DbService().generateSearchTerms(
          terms: [
            finalMakeModel,
            _selectedVehicleType!,
            _regNumberController.text,
          ],
        );

        vehicleData = DriverVehicle(
          id: _existingVehicle?.id,
          driverId: userId,
          vehicleType: _selectedVehicleType!,
          makeAndModel: finalMakeModel,
          registrationNumber: _regNumberController.text.trim(),
          insuranceType: _selectedInsuranceType!,
          legalPapersUrl: vehicleUploads[0] ?? '',
          insuranceDocsUrl: vehicleUploads[1] ?? '',
          frontImageUrl: vehicleUploads[2] ?? '',
          sideImageUrl: vehicleUploads[3] ?? '',
          rearImageUrl: vehicleUploads[4] ?? '',
          otherImageUrl: vehicleUploads[5],
          hireType: _selectedDriverType!, // Use the selected driver type
          createdAt: _existingVehicle?.createdAt ?? Timestamp.now(),
          vehicleName: finalMakeModel,
          seats: _selectedVehicleType == 'Sasa'
              ? 4
              : _selectedVehicleType == 'Bajaj'
              ? 3
              : 1,
          fuelType: 'Petrol',
          features: _existingVehicle?.features ?? [],
          basePrice: null,
          regionOfOperation: '',
          availabilityDays: [],
          searchTerms: vehicleSearchTerms,
          serviceTypes: [], // Normal drivers don't use service types yet
          booked: false,
          color: _selectedVehicleColor,
        );

        DocumentReference vehicleDocRef;
        if (_existingVehicle != null) {
          vehicleDocRef = FirebaseFirestore.instance
              .collection('vehicles')
              .doc(_existingVehicle!.id);
          batch.update(vehicleDocRef, vehicleData.toMap());

          setState(() {
            _newVehicleData = vehicleData;
          });
        } else {
          vehicleDocRef = FirebaseFirestore.instance
              .collection('vehicles')
              .doc();
          batch.set(vehicleDocRef, vehicleData.toMap());
        }
      } else if (_selectedDriverType == 'Special Hire' &&
          _existingVehicle != null) {
        batch.delete(
          FirebaseFirestore.instance
              .collection('vehicles')
              .doc(_existingVehicle!.id),
        );
      }

      await batch.commit();

      // Update invitation status if applicable
      if (widget.invitationId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('driver_invitations')
              .doc(widget.invitationId)
              .update({
                'status': 'accepted',
                'respondedAt': Timestamp.now(),
                'linkedDriverId': user.uid,
              });
          if (kDebugMode) {
            print('Invitation ${widget.invitationId} marked as accepted');
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error updating invitation status: $e");
          }
          // Don't fail the whole submission if invitation update fails
        }
      }

      if (mounted) Navigator.pop(context);

      Funcs.showSnackBar(
        message: _existingDriver != null
            ? 'Information updated successfully!'
            : 'Application submitted successfully!',
        isSuccess: true,
      );
      if (mounted) Navigator.pop(context, _newVehicleData);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      Funcs.showSnackBar(message: 'Submission failed: $e', isSuccess: false);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onNavigationButtonPressed() {
    if (_currentPageIndex == 0) {
      if (_personalInfoFormKey.currentState!.validate()) {
        if (_selectedDriverType != 'Special Hire') {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        } else {
          _submitApplication();
        }
      }
    } else if (_currentPageIndex == 1) {
      _submitApplication();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final showVehicleForm =
        _selectedDriverType == 'Normal Ride' ||
        _selectedDriverType == 'Delivery';
    final buttonText =
        ((_currentPageIndex == 0 && showVehicleForm)
                ? 'Next'
                : (_existingDriver != null
                      ? 'Update Information'
                      : 'Submit Application'))
            .tr;

    return Scaffold(
      backgroundColor: AppStyle.appColor(context),
      body: Container(
        color: AppStyle.secondaryColor(context),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: AppStyle.primaryColor(context),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppStyle.appRadius),
                      bottomRight: Radius.circular(AppStyle.appRadius),
                    ),
                    image: const DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: AssetImage(
                        "assets/img/driver_register_pattern.png",
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 120,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: AppStyle.secondaryColor(context).withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppStyle.appRadius),
                      bottomRight: Radius.circular(AppStyle.appRadius),
                    ),
                  ),
                  child: AppBar(
                    foregroundColor: Colors.white,
                    leading: IconButton(
                      onPressed: () {
                        if (_currentPageIndex == 0 ||
                            _currentPageIndex == widget.initialStep) {
                          Navigator.pop(context);
                        } else {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_currentPageIndex == 0
                                  ? 'Personal Information'
                                  : 'Vehicle Information')
                              .tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppStyle.appFontSizeLG,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppStyle.appGap),
                        Text(
                          (_currentPageIndex == 0
                                  ? "Tell us a bit about yourself"
                                  : "Provide details about your vehicle")
                              .tr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: AppStyle.appFontSizeXSM,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Rejection reason alert for disapproved drivers
            if (_existingDriver?.status == 'disapproved' &&
                _existingDriver?.rejectionReason != null)
              Container(
                margin: const EdgeInsets.all(AppStyle.appPadding),
                padding: const EdgeInsets.all(AppStyle.appPadding),
                decoration: BoxDecoration(
                  color: AppStyle.errorColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppStyle.appRadius),
                  border: Border.all(
                    color: AppStyle.errorColor(context),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppStyle.errorColor(context),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Application Needs Corrections'.tr,
                            style: TextStyle(
                              fontSize: AppStyle.appFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppStyle.errorColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rejection Reason:'.tr,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSizeSM,
                        fontWeight: FontWeight.w600,
                        color: AppStyle.textColored(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _existingDriver!.rejectionReason!,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSizeSM,
                        color: AppStyle.textColored(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppStyle.successColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppStyle.successColor(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please update the required information and resubmit your application.'
                                  .tr,
                              style: TextStyle(
                                fontSize: AppStyle.appFontSizeXSM,
                                color: AppStyle.textColored(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppStyle.appColor(context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppStyle.appRadiusLG),
                    topRight: Radius.circular(AppStyle.appRadiusLG),
                  ),
                ),
                child: _isLoading
                    ? const Center(child: Loading())
                    : PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildPersonalInfoForm(),
                          if (showVehicleForm) _buildVehicleInfoForm(),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppStyle.appPadding),
          child: SizedBox(
            height: AppStyle.buttonHeight,
            child: ElevatedButton(
              onPressed: _isSubmitting || _isLoading
                  ? null
                  : _onNavigationButtonPressed,
              style: AppStyle.elevatedButtonStyle(context).copyWith(
                backgroundColor: WidgetStateProperty.all<Color>(
                  AppStyle.primaryColor(context),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    // LOGIC TO DYNAMICALLY SET DRIVER TYPE OPTIONS
    List<String> getDriverTypeOptions() {
      // New driver registration: show all primary options.
      if (_existingDriver == null) {
        // return ['Normal Ride', 'Delivery', 'Special Hire'];
        return ['Normal Ride', 'Special Hire'];
      }
      // Edit mode for an existing driver.
      // If they are already a Special Hire driver, they can't change their type.
      if (_existingDriver!.driverType == 'Special Hire') {
        return ['Special Hire'];
      }
      // Otherwise (Normal Ride/Delivery), they can switch between those two,
      // but cannot become a Special Hire driver from this screen.
      // return ['Normal Ride', 'Delivery'];
      return ['Normal Ride'];
    }

    final driverTypeOptions = getDriverTypeOptions();

    return Form(
      key: _personalInfoFormKey,
      child: ListView(
        padding: const EdgeInsets.all(AppStyle.appPadding),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Driver Type"),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDriverType,
                  decoration: const InputDecoration(
                    hintText: 'Select your driver type',
                  ),
                  // Disable if locked
                  onChanged: widget.preselectedDriverType != null
                      ? null
                      : (v) {
                          if (v != _selectedDriverType) {
                            setState(() {
                              _selectedDriverType = v;
                              _updateVehicleTypeList();
                            });
                          }
                        },
                  items: driverTypeOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Full Name"),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Gender"),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    hintText: 'Select your gender',
                  ),
                  items: ['Male', 'Female']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGender = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Location (Residential Address)"),
                PlaceSearchField(
                  title: "Residential Address",
                  controller: _addressController,
                  locationLat: -6.8,
                  locationLng: 39.28,
                  locationRadius: 50000,
                  historyCacheKey: "driver_location",
                  googleApiKey: googleMapApiKey,
                  onPlaceSelected: (Place value) {
                    setState(() {
                      _addressController.text = value.mainText;
                    });
                    if (kDebugMode) {
                      print(value.latitude);
                    }
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Required".tr;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Phone number"),
                PhoneFormField(
                  initialValue: _transactionPhoneNumber,
                  decoration: const InputDecoration(hintText: '712 345 678'),
                  countrySelectorNavigator:
                      const CountrySelectorNavigator.page(),
                  validator: PhoneValidator.compose([
                    PhoneValidator.required(context),
                    PhoneValidator.validMobile(context),
                  ]),
                  onChanged: (newNumber) {
                    _transactionPhoneNumber = newNumber;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "NIDA Number"),
                TextFormField(
                  controller: _nidaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(20),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Enter NIDA number',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length != 20) return 'NIDA number must be 20 digits';
                    return null;
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "License Number"),
                TextFormField(
                  controller: _licenseController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Enter license number',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length != 10) {
                      return 'License number must be 10 digits';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Upload License"),
                FileUploadButtonComp(
                  label: 'Upload (Front)',
                  localFile: _licenseFrontFile,
                  existingFileUrl: _existingDriver?.licenseFrontUrl,
                  onFilePicked: (file) =>
                      setState(() => _licenseFrontFile = file),
                ),
                FileUploadButtonComp(
                  label: 'Upload (Back)',
                  localFile: _licenseBackFile,
                  existingFileUrl: _existingDriver?.licenseBackUrl,
                  onFilePicked: (file) =>
                      setState(() => _licenseBackFile = file),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Your photo (Selfie)"),
                FileUploadButtonComp(
                  label: 'Upload (Selfie)',
                  localFile: _selfieFile,
                  existingFileUrl: _existingDriver?.selfieImageUrl,
                  onFilePicked: (file) => setState(() => _selfieFile = file),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoForm() {
    return Form(
      key: _vehicleInfoFormKey,
      child: ListView(
        padding: const EdgeInsets.all(AppStyle.appPadding),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Vehicle Type"),
                DropdownButtonFormField<String>(
                  initialValue: _selectedVehicleType,
                  decoration: const InputDecoration(
                    hintText: 'Select vehicle type',
                  ),
                  items: _currentVehicleTypes
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedVehicleType = v;
                      _selectedMakeModel = null;
                      _otherMakeModelController.clear();
                      _currentModels = _vehicleMakesAndModels[v] ?? [];
                    });
                  },
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Make & Model"),
                DropdownButtonFormField<String>(
                  initialValue: _selectedMakeModel,
                  decoration: const InputDecoration(
                    hintText: 'Select make & model',
                  ),
                  items: _currentModels
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: _selectedVehicleType == null
                      ? null
                      : (v) => setState(() => _selectedMakeModel = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ],
            ),
          ),
          if (_selectedMakeModel == 'Other')
            Padding(
              padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextFieldTitle(value: "Specify Make & Model"),
                  TextFormField(
                    controller: _otherMakeModelController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., TVS Apache',
                    ),
                    validator: (v) {
                      if (_selectedMakeModel == 'Other' &&
                          (v == null || v.isEmpty)) {
                        return 'Please specify the model';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Registration Number"),
                TextFormField(
                  controller: _regNumberController,
                  inputFormatters: [
                    // Only allow letters, numbers, and spaces
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                    // Force uppercase
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      );
                    }),
                  ],
                  decoration: const InputDecoration(hintText: 'e.g. T 123 ABC'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    // Additional check for invalid characters (emojis, symbols, etc.)
                    if (!RegExp(r'^[A-Z0-9 ]+$').hasMatch(v)) {
                      return 'Only letters, numbers, and spaces allowed';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Vehicle Color"),
                DropdownButtonFormField<String>(
                  initialValue: _selectedVehicleColor,
                  decoration: const InputDecoration(
                    hintText: 'Select vehicle color',
                  ),
                  items: _vehicleColors.keys.map((colorName) {
                    return DropdownMenuItem<String>(
                      value: colorName,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _vehicleColors[colorName],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorName == 'White'
                                    ? AppStyle.borderColor(context)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(colorName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedVehicleColor = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(
                  value:
                      "Upload Legal Papers (e.g., specific government letters).(Barua ya Mtendaji)",
                ),
                FileUploadButtonComp(
                  label: 'Upload',
                  localFile: _legalPapersFile,
                  existingFileUrl: _existingVehicle?.legalPapersUrl,
                  onFilePicked: (file) =>
                      setState(() => _legalPapersFile = file),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: "Insurance Type"),
                DropdownButtonFormField<String>(
                  initialValue: _selectedInsuranceType,
                  decoration: const InputDecoration(
                    hintText: 'Select insurance type',
                  ),
                  items: ['Comprehensive', 'Third Party']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedInsuranceType = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldTitle(value: 'Insurance Documents'),
                FileUploadButtonComp(
                  label: 'Upload',
                  localFile: _insuranceDocsFile,
                  existingFileUrl: _existingVehicle?.insuranceDocsUrl,
                  onFilePicked: (file) =>
                      setState(() => _insuranceDocsFile = file),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextFieldTitle(value: 'Vehicle Images'),
              FileUploadButtonComp(
                label: 'Front view',
                localFile: _frontViewFile,
                existingFileUrl: _existingVehicle?.frontImageUrl,
                onFilePicked: (file) => setState(() => _frontViewFile = file),
              ),
              FileUploadButtonComp(
                label: 'Side view',
                localFile: _sideViewFile,
                existingFileUrl: _existingVehicle?.sideImageUrl,
                onFilePicked: (file) => setState(() => _sideViewFile = file),
              ),
              FileUploadButtonComp(
                label: 'Rear view',
                localFile: _rearViewFile,
                existingFileUrl: _existingVehicle?.rearImageUrl,
                onFilePicked: (file) => setState(() => _rearViewFile = file),
              ),
              if (!(_selectedVehicleType?.toLowerCase().contains('boda') ??
                  false))
                FileUploadButtonComp(
                  label: 'Interior View Upload',
                  localFile: _otherDocFile,
                  existingFileUrl: _existingVehicle?.otherImageUrl,
                  onFilePicked: (file) => setState(() => _otherDocFile = file),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
