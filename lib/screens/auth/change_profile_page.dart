import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class ChangeProfilePage extends StatefulWidget {
  static const String id = 'changeProfilePage';

  @override
  ChangeProfilePageState createState() => ChangeProfilePageState();
}

class ChangeProfilePageState extends State<ChangeProfilePage> {
  bool _showSpinner = false;
  String _nameTFValue;
  String _emailTFValue;
  String oldName;
  String oldEmail;
  TextEditingController _nameTextController;
  TextEditingController _emailTextController;

  @override
  void initState() {
    super.initState();
    _nameTFValue = User().getUsername();
    _emailTFValue = User().getUserEmail();
    oldName = User().getUsername();
    oldEmail = User().getUserEmail();
    _nameTextController = TextEditingController(text: _nameTFValue);
    _emailTextController = TextEditingController(text: _emailTFValue);
  }

  void updateProfile() async {
    if (_nameTFValue == null || _nameTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_name'), context);
      return;
    }

    if (_emailTFValue == null || _emailTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_email'), context);
      return;
    }

    // if (_nameTFValue  == oldName) {
    //   showSimpleFlushBar(
    //       AppTranslations.of(context).text('please_enter_name_not_same'), context);
    //   return;
    // }
    //
    // if (_emailTFValue  == oldEmail) {
    //   showSimpleFlushBar(
    //       AppTranslations.of(context).text('please_enter_email_not_same'), context);
    //   return;
    // }

    Map<String, dynamic> params = {
      "data": {
        "userName": _nameTFValue,
        "userEmail": _emailTFValue,
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      Map data = await UserNetworking.updateProfile(params);

      showSimpleFlushBar(data["msg"].toString(), context, isError: false);

      User().setUsername(_nameTFValue);
      User().setEmail(_emailTFValue);
    } catch (e) {
      print(e);
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: arrowBack,
            onPressed: () => {Navigator.pop(context)},
          ),
          title: Text(
            AppTranslations.of(context).text('change_password'),
            style: kAppBarTextStyle,
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        AppTranslations.of(context).text('name'),
                        style:
                            TextStyle(fontFamily: poppinsRegular, fontSize: 15),
                      ),
                      InputTextField(
                        obscureText: false,
                        controller: _nameTextController,
                        onChange: (value) {
                          _nameTFValue = value;
                        },
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        AppTranslations.of(context).text('email'),
                        style:
                            TextStyle(fontFamily: poppinsRegular, fontSize: 15),
                      ),
                      InputTextField(
                        obscureText: false,
                        controller: _emailTextController,
                        inputType: TextInputType.emailAddress,
                        onChange: (value) {
                          _emailTextController = value;
                        },
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                  ActionButton(
                    buttonText: AppTranslations.of(context).text('change'),
                    onPressed: () {
                      updateProfile();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
