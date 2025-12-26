import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kiliride/services/language_service.dart';
import 'package:kiliride/shared/styles.shared.dart';

class LanguageModal extends StatefulWidget {
  const LanguageModal({super.key});

  @override
  State<LanguageModal> createState() => _LanguageModalState();
}

class _LanguageModalState extends State<LanguageModal> {
  String _currentLanguage = 'en_US';

  final List<Map<String, String>> _languages = [
    {'code': 'en_US', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'sw_TZ', 'name': 'Swahili', 'flag': '🇹🇿'},
    {'code': 'es_ES', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'pt_PT', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'fr_FR', 'name': 'Français', 'flag': '🇫🇷'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeLanguageState();
  }

  void _initializeLanguageState() async {
    final currentLanguage = await LanguageService.getSavedLanguage();
    setState(() {
      _currentLanguage = currentLanguage;
    });
  }

  void _setLanguage(String languageCode) async {
    await LanguageService.changeLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppStyle.appPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Language'.tr,
                  style: TextStyle(
                    fontSize: AppStyle.appFontSizeLG,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.invertedTextAppColor(context),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Language Options
          ...List.generate(_languages.length, (index) {
            final language = _languages[index];

            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppStyle.appRadiusXLG),
                      ),
                    ),
                    child: Text(
                      language['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  title: Text(
                    language['name']!.tr,
                    style: TextStyle(
                      fontSize: AppStyle.appFontSizeMd,
                      fontWeight: FontWeight.w500,
                      color: AppStyle.invertedTextAppColor(context),
                    ),
                  ),
                  trailing: Radio<String>(
                    value: language['code']!,
                    groupValue: _currentLanguage,
                    activeColor: AppStyle.primaryColor(context),
                    onChanged: (value) {
                      if (value != null) {
                        _setLanguage(value);
                      }
                    },
                  ),
                  onTap: () {
                    _setLanguage(language['code']!);
                  },
                ),
                if (index < _languages.length - 1)
                  Divider(color: AppStyle.borderColor(context)),
              ],
            );
          }),

          const SizedBox(height: AppStyle.appPadding),
        ],
      ),
    );
  }
}
