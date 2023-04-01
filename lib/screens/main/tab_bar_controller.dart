import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/halo_loading.dart';
import 'package:haloapp/main.dart';
import 'package:haloapp/models/banner_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/networkings/home_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/screens/general/banner_dialog.dart';
import 'package:haloapp/screens/main/ewallet_page.dart';
import 'package:haloapp/screens/main/user_profile_page.dart';
import 'package:haloapp/screens/boarding/login_page.dart';
import 'package:haloapp/screens/general/custom_alert_dialog.dart';
// import 'package:haloapp/screens/history/delivery_history_page.dart';
import 'package:haloapp/screens/main/delivery_history_page.dart';

import 'package:haloapp/screens/general/support_page.dart';
import 'package:haloapp/screens/main/home_page_new.dart';
// import 'package:haloapp/screens/main/home_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/app_translations/application.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:haloapp/utils/services/package_info_service.dart';
import 'package:haloapp/utils/services/push_notifications.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/components/custom_tab.dart' as halo;
import 'package:haloapp/widget/social_login_container.dart';
// import 'package:huawei_push/push.dart';
// import 'package:location_permissions/location_permissions.dart'
//     as location_permission;
import 'package:url_launcher/url_launcher.dart';

class TabBarPage extends StatefulWidget {
  static const String id = 'tabBarPage';
  const TabBarPage({Key key}) : super(key: key);

  @override
  TabBarPageState createState() => TabBarPageState();
}

class TabBarPageState extends State<TabBarPage>
    with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  DateTime _currentBackPressTime;
  bool _isLoading = true;
  int index = 0;

  TabController tabController;
  BannerModel _bannerModel = BannerModel();

  final List<Widget> _children = [
    HomePage(),
    DeliveryHistoryPage(),
    EwalletPage(),
    SupportPage(),
    UserProfilePage(),
  ];

  void tabBarOnTapped(int index) {
    print('tapped index $index');
    setupGPS();
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // checkAppUpdate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAppUpdate();
      showNoticeDialog();
    });

    init();

    tabController = TabController(vsync: this, length: _children.length);
    tabController.addListener(onTap);

    User.currentTab.addListener(() {
      if (!tabController.indexIsChanging) {
        tabController.animateTo(User.currentTab.value);
      }
    });

    // SystemChannels.lifecycle.setMessageHandler((msg) {
    //   debugPrint('SystemChannels> $msg');
    //   if (msg == AppLifecycleState.resumed.toString()) {
    //     // preLoadGPS();
    //   }
    //   ;
    // });
  }

  init() async {
    await HomeNetworking.initAppConfig();
    var langCode = await SharedPrefService().getLanguage();
    application.onLocaleChanged(Locale(langCode ?? 'en'));
    // preLoadGPS();
    // autoLogin();

    await Future.wait([setupGPS()]);
    setState(() {
      _isLoading = false;
    });
  }

  preLoadGPS() async {
    LocationService.getLastKnownLocation();
  }

  onTap() {
    if (mounted) {
      setState(() {
        _currentTabIndex = tabController.index;
        User.currentTab.value = _currentTabIndex;
        index = tabController.index;
      });
      if ((tabController.index == 1 ||
              tabController.index == 2 ||
              tabController.index == 4) &&
          User().getAuthToken() == null) {
        tabController.index = tabController.previousIndex;
        // return Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   LoginPage.id,
        //   (Route<dynamic> route) => false,
        //   arguments: LoginArguments(true),
        // );
        return Navigator.pushNamed(
          context,
          LoginPage.id,
          arguments: LoginArguments(true),
        );
      }
    }
//    tabController.animateTo(tabController.index);
  }

  checkAppUpdate() async {
    // _showAppUpdateDialog();
    if (await AuthNetworking().isAppRequireUpdate()) _showAppUpdateDialog();
  }

  Future<void> setupGPS() async {
    // await Geolocator.requestPermission();
    //
    // location_permission.ServiceStatus serviceStatus =
    //     await location_permission.LocationPermissions().checkServiceStatus();
    //
    // if (serviceStatus != location_permission.ServiceStatus.enabled) {
    //   await showDialog(
    //       context: context,
    //       builder: (context) => CustomAlertDialog(
    //             title: 'Halo App',
    //             message: AppTranslations.of(context)
    //                 .text('please_enable_location_service_in_phone_settings'),
    //           ));
    // }

    // if (serviceStatus != ServiceStatus.enabled) {

    // } else {
    //   PermissionStatus permission =
    //       await LocationPermissions().checkPermissionStatus();

    //   if (permission != PermissionStatus.denied) {
    //     await Geolocator.requestPermission();
    //   }
    // }
  }

  // Future<void> autoLogin() async {
  //   Map<String, dynamic> info = await SharedPrefService().getLoginInfo();
  //   String username = info['username'];
  //   String password = info['password'];
  //   String socialType = info["socialType"];
  //   String socialModel = info["socialModelKey"];
  //   SocialLoginInfoModel socialLoginInfoModel;
  //
  //   if (socialModel != null && socialModel.isNotEmpty) {
  //     socialLoginInfoModel = socialInfoModelFromJson(socialModel);
  //   }
  //
  //   if (socialType != null) {
  //     if (socialType != SharedPrefService.normalLogin && socialLoginInfoModel != null) {
  //       PushNotificationsManager().init();
  //       String fcmToken = await PushNotificationsManager().getFCMToken();
  //       String huaweiToken = MyApp.huaweiToken;
  //
  //       Map<String, dynamic> params = {
  //         "data": {
  //           "socialEmail": socialLoginInfoModel != null ? socialLoginInfoModel.email : null,
  //           "socialName": socialLoginInfoModel != null ? socialLoginInfoModel.name : null,
  //           "socialId": socialLoginInfoModel != null ? socialLoginInfoModel.userId : null,
  //           "socialType": socialLoginInfoModel != null ? socialLoginInfoModel.type : null,
  //           "fcmToken": fcmToken,
  //           "huaweiToken": huaweiToken
  //         }
  //       };
  //
  //       print(params);
  //
  //       try {
  //         var data = await AuthNetworking().socialLogin(params);
  //
  //         print("Data: $data");
  //         if (data is String && data == 'login') {}
  //       } catch (e) {
  //         print(e.toString());
  //         if (e is String) {
  //           showSimpleFlushBar(e, context);
  //         }
  //       } finally {}
  //     } else {
  //       if (username != null && username != '' && password != null && password != '') {
  //         PushNotificationsManager().init();
  //         String fcmToken = await PushNotificationsManager().getFCMToken();
  //         String huaweiToken = MyApp.huaweiToken;
  //         Map<String, dynamic> params = {
  //           'data': {
  //             'phone': username,
  //             'password': password,
  //             'fcmToken': fcmToken,
  //             'huaweiToken': huaweiToken,
  //           }
  //         };
  //         try {
  //           var data = await AuthNetworking().login(params);
  //
  //           if (data is String && data == 'login') {
  //             // success slogin
  //             print('LOGINNED');
  //             // force refresh app after success login
  //           }
  //         } catch (e) {
  //           // print('ggwo');
  //           print(e);
  //           if (e is String) {
  //             showSimpleFlushBar(e, context);
  //           }
  //         } finally {}
  //       }
  //     }
  //   }
  // }

  // Future<void> autoLogin() async {
  //
  //   Map<String, String> info = await SharedPrefService().getLoginInfo();
  //   String username = info['username'];
  //   String password = info['password'];
  //   if (username == null) {
  //     return;
  //   }
  //   PushNotificationsManager().init();
  //   String fcmToken = await PushNotificationsManager().getFCMToken();
  //   String huaweiToken = MyApp.huaweiToken;
  //   Map<String, dynamic> params = {
  //     'data': {
  //       'phone': username,
  //       'password': password,
  //       'fcmToken': fcmToken,
  //       'huaweiToken': huaweiToken,
  //     }
  //   };
  //   try {
  //     var data = await AuthNetworking().login(params);
  //
  //     if (data is String && data == 'login') {
  //       // success slogin
  //       print('LOGINNED');
  //       // force refresh app after success login
  //     }
  //   } catch (e) {
  //     // print('ggwo');
  //     print(e);
  //     if (e is String) {
  //       showSimpleFlushBar(e, context);
  //     }
  //   } finally {}
  // }

  void _showAppUpdateDialog() {
    showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
              title: AppTranslations.of(context).text('new_version_available'),
              message: AppTranslations.of(context)
                  .text('the_new_version_of_app_is_available_please_update'),
            )).then((value) async {
      String url = '';
      if (Platform.isAndroid) {
        String packageName = await PackageInfoService().getPackageName();

        url = 'market://details?id=' + packageName;
        if (!(await canLaunchUrl(Uri.parse(url)))) {
          url = 'https://play.google.com/store/apps/details?id=' + packageName;
        }
      } else if (Platform.isIOS) {
        url = 'itms-apps://itunes.apple.com/my/app/id1525518223';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        launchUrl(Uri.parse(url));
      } else {
        print('Could not launch');
      }
    });
  }

  void showNoticeDialog() async {
    Map<String, dynamic> params = {};

    try {
      _bannerModel = await UserNetworking().getHomeBanner(params);
    } catch (e) {
      print(e);
      if (e is String) {
        showSimpleFlushBar(e, context);
      }
    } finally {}

    if (_bannerModel.reviewBanner != null) {
      var langCode = await SharedPrefService().getLanguage();
      String url = '';
      if (langCode == 'en') {
        url = _bannerModel.reviewBanner.en.imageUrl;
      } else if (langCode == 'ms') {
        url = _bannerModel.reviewBanner.bm.imageUrl;
      } else {
        url = _bannerModel.reviewBanner.cn.imageUrl;
      }

      if (url.isNotEmpty) {
        showDialog(
            context: context,
            builder: (context) => BannerDialog(
                  url: url,
                ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: _isLoading
            ? Scaffold(body: HaloLoading())
            : Scaffold(
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.1), blurRadius: 20)
                  ]),
                  child: Container(
                    color: Colors.white,
                    child: SafeArea(
                      top: false,
                      child: TabBar(
                        controller: tabController,
                        onTap: tabBarOnTapped,
                        labelColor: kColorRed,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.transparent,
                        unselectedLabelStyle: TextStyle(fontSize: 8.0),
                        labelStyle:
                            TextStyle(fontFamily: poppinsMedium, fontSize: 7.0),
                        tabs: [
                          halo.Tab(
                              iconMargin: EdgeInsets.all(0),
                              icon: getImageIcon("images/ic_home_selected.png",
                                  "images/ic_home.png", 0),
                              text: AppTranslations.of(context).text('home')),
                          halo.Tab(
                              iconMargin: EdgeInsets.all(0),
                              icon: getImageIcon(
                                  "images/ic_history_selected.png",
                                  "images/ic_history.png",
                                  1),
                              text:
                                  AppTranslations.of(context).text('history')),
                          halo.Tab(
                              iconMargin: EdgeInsets.all(0),
                              icon: getImageIcon(
                                  "images/ic_payment_tab_selected.png",
                                  "images/ic_payment_tab.png",
                                  2),
                              text: AppTranslations.of(context)
                                  .text('title_payment')),
                          halo.Tab(
                              iconMargin: EdgeInsets.all(0),
                              icon: getImageIcon(
                                  "images/ic_message_selected.png",
                                  "images/ic_message.png",
                                  3),
                              text: AppTranslations.of(context).text('chat')),
                          halo.Tab(
                              iconMargin: EdgeInsets.all(0),
                              icon: getImageIcon("images/ic_user_selected.png",
                                  "images/ic_user.png", 4),
                              text:
                                  AppTranslations.of(context).text('profile')),
                        ],
                      ),
                    ),
                  ),
                ),
                body:
                    TabBarView(controller: tabController, children: _children),
              ));

//    return WillPopScope(
//      onWillPop: () async {
//        SystemNavigator.pop();
//        return true;
//      },
//      child: DefaultTabController(
//        initialIndex: _currentTabIndex,
//        length: _children.length,
//        child: Scaffold(
//          body: _children[_currentTabIndex],
//          bottomNavigationBar: FABBottomAppBar(
//            onTabSelected: tabBarOnTapped,
//            items: [
//              FABBottomAppBarItem(iconData: Icons.home, text: 'home'),
//              FABBottomAppBarItem(
//                  iconData: Icons.history,
//                  text: AppTranslations.of(context).text('history')),
//              FABBottomAppBarItem(
//                  iconData: Icons.chat,
//                  text: AppTranslations.of(context).text('chat')),
//              FABBottomAppBarItem(
//                  iconData: Icons.account_circle,
//                  text: AppTranslations.of(context).text('profile')),
//            ],
//          ),
//        ),
//      ),
//    );
  }

  Widget getImageIcon(
      String selectedAsset, String unselectAsset, int position) {
    return Image.asset(
      _currentTabIndex == position ? selectedAsset : unselectAsset,
      width: 18,
      height: 18,
    );
  }
}
