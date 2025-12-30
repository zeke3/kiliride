import 'package:flutter/material.dart';
import 'package:kiliride/shared/styles.shared.dart';
import 'package:kiliride/components/device_contacts_picker.dart';
import 'package:kiliride/screens/manual_add_contact_form.scrn.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  final List<TrustedContact> _contacts = [];

  void _showAddContactOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppStyle.appColor(context),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildAddOptionButton(
              icon: Icons.contacts,
              title: 'Add from contacts',
              onTap: () {
                Navigator.pop(context);
                _addFromContacts();
              },
            ),
            const SizedBox(height: 12),
            _buildAddOptionButton(
              icon: Icons.edit,
              title: 'Add manually',
              onTap: () {
                Navigator.pop(context);
                _addManually();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _reloadContacts() {
    // Callback to refresh the contact list after adding
    setState(() {});
  }

  Widget _buildAddOptionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppStyle.inputBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addFromContacts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DeviceContactsPicker(
          onContactAdded: _reloadContacts,
        );
      },
    );
  }

  void _addManually() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ManualAddContactForm(
          onContactAdded: _reloadContacts,
        );
      },
    );
  }

  void _removeContact(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppStyle.appColor(context),
        title: const Text('Remove contact'),
        content: Text(
          'Are you sure you want to remove ${_contacts[index].name} from your trusted contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _contacts.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text(
              'Remove',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.appColor(context),
      appBar: AppBar(
        backgroundColor: AppStyle.appColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trusted contacts',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _contacts.isEmpty ? _buildEmptyState() : _buildContactsList(),
      floatingActionButton: _contacts.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddContactOptions,
              backgroundColor: AppStyle.primaryColor(context),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppStyle.appPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppStyle.primaryColor(context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_outlined,
                size: 80,
                color: AppStyle.primaryColor(context).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No contacts added',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'For your security, add at least one person that we can call in an emergency.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showAddContactOptions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.primaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add from contacts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _addManually,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppStyle.primaryColor(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: AppStyle.primaryColor(context),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Add manually',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppStyle.appPadding),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: AppStyle.primaryColor(context).withValues(alpha: 0.1),
              radius: 24,
              child: Icon(
                Icons.person,
                color: AppStyle.primaryColor(context),
                size: 24,
              ),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.phoneNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.relationship,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppStyle.primaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
              onPressed: () => _removeContact(index),
            ),
          ),
        );
      },
    );
  }
}

class TrustedContact {
  final String name;
  final String phoneNumber;
  final String relationship;

  TrustedContact({
    required this.name,
    required this.phoneNumber,
    required this.relationship,
  });
}
