import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kiliride/screens/manual_add_contact_form.scrn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:kiliride/widgets/snack_bar.dart';

class DeviceContactsPicker extends StatefulWidget {
  final VoidCallback? onContactAdded;

  const DeviceContactsPicker({super.key, this.onContactAdded});

  @override
  State<DeviceContactsPicker> createState() => _DeviceContactsPickerState();
}

class _DeviceContactsPickerState extends State<DeviceContactsPicker> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = false;
  bool _permissionGranted = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionAndLoadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check and request permission
      PermissionStatus permission = await Permission.contacts.status;

      if (permission.isDenied) {
        permission = await Permission.contacts.request();
      }

      if (permission.isGranted) {
        setState(() {
          _permissionGranted = true;
        });
        await _loadContacts();
      } else if (permission.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDialog();
        }
      } else {
        if (mounted) {
          showSnackBar(
            context,
            'Contacts permission is required to access your contacts'.tr,
            type: SnackBarType.error,
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Error accessing contacts: $e'.tr,
          type: SnackBarType.error,
        );
        if (mounted) Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadContacts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get contacts with phone numbers only
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Filter contacts that have phone numbers
      final contactsWithPhones = contacts
          .where(
            (contact) =>
                contact.phones.isNotEmpty && contact.displayName.isNotEmpty,
          )
          .toList();

      // Sort contacts alphabetically
      contactsWithPhones.sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );

      setState(() {
        _contacts = contactsWithPhones;
        _filteredContacts = contactsWithPhones;
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Error loading contacts: $e'.tr,
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts.where((contact) {
          return contact.displayName.toLowerCase().contains(
            query.toLowerCase(),
          );
        }).toList();
      }
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contacts Permission Required'.tr),
        content: Text(
          'To select contacts from your device, we need access to your contacts. Please enable contacts permission in your device settings.'
              .tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
              Navigator.pop(context);
            },
            style: AppStyle.elevatedButtonStyle(context),
            child: Text('Open Settings'.tr),
          ),
        ],
      ),
    );
  }

  void _selectContact(Contact contact) {
    // Extract contact information
    String firstName = '';
    String lastName = '';
    String phoneNumber = '';

    // Parse display name into first and last name
    final nameParts = contact.displayName.trim().split(' ');
    if (nameParts.isNotEmpty) {
      firstName = nameParts.first;
      if (nameParts.length > 1) {
        lastName = nameParts.skip(1).join(' ');
      }
    }

    // Get the first phone number
    if (contact.phones.isNotEmpty) {
      phoneNumber = contact.phones.first.number;
    }

    // Close this screen and open the manual form with prefilled data
    Navigator.pop(context);

    // Show the manual form with prefilled data
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ManualAddContactForm(
          onContactAdded: widget.onContactAdded,
          prefilledFirstName: firstName,
          prefilledLastName: lastName,
          prefilledPhoneNumber: phoneNumber,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                  'Select Contact'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeMd,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.textPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a contact from your device'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeSM,
                    color: AppStyle.secondaryColor(context),
                  ),
                ),
              ],
            ),
          ),

          // Search bar (only show if permission granted and not loading)
          if (_permissionGranted && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyle.appPadding,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search contacts...'.tr,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(AppStyle.appPadding - 4),
                    child: SvgPicture.asset(
                      'assets/icons/search.svg',
                      color: AppStyle.secondaryColor(context),
                      width: 16,
                      height: 16,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.appRadius),
                  ),
                  filled: true,
                  // fillColor: AppStyle.primaryColor2(context),
                ),
                onChanged: _filterContacts,
              ),
            ),

          const SizedBox(height: AppStyle.appGap),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: 16),
            Text(
              'Loading contacts...'.tr,
              style: TextStyle(
                fontSize: AppStyle.appFontSize,
                color: AppStyle.secondaryColor(context),
              ),
            ),
          ],
        ),
      );
    }

    if (!_permissionGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Contacts Permission Required'.tr,
              style: TextStyle(
                fontSize: AppStyle.appFontSizeMd,
                fontWeight: FontWeight.w600,
                color: AppStyle.secondaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'We need access to your contacts to help you select trusted contacts.'
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppStyle.appFontSize,
                  color: AppStyle.secondaryColor(context),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _requestPermissionAndLoadContacts,
              style: AppStyle.elevatedButtonStyle(context),
              icon: const Icon(Icons.refresh),
              label: Text('Retry'.tr),
            ),
          ],
        ),
      );
    }

    if (_filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No Contacts Found'.tr
                  : 'No Matching Contacts'.tr,
              style: TextStyle(
                fontSize: AppStyle.appFontSizeMd,
                fontWeight: FontWeight.w600,
                color: AppStyle.secondaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'No contacts with phone numbers were found on your device.'
                        .tr
                  : 'Try a different search term.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppStyle.appFontSize,
                color: AppStyle.secondaryColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppStyle.appPadding),
      itemCount: _filteredContacts.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: Color.fromRGBO(225, 225, 225, 1)),
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        return _buildContactTile(contact);
      },
    );
  }

  Widget _buildContactTile(Contact contact) {
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppStyle.appGap / 2,
        horizontal: 0,
      ),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppStyle.primaryColor(context).withValues(alpha: 0.1),
        child: Text(
          contact.displayName.isNotEmpty
              ? contact.displayName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: AppStyle.appFontSizeMd,
            fontWeight: FontWeight.w600,
            color: AppStyle.primaryColor(context),
          ),
        ),
      ),
      title: Text(
        contact.displayName,
        style: TextStyle(
          fontSize: AppStyle.appFontSize,
          fontWeight: FontWeight.w600,
          color: AppStyle.textPrimaryColor(context),
        ),
      ),
      subtitle: phone.isNotEmpty
          ? Text(
              phone,
              style: TextStyle(
                fontSize: AppStyle.appFontSize - 2,
                color: AppStyle.secondaryColor(context),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppStyle.secondaryColor(context),
      ),
      onTap: () => _selectContact(contact),
    );
  }
}
