import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kiliride/shared/funcs.main.ctrl.dart';
import 'package:kiliride/shared/styles.shared.dart';

class CancelRideReasonScreen extends StatefulWidget {
  const CancelRideReasonScreen({super.key});

  @override
  State<CancelRideReasonScreen> createState() => _CancelRideReasonScreenState();
}

class _CancelRideReasonScreenState extends State<CancelRideReasonScreen> {
  String? _selectedReason;
  final _otherReasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // A list of predefined reasons for cancellation.
  static const List<String> _cancelReasons = [
    'Driver asked me to cancel',
    'Driver is taking too long',
    'Driver is not moving',
    'I changed my mind',
    'Booked by mistake',
    'Other',
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _confirmCancellation() {
    // Ensure a reason is selected.
    if (_selectedReason == null) {
      Funcs.showSnackBar(message: "Please select a reason.", isSuccess: false);
      return;
    }

    // If 'Other' is selected, validate the text field.
    if (_selectedReason == 'Other') {
      if (_formKey.currentState!.validate()) {
        Navigator.of(context).pop(_otherReasonController.text.trim());
      }
    } else {
      Navigator.of(context).pop(_selectedReason);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.appColor(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppStyle.appBarHeight),
        child: AppBar(
          backgroundColor: AppStyle.appColor(context),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Cancel Ride".tr,
            style: TextStyle(
              fontSize: AppStyle.appFontSizeLG,
              fontWeight: FontWeight.w600,
              color: AppStyle.textColored(context),
            ),
          ),
          iconTheme: IconThemeData(
            color: AppStyle.textColored(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyle.appPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's your reason for cancellation?".tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSizeLG,
                  fontWeight: FontWeight.w500,
                  color: AppStyle.textColored(context),
                ),
              ),
              const SizedBox(height: AppStyle.appGap / 2),
              Text(
                "Your feedback helps us improve the service.".tr,
                style: TextStyle(
                  fontSize: AppStyle.appFontSize,
                  color: AppStyle.textColoredFade(context),
                ),
              ),
              const SizedBox(height: AppStyle.appPadding),
              // Create a list of selectable tiles for each reason.
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cancelReasons.length,
                separatorBuilder: (context, index) =>
                    Divider(color: AppStyle.borderColor(context)),
                itemBuilder: (context, index) {
                  final reason = _cancelReasons[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      reason.tr,
                      style: TextStyle(color: AppStyle.textColored(context)),
                    ),
                    leading: Radio<String>(
                      value: reason,
                      groupValue: _selectedReason,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                      activeColor: AppStyle.primaryColor(context),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedReason = reason;
                      });
                    },
                  );
                },
              ),
              // If 'Other' is selected, show a text field for custom input.
              if (_selectedReason == 'Other')
                TextFormField(
                  maxLines: 5,
                  minLines: 3,
                  controller: _otherReasonController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your reason'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
                      borderSide: BorderSide(
                        color: AppStyle.borderColor(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
                      borderSide: BorderSide(
                        color: AppStyle.primaryColor(context),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Reason cannot be empty'.tr;
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppStyle.appPadding),
          child: SizedBox(
            width: double.infinity,
            height: AppStyle.buttonHeight,
            child: ElevatedButton(
              onPressed: _confirmCancellation,
              style: AppStyle.elevatedButtonStyle(context).copyWith(
                backgroundColor: WidgetStatePropertyAll(
                  AppStyle.primaryColor(context),
                ),
              ),
              child: Text("Confirm Cancellation".tr),
            ),
          ),
        ),
      ),
    );
  }
}
