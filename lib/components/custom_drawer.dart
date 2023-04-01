import 'package:flutter/material.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/screens/auth/user_profile_page.dart';
import 'package:haloapp/screens/history/delivery_history_page.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/screens/general/settings_page.dart';
import 'package:haloapp/screens/general/support_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/services/package_info_service.dart';
import 'dart:io';

import 'package:haloapp/utils/services/shared_pref_service.dart';

class CustomDrawer extends StatefulWidget {
  final Function(String) callback;

  CustomDrawer({this.callback});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, UserProfilePage.id);
            },
            child: Container(
              child: DrawerHeader(
                decoration: BoxDecoration(color: kColorRed),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Image.asset(
                      'images/male_user.png',
                      height: 100.0,
                    ),
                    SizedBox(height: 10.0),
                    Flexible(
                      child: Text(
                        '${AppTranslations.of(context).text("hi")}, ${User().getUsername()}!',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                            fontFamily: poppinsMedium,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.fiber_new),
                  title: Text(
                    AppTranslations.of(context).text("new_booking"),
                    style: TextStyle(fontFamily: poppinsMedium, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.callback('newBooking');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    AppTranslations.of(context).text('history'),
                    style: TextStyle(fontFamily: poppinsMedium, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, DeliveryHistoryPage.id)
                        .then((value) {
                      if (value != null && value == 'remakeBooking') {
                        widget.callback('remakeBooking');
                      }
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text(
                    AppTranslations.of(context).text('support'),
                    style: TextStyle(fontFamily: poppinsMedium, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, SupportPage.id);
                  },
                ),
//                ListTile(
//                  leading: Icon(Icons.settings),
//                  title: Text(
//                    AppTranslations.of(context).text('settings'),
//                    style: TextStyle(fontFamily: poppinsMedium, fontSize: 16),
//                  ),
//                  onTap: () {
//                    Navigator.pop(context);
//                    Navigator.pushNamed(context, SettingsPage.id);
//                  },
//                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text(
                    AppTranslations.of(context).text('logout'),
                    style: TextStyle(fontFamily: poppinsMedium, fontSize: 16),
                  ),
                  onTap: () async {
                    SharedPrefService().removeLoginInfo();
                    BookingModel().clearBookingData();

                    Navigator.pop(context);

                    // wait drawer closing animation finish before pop back to login
                    sleep(Duration(milliseconds: 400));
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
          Container(
            height: 50.0,
            child: FutureBuilder<String>(
              future: PackageInfoService().getAppVersion(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Version ${snapshot.data}',
                    style: TextStyle(
                      fontFamily: poppinsLight,
                      fontSize: 12,
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
