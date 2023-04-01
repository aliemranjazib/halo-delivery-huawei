import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/main.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/screens/auth/change_password_page.dart';
import 'package:haloapp/screens/auth/change_profile_page.dart';
import 'package:haloapp/screens/general/settings_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/package_info_service.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/utils/utils.dart';

class UserProfilePage extends StatefulWidget {
  static const String id = 'userProfilePage';

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _appVersion = '';
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    _appVersion = (await PackageInfoService().getAppVersion()) +
        " @ " +
        (await PackageInfoService().getAppBuildNumber());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text('profile'),
          style: kAppBarTextStyle,
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          GestureDetector(
              onTap: () {
                SharedPrefService().removeLoginInfo();
                BookingModel().clearBookingData();
                FoodOrderModel().clearFoodOrderData();
                User().resetUserData();
                User.currentTab.value = 0;

                // MyApp.myTabbedPageKey.currentState.tabController.animateTo(0);
                // Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.exit_to_app),
              )),
          Utils.getEnvironment()
        ],
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 25.0),
          child: User().getUsername() == null
              ? Center(
                  child: ElevatedButton(
                  child: Text('login'),
                  onPressed: () {},
                ))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Image.asset(
                        'images/avatar.png',
                        height: 120,
                      ),
                      SizedBox(height: 20.0),
                      UserInfoCard(
                        icon: Icon(Icons.person),
                        title: AppTranslations.of(context).text('name'),
                        detail: User().getUsername(),
                        actionBtn: GestureDetector(
                          // padding: EdgeInsets.zero,
                          // visualDensity: VisualDensity.compact,
                          onTap: () async {
                            await Navigator.pushNamed(
                                context, ChangeProfilePage.id);
                            setState(() {});
                          },
                          child: Icon(Icons.edit, color: Colors.red[900]),
                        ),
                      ),
                      UserInfoCard(
                        icon: Icon(Icons.alternate_email),
                        title: AppTranslations.of(context).text('email'),
                        detail: User().getUserEmail(),
                        actionBtn: GestureDetector(
                          // padding: EdgeInsets.zero,
                          // visualDensity: VisualDensity.compact,
                          onTap: () async {
                            await Navigator.pushNamed(
                                context, ChangeProfilePage.id);
                            setState(() {});
                          },
                          child: Icon(Icons.edit, color: Colors.red[900]),
                        ),
                      ),
                      UserInfoCard(
                          icon: Icon(Icons.phone),
                          title: AppTranslations.of(context).text('phone_no'),
                          detail: User().getUserPhoneCountryCode() +
                              User().getUserPhone()),
                      UserInfoCard(
                          icon: Icon(Icons.date_range),
                          title: AppTranslations.of(context).text('dob'),
                          detail: User().getUserDOB()),
                      UserInfoCard(
                        icon: Icon(Icons.lock),
                        title: AppTranslations.of(context).text('password'),
                        detail: '******',
                        actionBtn: GestureDetector(
                          // padding: EdgeInsets.zero,
                          // visualDensity: VisualDensity.compact,
                          onTap: () {
                            Navigator.pushNamed(context, ChangePasswordPage.id);
                          },
                          child: Icon(Icons.edit, color: Colors.red[900]),
                        ),
                      ),
                      UserInfoCard(
                          icon: Icon(Icons.info),
                          title: "Version",
                          detail: _appVersion),
                      // ActionButtonLight(
                      //   buttonText: 'Settings',
                      //   onPressed: () {
                      //     Navigator.of(context).pushNamed(SettingsPage.id);
                      //   },
                      // )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final Icon icon;
  final String title;
  final String detail;
  final Widget actionBtn;

  UserInfoCard({this.icon, this.title, this.detail, this.actionBtn});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: kColorRed.withOpacity(.05),
              borderRadius: BorderRadius.circular(100)),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
          margin: EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 8.0),
              IconTheme(
                  data: new IconThemeData(
                    size: 14,
                    color: kColorRed,
                  ),
                  child: icon),
              SizedBox(width: 4.0),
              SizedBox(
                width: 75,
                child: Text(
                  title,
                  style: TextStyle(
                    color: kColorRed,
                    fontFamily: poppinsMedium,
                    fontSize: 13,
                  ),
                ),
              ),
              // SizedBox(width: 5.0),
              Expanded(
                // flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detail,
                      style: TextStyle(fontFamily: poppinsMedium, fontSize: 15),
                    ),
                    addButton()
                  ],
                ),
              ),
            ],
          ),
        ),
        // Divider(color: Colors.black)
      ],
    );
  }

  Widget addButton() {
    if (actionBtn != null) {
      return actionBtn;
    } else {
      return Container();
    }
  }
}
