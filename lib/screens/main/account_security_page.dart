import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components_new/profile_option.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/auth/change_password_page.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/screens/main/language_selector_page.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';

import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';

class AccountSecurityPage extends StatefulWidget {
  static const String id = 'AccountSecurityPage';

  @override
  AccountSecurityPageState createState() => AccountSecurityPageState();
}

class AccountSecurityPageState extends State<AccountSecurityPage> {

  Future _removeAccount() async {

    Map<String, dynamic> params = {
    };

    print(params);

    try {
        String data = await  await AuthNetworking().removeAccount(params);
        showSimpleFlushBar(data, context, isError: false);

        SharedPrefService().removeLoginInfo();
        BookingModel().clearBookingData();
        FoodOrderModel().clearFoodOrderData();
        User().resetUserData();
        User.currentTab.value = 0;
        Navigator.popUntil(context, ModalRoute.withName(TabBarPage.id));
    } catch (e) {
      print('gg');
      // print(e.toString());
    } finally {

    }
  }

  void showConfirmMakeNewBookingDialog() {
    showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
          title: AppTranslations.of(context).text('delete_account'),
          message: AppTranslations.of(context).text(
              'delete_account_confirm'),
        )).then((value) {
      if (value != null && value == 'confirm') {
        _removeAccount();
      }
    });
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
          AppTranslations.of(context).text('profile_option_security'),
          style: kAppBarTextStyle,
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 25.0,
          ),
          child: Column(
            children: [
              ProfileOption(
                icon: 'images/ic_language_setting.png',
                label: AppTranslations.of(context)
                    .text('profile_option_languages'),
                onPressed: () {
                  Navigator.pushNamed(context, LanguageSelectorPage.id);
                },
              ),
              ProfileOption(
                icon: 'images/ic_change_pw.png',
                label:
                    AppTranslations.of(context).text('profile_option_password'),
                onPressed: () {
                  Navigator.pushNamed(context, ChangePasswordPage.id);
                },
              ),
              ProfileOption(
                icon: 'images/ic_change_pw.png',
                label:
                AppTranslations.of(context).text('delete_account'),
                onPressed: () {
                  showConfirmMakeNewBookingDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
