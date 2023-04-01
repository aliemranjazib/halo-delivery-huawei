import 'package:flutter/material.dart';
import 'package:haloapp/components_new/profile_option.dart';
import 'package:haloapp/main.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/screens/auth/change_profile_page.dart';
import 'package:haloapp/screens/main/account_security_page.dart';
import 'package:haloapp/screens/main/activity_support_page.dart';
import 'package:haloapp/screens/main/notification_list_page.dart';
import 'package:haloapp/screens/main/points/points_page.dart';
import 'package:haloapp/screens/main/referral_page.dart';
import 'package:haloapp/screens/main/webview_page.dart';
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
      body: SafeArea(
        top: false,
        child: Container(
          child: User().getUsername() == null
              ? Center(
                  child: ElevatedButton(
                  child: Text('login'),
                  onPressed: () {},
                ))
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: kAppBarGradient,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  SharedPrefService().removeLoginInfo();
                                  BookingModel().clearBookingData();
                                  FoodOrderModel().clearFoodOrderData();
                                  User().resetUserData();
                                  User.currentTab.value = 0;
                                  // MyApp.myTabbedPageKey.currentState
                                  //     .tabController
                                  //     .animateTo(0);
                                  // Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    AppTranslations.of(context).text('logout'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: poppinsSemiBold,
                                    ),
                                  ),
                                ),
                              ),
                              Utils.getEnvironment(),
                            ],
                          ),
                          Image.asset(
                            'images/avatar.png',
                            height: 120,
                          ),
                          SizedBox(height: 10),
                          Text(
                            User().getUsername(),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: poppinsSemiBold,
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 200 + MediaQuery.of(context).padding.top,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 25.0,
                        ),
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ProfileOption(
                                icon: 'images/ic_setting.png',
                                label: AppTranslations.of(context)
                                    .text('profile_option_personal'),
                                onPressed: () async {
                                  await Navigator.pushNamed(
                                      context, ChangeProfilePage.id);
                                  setState(() {});
                                },
                              ),
                              ProfileOption(
                                icon: 'images/ic_password.png',
                                label: AppTranslations.of(context)
                                    .text('profile_option_security'),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AccountSecurityPage.id);
                                },
                              ),
                              ProfileOption(
                                icon: 'images/ic_noti.png',
                                label: AppTranslations.of(context)
                                    .text('notification'),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, NotificationListPage.id);
                                },
                              ),
                              ProfileOption(
                                icon: 'images/new/points.png',
                                label:
                                    AppTranslations.of(context).text('Points'),
                                onPressed: () {
                                  Navigator.pushNamed(context, PointsPage.id);
                                },
                              ),
                              ProfileOption(
                                icon: 'images/ic_referral.png',
                                label: AppTranslations.of(context)
                                    .text('referrals'),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, ReferralsPage.id);
                                },
                              ),
                              ProfileOption(
                                icon: 'images/ic_faq.png',
                                label: AppTranslations.of(context).text('faqs'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebviewPage(
                                        url: 'https://halo.express/home/faq',
                                        title: AppTranslations.of(context)
                                            .text('faqs'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ProfileOption(
                                icon: 'images/ic_faq.png',
                                label:
                                    AppTranslations.of(context).text('support'),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, ActivitySupportPage.id);
                                },
                              ),
                              ProfileOption(
                                icon: 'images/ic_t&c.png',
                                label: AppTranslations.of(context)
                                    .text('terms_n_conditions'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebviewPage(
                                        url: 'https://halo.express/home/term',
                                        title: AppTranslations.of(context)
                                            .text('terms_n_conditions'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ProfileOption(
                                icon: 'images/ic_p_c.png',
                                label: AppTranslations.of(context)
                                    .text('privacy_n_policy'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebviewPage(
                                        url:
                                            'https://halo.express/home/privacy',
                                        title: AppTranslations.of(context)
                                            .text('privacy_n_policy'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                child: Text(
                                  'Version: $_appVersion',
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
