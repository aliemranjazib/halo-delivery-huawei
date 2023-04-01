import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/screens/boarding/login_page.dart';
import 'package:haloapp/screens/boarding/signup_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class GetStartedPage extends StatefulWidget {
  static const String id = 'GetStartedPage';

  @override
  _GetStartedPageState createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Image.asset(
              "images/get_started_bg.png",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitHeight,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Text(
                    AppTranslations.of(context).text("title_let_get_started"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Text(
                    AppTranslations.of(context)
                        .text("title_login_enjoy_the_app"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: light2Grey,
                      fontFamily: poppinsRegular,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: ActionIconButton(
                            onPressed: () {
                              return Navigator.pushNamed(context, LoginPage.id,
                                  arguments: LoginArguments(true));
                            },
                            icon: Image.asset(
                              "images/haloje_logo_small.png",
                              width: 80,
                              height: 80,
                            ),
                            buttonText: AppTranslations.of(context)
                                .text("title_existing_user"),
                          ),
                        )),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: ActionIconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                SignUpPage.id,
                              );
                            },
                            icon: Container(
                                padding: EdgeInsets.all(16),
                                width: 80,
                                height: 80,
                                child: Image.asset("images/ic_edit.png")),
                            buttonText: AppTranslations.of(context)
                                .text("title_apply_account"),
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
