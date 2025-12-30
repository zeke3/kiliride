import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/models/trusted_contact.model.dart';
import 'package:kiliride/services/auth.service.dart';
import 'package:kiliride/services/db_service.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:kiliride/widgets/snack_bar.dart';
import 'package:phone_form_field/phone_form_field.dart';

class ManualAddContactForm extends StatefulWidget {
  final VoidCallback? onContactAdded;
  final String? prefilledFirstName;
  final String? prefilledLastName;
  final String? prefilledPhoneNumber;

  const ManualAddContactForm({
    super.key,
    this.onContactAdded,
    this.prefilledFirstName,
    this.prefilledLastName,
    this.prefilledPhoneNumber,
  });

  @override
  State<ManualAddContactForm> createState() => _ManualAddContactFormState();
}

class _ManualAddContactFormState extends State<ManualAddContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = PhoneController(
    initialValue: const PhoneNumber(isoCode: IsoCode.TZ, nsn: ''),
  );

  String _selectedRelationship = RelationshipType.friend.displayName;
  bool _isSubmitting = false;
  String? _relationshipError;

  final DBService _dbService = DBService();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with prefilled data if provided
    if (widget.prefilledFirstName != null) {
      _firstNameController.text = widget.prefilledFirstName!;
    }
    if (widget.prefilledLastName != null) {
      _lastNameController.text = widget.prefilledLastName!;
    }
    if (widget.prefilledPhoneNumber != null) {
      // Parse the phone number string and set it to the controller
      try {
        final phoneNumber = PhoneNumber.parse(widget.prefilledPhoneNumber!);
        _phoneController.value = phoneNumber;
      } catch (e) {
        // If parsing fails, try setting it as national number for Tanzania
        _phoneController.value = PhoneNumber(
          isoCode: IsoCode.TZ,
          nsn: widget.prefilledPhoneNumber!.replaceAll(RegExp(r'[^\d]'), ''),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) {
      return;
    }


  }

  void _showRelationshipBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppStyle.appBackgroundColor(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppStyle.appRadiusLG),
              topRight: Radius.circular(AppStyle.appRadiusLG),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppStyle.appGap),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppStyle.appPadding),
                child: Column(
                  children: [
                    Text(
                      'Select Relationship'.tr,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSizeLG,
                        fontWeight: FontWeight.w600,
                        color: AppStyle.textPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a relationship for this contact'.tr,
                      style: TextStyle(
                        fontSize: AppStyle.appFontSize,
                        color: AppStyle.secondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Relationship options
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyle.appPadding,
                  ),
                  itemCount: RelationshipType.getAllDisplayNames().length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: Color.fromRGBO(225, 225, 225, 1),
                  ),
                  itemBuilder: (context, index) {
                    final relationship =
                        RelationshipType.getAllDisplayNames()[index];
                    final isSelected = relationship == _selectedRelationship;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: AppStyle.appGap / 4,
                      ),
                      title: Text(
                        relationship.tr,
                        style: TextStyle(
                          fontSize: AppStyle.appFontSize,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? AppStyle.primaryColor(context)
                              : AppStyle.textPrimaryColor(context),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppStyle.primaryColor(context),
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedRelationship = relationship;
                          _relationshipError =
                              null; // Clear any validation error
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _validateForm() {
    bool isValid = true;

    // Clear previous errors
    setState(() {
      _relationshipError = null;
    });

    // Validate relationship selection
    if (_selectedRelationship.isEmpty) {
      setState(() {
        _relationshipError = 'Please select a relationship'.tr;
      });
      isValid = false;
    }

    // Validate other form fields
    if (!_formKey.currentState!.validate()) {
      isValid = false;
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: AppStyle.appBackgroundColor(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppStyle.appRadiusLG),
            topRight: Radius.circular(AppStyle.appRadiusLG),
          ),
        ),
        padding: EdgeInsets.only(
          top: AppStyle.appPadding,
          left: AppStyle.appPadding,
          right: AppStyle.appPadding,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppStyle.appPadding,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppStyle.appPadding),

                // Title
                Text(
                  'Add Contact Manually'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeLG,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.textPrimaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the contact details below'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSize,
                    color: AppStyle.secondaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppStyle.appPadding),

                // First Name Field
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name'.tr,
                    hintText: 'Enter first name'.tr,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadius),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadius),
                      borderSide: BorderSide(
                        color: AppStyle.primaryColor(context),
                        width: 1,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required'.tr;
                    }
                    if (value.trim().length < 2) {
                      return 'First name must be at least 2 characters'.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppStyle.appPadding),

                // Last Name Field (Optional)
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name (Optional)'.tr,
                    hintText: 'Enter last name'.tr,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadius),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadius),
                      borderSide: BorderSide(
                        color: AppStyle.primaryColor(context),
                        width: 1,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    // Last name is optional, only validate if provided
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length < 2) {
                        return 'Last name must be at least 2 characters'.tr;
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppStyle.appPadding),

                // Phone Number Field
                PhoneFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number'.tr,
                    hintText: '712 345 678',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadius),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadius),
                      borderSide: BorderSide(
                        color: AppStyle.primaryColor(context),
                        width: 1,
                      ),
                    ),
                  ),
                  validator: PhoneValidator.compose([
                    PhoneValidator.required(context, errorText: 'Phone number is required'.tr),
                    PhoneValidator.valid(context, errorText: 'Please enter a valid phone number'.tr),
                  ]),
                  countrySelectorNavigator: const CountrySelectorNavigator.page(),
                  onChanged: (phoneNumber) {
                    // Phone number changed
                  },
                ),

                const SizedBox(height: AppStyle.appPadding),

                // Relationship Selection Field
                GestureDetector(
                  onTap: () => _showRelationshipBottomSheet(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: AppStyle.appGap,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _relationshipError != null
                            ? Colors.red
                            : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(AppStyle.appRadius),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Relationship'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedRelationship.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppStyle.textPrimaryColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),

                // Show validation error if any
                if (_relationshipError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      _relationshipError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: AppStyle.appPadding * 1.5),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: AppStyle.elevatedButtonStyle(context).copyWith(
                    backgroundColor: WidgetStateProperty.all(AppStyle.primaryColor(context)),
                    minimumSize: WidgetStateProperty.all(
                      const Size(double.infinity, 52),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('Adding Contact...'.tr),
                          ],
                        )
                      : Text(
                          'Add Contact'.tr,
                          style: const TextStyle(
                            fontSize: AppStyle.appFontSizeMd,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                const SizedBox(height: AppStyle.appGap),

                // Cancel Button
                OutlinedButton(
                  style: AppStyle.outlinedButtonStyle(context).copyWith(
                    minimumSize: WidgetStateProperty.all(
                      const Size(double.infinity, 52),
                    ),
                    side: WidgetStateProperty.all(
                      BorderSide(
                        color: AppStyle.secondaryColor(context),
                        width: 1,
                      ),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                  child: Text(
                    'Cancel'.tr,
                    style: TextStyle(
                      color: AppStyle.secondaryColor(context),
                      fontSize: AppStyle.appFontSizeMd,
                    ),
                  ),
                ),

                // Bottom safe area padding
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
