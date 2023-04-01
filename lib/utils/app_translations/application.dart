import 'dart:ui';

import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/utils/app_translations/app_translations_delegate.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';

class Application {
  static final Application _application = Application._internal();

  factory Application() {
    return _application;
  }

  Application._internal();

  // final List<String> supportedLanguages = ["English", "Bahasa Melayu", "华语"];

  // final List<String> supportedLanguagesCodes = ["en", "ms", "zh"];

  static final List<String> supportedShortCodeLanguages = ["EN", "BM", "华语"];

  static final List<String> supportedLanguages = ["English", "Bahasa Melayu", "华语"];

  static final List<String> supportedLanguagesCodes = ["en", "ms", "zh"];

  static final Map<dynamic, dynamic> languagesMap = {
    supportedLanguagesCodes[0]: supportedShortCodeLanguages[0],
    supportedLanguagesCodes[1]: supportedShortCodeLanguages[1],
    supportedLanguagesCodes[2]: supportedShortCodeLanguages[2],
  };

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ms':
        return 'Bahasa Melayu';
      case 'zh':
        return '华语';
      default:
        return '';
    }
  }

  String getLanguageShortName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
        return 'EN';
      case 'ms': case 'bm':
        return 'BM';
      case 'zh': case 'cn':
        return '华语';
      default:
        return '';
    }
  }

  AppTranslationsDelegate localeDelegate;

  //returns the list of supported Locales
  // Iterable<Locale> supportedLocales() =>
  //     supportedLanguagesCodes.map<Locale>((language) => Locale(language, ""));

  Iterable<Locale> supportedLocales() =>
      AppConfig.language
          ?.map<Locale>((language) => Locale(language.code, "")) ??
      [Locale('en', '')];

  //function to be invoked when changing the language
  LocaleChangeCallback onLocaleChanged;
}

Application application = Application();

typedef void LocaleChangeCallback(Locale locale);
