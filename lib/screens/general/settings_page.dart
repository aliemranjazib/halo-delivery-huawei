import 'package:flutter/material.dart';
import 'package:haloapp/screens/general/language_selector_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/app_translations/application.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';

class SettingsPage extends StatefulWidget {
  static const String id = 'settingsPage';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguageCode;

  @override
  void initState() {
    super.initState();

    initiateLanguage();
  }

  void initiateLanguage() async {
    String languageCode = await SharedPrefService().getLanguage();
    setState(() {
      _selectedLanguageCode = languageCode;
    });
  }

  _displayLanguageDialog() {
    showDialog(context: context, builder: (context) => LanguageSelectorPage())
        .then((value) {
      setState(() {
        initiateLanguage();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("settings"),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(AppTranslations.of(context).text('language'),
                style: TextStyle(fontFamily: poppinsMedium, fontSize: 18)),
            SizedBox(height: 15.0),
            GestureDetector(
              onTap: () {
                _displayLanguageDialog();
              },
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  application.getLanguageName(_selectedLanguageCode),
                  style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
