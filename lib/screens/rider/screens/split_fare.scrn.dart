import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';

class SplitFareScreen extends StatefulWidget {
  final int totalPrice;

  const SplitFareScreen({
    super.key,
    required this.totalPrice,
  });

  @override
  State<SplitFareScreen> createState() => _SplitFareScreenState();
}

class _SplitFareScreenState extends State<SplitFareScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  List<Contact> _selectedContacts = [];
  bool _isLoading = true;
  bool _permissionDenied = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    try {
      // Request permission
      if (await FlutterContacts.requestPermission()) {
        // Fetch contacts with phone numbers only
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        // Filter contacts that have phone numbers
        final contactsWithPhones = contacts
            .where((contact) => contact.phones.isNotEmpty)
            .toList();

        setState(() {
          _contacts = contactsWithPhones;
          _filteredContacts = contactsWithPhones;
          _isLoading = false;
        });
      } else {
        setState(() {
          _permissionDenied = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _permissionDenied = true;
      });
      Funcs.showSnackBar(
        message: "Failed to load contacts: ${e.toString()}",
        isSuccess: false,
      );
    }
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts
            .where((contact) =>
                contact.displayName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                contact.phones.any((phone) =>
                    phone.number.replaceAll(RegExp(r'\s+'), '').contains(query)))
            .toList();
      }
    });
  }

  void _toggleContact(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  void _removeSelectedContact(Contact contact) {
    setState(() {
      _selectedContacts.remove(contact);
    });
  }

  void _confirmSelection() {
    if (_selectedContacts.isEmpty) {
      Funcs.showSnackBar(
        message: "Please select at least one contact",
        isSuccess: false,
      );
      return;
    }

    // Return selected contacts to previous screen
    Navigator.of(context).pop(_selectedContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.appColor(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppStyle.appBarHeight),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppStyle.appColor(context),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Split fare".tr,
            style: TextStyle(
              fontSize: AppStyle.appFontSizeLG,
              fontWeight: FontWeight.w600,
              color: AppStyle.textColored(context),
            ),
          ),
          iconTheme: IconThemeData(
            color: AppStyle.textColored(context),
          ),
          actions: [
            TextButton(
              onPressed: _confirmSelection,
              child: Icon(
                Icons.check,
                color: AppStyle.primaryColor(context),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _permissionDenied
              ? _buildPermissionDenied()
              : Column(
                  children: [
                    // Search bar
                    Container(
                      padding: const EdgeInsets.all(AppStyle.appPadding),
                      color: AppStyle.appColor(context),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterContacts,
                        decoration: InputDecoration(
                          hintText: 'Search contacts'.tr,
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    // Selected contacts chips
                    if (_selectedContacts.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppStyle.appPadding,
                          vertical: AppStyle.appGap,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedContacts.map((contact) {
                            return Chip(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: AppStyle.borderColor(context),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              avatar: CircleAvatar(
                                backgroundColor: AppStyle.primaryColor(context),
                                child: Text(
                                  contact.displayName.isNotEmpty
                                      ? contact.displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              label: Text(
                                contact.displayName.isNotEmpty
                                    ? contact.displayName
                                    : contact.phones.first.number,
                                style: const TextStyle(fontSize: 12),
                              ),
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 18,
                              ),
                              onDeleted: () => _removeSelectedContact(contact),
                              backgroundColor: Colors.grey[100],
                            );
                          }).toList(),
                        ),
                      ),

                    // Contacts list
                    Expanded(
                      child: _filteredContacts.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.isEmpty
                                    ? 'No contacts found'.tr
                                    : 'No matching contacts'.tr,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: AppStyle.appFontSize,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppStyle.appPadding,
                                vertical: 0
                              ),
                              itemCount: _filteredContacts.length,
                              separatorBuilder: (context, index) => Divider(
                                color: AppStyle.dividerColor(context),
                              ),
                              itemBuilder: (context, index) {
                                final contact = _filteredContacts[index];
                                final isSelected =
                                    _selectedContacts.contains(contact);
                                final phoneNumber = contact.phones.isNotEmpty
                                    ? contact.phones.first.number
                                    : '';

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected
                                        ? AppStyle.primaryColor(context)
                                        : Colors.grey[300],
                                    radius: 24,
                                    child: Text(
                                      contact.displayName.isNotEmpty
                                          ? contact.displayName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontSize: AppStyle.appFontSizeMd,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    contact.displayName.isNotEmpty
                                        ? contact.displayName
                                        : 'Unknown',
                                    style: TextStyle(
                                      fontSize: AppStyle.appFontSize,
                                      fontWeight: FontWeight.w500,
                                      color: AppStyle.textColored(context),
                                    ),
                                  ),
                                  subtitle: Text(
                                    phoneNumber,
                                    style: TextStyle(
                                      fontSize: AppStyle.appFontSizeSM - 2,
                                      color: AppStyle.textColoredFade(context),
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppStyle.primaryColor(context)
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? AppStyle.primaryColor(context)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  onTap: () => _toggleContact(contact),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppStyle.appPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppStyle.appPadding),
            Text(
              'Contact Permission Required'.tr,
              style: TextStyle(
                fontSize: AppStyle.appFontSizeLG,
                fontWeight: FontWeight.w600,
                color: AppStyle.textColored(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyle.appGap),
            Text(
              'Please grant access to your contacts to split fare with friends'.tr,
              style: TextStyle(
                fontSize: AppStyle.appFontSize,
                color: AppStyle.textColoredFade(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyle.appPadding * 2),
            ElevatedButton(
              onPressed: _loadContacts,
              style: AppStyle.elevatedButtonStyle(context).copyWith(
                backgroundColor: WidgetStatePropertyAll(
                  AppStyle.primaryColor(context),
                ),
              ),
              child: Text('Grant Permission'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
