import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/utils/app_translations/application.dart';
import 'app_translations.dart';

class AppTranslationsDelegate extends LocalizationsDelegate<AppTranslations> {
  final Locale newLocale;
  const AppTranslationsDelegate({this.newLocale});

  @override
  bool isSupported(Locale locale) {
    // return application.supportedLanguagesCodes.contains(locale.languageCode);
    return locale.languageCode == 'en'
        ? true
        : AppConfig.language?.firstWhere(
                (element) => element.code == locale.languageCode) !=
            null;
  }

  @override
  Future<AppTranslations> load(Locale locale) {
    return AppTranslations.load(newLocale ?? locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppTranslations> old) {
    return true;
  }
}
