import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kiliride/translations/en.dart';
import 'package:kiliride/translations/sw.dart';


class LocaleService extends Translations {
  static Locale locale = const Locale('en', 'US');
  static Locale fallbackLocale = const Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': englishTranslations,
    'sw_TZ': swahiliTranslations,
    // 'es_ES': spanishTranslations,
    // 'pt_PT': portugueseTranslations,
    // 'fr_FR': frenchTranslations,
  };
}
