import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class UploadImagePopup extends StatefulWidget {
  @override
  _UploadImagePopupState createState() => _UploadImagePopupState();
}

class _UploadImagePopupState extends State<UploadImagePopup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppTranslations.of(context).text('choose_upload_photo_method'),
            textAlign: TextAlign.center,
            style: kAddressTextStyle,
          ),
          SizedBox(height: 20.0),
          ActionButton(
            buttonText: AppTranslations.of(context).text('take_picture'),
            onPressed: () {
              Navigator.pop(context, 'camera');
            },
          ),
          SizedBox(height: 15.0),
          ActionButton(
            buttonText: AppTranslations.of(context).text('select_from_gallery'),
            onPressed: () {
              Navigator.pop(context, 'gallery');
            },
          )
        ],
      ),
    );
  }
}
