import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/app_translations/app_translations_delegate.dart';
import 'package:haloapp/utils/app_translations/application.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';

class LanguageSelectorPage extends StatefulWidget {
  static const String id = 'languageSelectorPage';

  @override
  _LanguageSelectorPageState createState() => _LanguageSelectorPageState();
}

class _LanguageSelectorPageState extends State<LanguageSelectorPage> {
  static final List<String> languagesList = Application.supportedLanguages;
  static final List<String> languageCodesList = Application.supportedLanguagesCodes;
  String _selectedLanguage;
  String _selectedLanguageCode;

  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
    languagesList[2]: languageCodesList[2],
  };

  @override
  void initState() {
    super.initState();

    initiateLanguage();
  }

  void initiateLanguage() async {
    String languageCode = await SharedPrefService().getLanguage();
    setState(() {
      _selectedLanguageCode = languageCode;

      var language = languagesMap.keys.firstWhere(
          (k) => languagesMap[k] == languageCode,
          orElse: () => null);
      _selectedLanguage = language;
    });
  }

  Widget buildLanguagesList() {
    List<Widget> list = [];

    for (int i = 0; i < AppConfig.language.length; i++) {
      var language = AppConfig.language.elementAt(i);

      Widget radioBtn = ListTile(
        contentPadding: EdgeInsets.all(0),
        title: GestureDetector(
          onTap: () {
            setState(() {
              _selectedLanguage = language.name;
              _selectedLanguageCode = language.code;
            });
          },
          child: Text(
            language.name,
            style: kDetailsTextStyle,
          ),
        ),
        leading: Radio(
          activeColor: kColorRed,
          value: language.code,
          groupValue: _selectedLanguageCode,
          onChanged: (value) {
            setState(() {
              _selectedLanguage = language.name;
              _selectedLanguageCode = language.code;
            });
            // setState(() {
            //   _selectedLanguage = value;
            // });
          },
        ),
      );

      list.add(radioBtn);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: arrowBack,
          onPressed: () => {Navigator.pop(context)},
        ),
        title: Text(
          AppTranslations.of(context).text('Language Settings'),
          style: kAppBarTextStyle,
        ),
      ),
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppTranslations.of(context).text("select_language"),
              style: kTitleTextStyle,
            ),
            SizedBox(height: 20.0),
            Container(
              child: SingleChildScrollView(child: buildLanguagesList()),
            ),
            SizedBox(height: 40.0),
            ActionButton(
              buttonText: AppTranslations.of(context).text('confirm'),
              onPressed: () {
                application.onLocaleChanged(Locale(_selectedLanguageCode));
                SharedPrefService().setLanguage(_selectedLanguageCode);
                Navigator.pop(context, 'confirm');
              },
            )
          ],
        ),
      )),
    );
  }
}
