import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/halo_service_model.dart';
import 'package:haloapp/models/promo_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/home_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/screens/delivery/delivery_main_page.dart';
import 'package:haloapp/screens/food/food_main_page.dart';
import 'package:haloapp/screens/general/find_address_page.dart';
import 'package:haloapp/screens/general/language_selector_page.dart';
import 'package:haloapp/screens/history/delivery_history_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/app_translations/application.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:huawei_location/huawei_location.dart';

import 'package:haloapp/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  static const String id = 'homePage';
  final TabController tabController;

  HomePage({this.tabController});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedLanguageCode = "";
  bool _showSpinner = true;
  List<PromoModel> _promos = [];
  final List<HaloServiceModel> haloServices = [
    HaloServiceModel(
        title: 'express', iconName: 'images/btn_express.png', isEnable: true),
    HaloServiceModel(
        title: 'food',
        iconName: 'images/btn_food.png',
        isEnable: User().getEnableFoodStatus()),
    HaloServiceModel(
        title: 'pharmacy',
        iconName: 'images/btn_pharma.png',
        isEnable: User().getEnablePharmacyStatus()),
    HaloServiceModel(
        title: 'frozen',
        iconName: 'images/btn_meat.png',
        isEnable: User().getEnableFrozenStatus()),
    HaloServiceModel(
        title: 'grocery',
        iconName: 'images/btn_grocer.png',
        isEnable: User().getEnableGroceriesStatus()),
    HaloServiceModel(
        title: 'festival',
        iconName: 'images/btn_festival.png',
        isEnable: User().getEnabledFestivalStatus()),
    // isEnable: User().getEnableFoodStatus()),
//        isEnable: true),
//    HaloServiceModel(
//        title: 'groceries',
//        iconName: 'images/grocery_1.png',
//        isEnable: User().getEnableGroceriesStatus()),
//    HaloServiceModel(
//        title: 'frozen_food',
//        iconName: 'images/frozen_1.png',
//        isEnable: User().getEnableFrozenStatus()),
//    HaloServiceModel(
//        title: 'pharmacy',
//        iconName: 'images/pharmacy_1.png',
//        isEnable: User().getEnablePharmacyStatus()),
//    HaloServiceModel(
//        title: 'top_up', iconName: 'images/prepaid_1.png', isEnable: false),
//    HaloServiceModel(
//        title: 'gold', iconName: 'images/gold_1.png', isEnable: false),
  ];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    await Future.wait([
      initiateLanguage(),
      if (User().getAuthToken() != null) loadNearbyAddress(),
    ]);

    Location location = await LocationService.getLastKnownLocation();
    if (location != null) {
      loadHomeInfo(location.latitude.toString(), location.longitude.toString());
    } else {
      loadHomeInfo(0.0.toString(), 0.0.toString());
    }

    //Show loading if changing language
    SharedPrefService.isLoadingLanguage.addListener(() {
      if (SharedPrefService.isLoadingLanguage.value) {
        setState(() {
          _showSpinner = true;
        });
      } else {
        if (mounted) {
          setState(() {
            _showSpinner = false;
          });
        }
      }
    });
    setState(() {
      _showSpinner = false;
    });
  }

  Future<void> initiateLanguage() async {
    String languageCode = await SharedPrefService().getLanguage();
    // print('### ' + _selectedLanguageCode);
    setState(() {
      _selectedLanguageCode = languageCode;
    });
  }

  _displayLanguageDialog() {
    showDialog(context: context, builder: (context) => LanguageSelectorPage())
        .then((value) {
      setState(() {
        initiateLanguage();
      });
    });
  }

  void checkLocationPermission() async {
    bool locationPermissionGranted = await LocationService().checkPermission();
  }

  _serviceBtnPressed(String service) {
    switch (service) {
      case 'express':
        Navigator.pushNamed(context, DeliveryMainPage.id).then((results) {
          if (results is PopWithResults) {
            PopWithResults popResult = results;
            if (popResult.toPage == HomePage.id) {
              //'bookingSuccess'
            } else {
              // pop to previous page
              Navigator.of(context).pop(results);
            }
          }
        });
        break;
      default:
        FoodOption foodOption = FoodOption(
            searchName: AppTranslations.of(context).text("food"),
            shopType: "food");
        FoodOrderModel().foodOption = foodOption;
        Navigator.pushNamed(context, FoodMainPage.id);
        // Navigator.pushNamed(context, FindAddressPage.id);
        break;
    }
  }

  Future<void> loadHomeInfo(String lat, String lng) async {
    Location position = await LocationService.getLastKnownLocation();
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      if (position != null && position.latitude != null) ...{
        'lat': position.latitude.toString(),
        'lng': position.longitude.toString()
      }
    };

    try {
      var data = await HomeNetworking().getHomeInfo(params);

      setState(() {
        _promos = data;
      });
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  Future<void> loadNearbyAddress() async {
    var position = await LocationService.getLastKnownLocation();
    Map nearbyAddress = (await UserNetworking.nearbyAddress({
          'data': {
            if (position != null && position.latitude != null) ...{
              'lat': position.latitude.toString(),
              'lng': position.longitude.toString()
            }
          }
        }))['addresses'] ??
        Map();
    if (nearbyAddress.length > 0) {
      var am = AddressModel(
        name: nearbyAddress['address_name'],
        note: nearbyAddress['address_note'],
        lat: nearbyAddress['address_lat'],
        lng: nearbyAddress['address_lng'],
        fullAddress: nearbyAddress['address_full'],
        zip: nearbyAddress['address_zip'],
        unitNo: nearbyAddress['address_unit'],
        // buildingName: savedAddress[index]
        //     ['address_custom'],
        city: nearbyAddress['address_city'],
        state: nearbyAddress['address_state'],
        street: nearbyAddress['address_street'],
      );
      FoodOrderModel().setDeliverAddress(am);
      await HomeNetworking.initAppConfig({
        "latitude": nearbyAddress['address_lat'],
        "longitude": nearbyAddress['address_lng'],
      });
      // afterSave('saved');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _buildWhatsNewWidget() {
      List<Widget> promoViews = [];

      if (_promos.length > 0) {
        for (PromoModel promo in _promos) {
          promoViews.add(GestureDetector(
            onTap: () async {
              if (promo.actionUrl != null && promo.actionUrl != '') {
                if (await canLaunch(promo.actionUrl)) {
                  await launch(promo.actionUrl);
                } else {
                  throw 'Could not launch ${promo.actionUrl}';
                }
              }
            },
            child: Container(
              padding: EdgeInsets.only(bottom: 10.0),
              margin: EdgeInsets.only(bottom: 30.0),
              decoration: BoxDecoration(
                color: kColorRed,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: kColorRed.withOpacity(0.3),
                    // spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      height: 250,
                      fit: BoxFit.cover,
                      imageUrl: promo.imageUrl,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white))),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    promo.name,
                    textAlign: TextAlign.center,
                    style: kDetailsTextStyle.copyWith(
                        fontFamily: poppinsMedium,
                        fontSize: 14,
                        color: Colors.white),
                  )
                ],
              ),
            ),
          ));
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: promoViews,
      );
    }

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        // elevation: 0,
        title: Image.asset(
          'images/haloje_title.png',
          height: 28.0,
        ),
        actions: [
          Center(
            child: GestureDetector(
              onTap: () {
                _displayLanguageDialog();
              },
              child: Container(
                padding: EdgeInsets.all(10.0),
                // decoration: BoxDecoration(
                //   border: Border.all(),
                //   borderRadius: BorderRadius.circular(5.0),
                // ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      _selectedLanguageCode.toUpperCase(),
                      style:
                          TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                    ),
                    Icon(Icons.arrow_drop_down_rounded)
                  ],
                ),
              ),
            ),
          ),
          Utils.getEnvironment()
        ],
        automaticallyImplyLeading: false,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  color: kColorRed,
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _showSpinner = true;
                      });
                      await Navigator.pushNamed(context, FindAddressPage.id,
                          arguments: {'popMode': true});
                      FoodOrderModel().clearFoodOrderData();

                      if (FoodOrderModel().getDeliveryAddress()?.lat != null) {
                        await HomeNetworking.initAppConfig({
                          "latitude": FoodOrderModel().getDeliveryAddress().lat,
                          "longitude":
                              FoodOrderModel().getDeliveryAddress().lng,
                        });
                        loadHomeInfo(FoodOrderModel().getDeliveryAddress().lat,
                            FoodOrderModel().getDeliveryAddress().lng);
                      }

                      setState(() {
                        _showSpinner = false;
                      });
                      // editAddress();
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      // padding: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                          // border: Border.all(color: Colors.grey),

                          borderRadius: BorderRadius.circular(5.0)),
                      // padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.pin_drop_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 15.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(
                                  AppTranslations.of(context)
                                      .text('deliver_to'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: poppinsBold,
                                      fontSize: 13),
                                ),
                                Text(
                                  (FoodOrderModel()
                                              .getDeliveryAddress()
                                              ?.fullAddress !=
                                          null)
                                      ? FoodOrderModel()
                                          .getDeliveryAddress()
                                          .fullAddress
                                      : AppTranslations.of(context)
                                          .text('home_address_bar_placeholder'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: poppinsMedium,
                                      fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      getOperationgTime(),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Image.asset(
                              'images/avatar.png',
                              height: 60.0,
                              width: 60.0,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Flexible(
                            child: Text(
                              User().getUsername() ?? "Welcome",
                              style: kTitleTextStyle.copyWith(fontSize: 20),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      // SizedBox(
                      //   height: 20.0,
                      //   child: Divider(
                      //     color: Colors.grey,
                      //   ),
                      // ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 12.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            print(index);
                            String service = AppConfig.enabledOptions[index];

                            print(service);
                            return HaloServicesButton(
                              iconName: 'images/btn_' + service + '.png',
                              title: service,
                              onTap: () {
                                _serviceBtnPressed(service);
                              },
                              isEnable: true,
                            );
                          },
                          itemCount: AppConfig.enabledOptions.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                        ),
                      ),

                      Container(
                        // alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Text(
                            //   AppTranslations.of(context)
                            //       .text('whats_news_ques'),
                            //   style: TextStyle(
                            //       fontFamily: poppinsMedium,
                            //       fontSize: 18,
                            //       color: kColorRed),
                            //   textAlign: TextAlign.center,
                            // ),
                            // SizedBox(height: 20.0),
                            _buildWhatsNewWidget(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getOperationgTime() {
    if (AppConfig.operatingTime != null) {
      if (AppConfig.operatingTime.zone_online_status == "true") {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DatetimeFormatter.dateAmPmWithoutDate(
                    AppConfig.operatingTime.zone_open_time),
                style: TextStyle(
                    color: Colors.black, fontFamily: poppinsBold, fontSize: 13),
              ),
              Text(
                " - ",
                style: TextStyle(
                    color: Colors.black, fontFamily: poppinsBold, fontSize: 13),
              ),
              Text(
                DatetimeFormatter.dateAmPmWithoutDate(
                    AppConfig.operatingTime.zone_close_time),
                style: TextStyle(
                    color: Colors.black, fontFamily: poppinsBold, fontSize: 13),
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                "(Open)",
                style: TextStyle(
                    color: Colors.black, fontFamily: poppinsBold, fontSize: 13),
              ),
            ],
          ),
        );
      } else {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DatetimeFormatter.dateAmPmWithoutDate(
                    AppConfig.operatingTime.zone_open_time),
                style: TextStyle(
                    color: Colors.black, fontFamily: poppinsBold, fontSize: 13),
              ),
              Text(
                " - ",
                style: TextStyle(
                    color: Colors.black, fontFamily: poppinsBold, fontSize: 13),
              ),
              Text(
                DatetimeFormatter.dateAmPmWithoutDate(
                    AppConfig.operatingTime.zone_close_time),
                style: TextStyle(
                    color: Colors.black, fontFamily: poppinsBold, fontSize: 13),
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                "(Close)",
                style: TextStyle(
                    color: Colors.black, fontFamily: poppinsBold, fontSize: 13),
              ),
            ],
          ),
        );
      }
    }

    return Container();
  }
}

class HaloServicesButton extends StatelessWidget {
  final String iconName;
  final String title;
  final Function onTap;
  final bool isEnable;

  const HaloServicesButton({
    Key key,
    @required this.iconName,
    @required this.title,
    @required this.onTap,
    @required this.isEnable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            iconName,
            height: 50.0,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace stackTrace) {
              return Image.asset(
                "images/btn_box.png",
                width: 90,
              );
            },
          ),
          SizedBox(height: 10.0),
          Text(
            AppTranslations.of(context).text(title),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kColorRed,
              fontFamily: poppinsMedium,
              fontSize: 11,
            ),
          ),
          (!isEnable)
              ? Text(
                  AppTranslations.of(context).text('coming_soon'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: poppinsItalic,
                      fontSize: 12,
                      color: Colors.redAccent),
                )
              : Container()
        ],
      ),
    );
  }
}
