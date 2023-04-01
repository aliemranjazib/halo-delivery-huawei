import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';

class GoogleLoginButton extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  googleLogin(BuildContext context) async {}

  void _showMessage(String message) {
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return ActionIconButtonOutline(
      icon: Container(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'images/google.png',
          width: socialIconSize,
          height: socialIconSize,
        ),
      ),
      onPressed: () {},
      buttonText: AppTranslations.of(context).text('login_btn_google'),
    );
  }
}
