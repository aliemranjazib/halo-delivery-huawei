import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';

import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components_new/banner_slider.dart';
import 'package:haloapp/components_new/custom_sliver_app_bar.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/components_new/food_type_container.dart';
import 'package:haloapp/components_new/horizontal_merchant_card.dart';
import 'package:haloapp/components_new/horizontal_merchant_card2.dart';
import 'package:haloapp/components_new/news_container.dart';
import 'package:haloapp/components_new/horizontal_card.dart';
import 'package:haloapp/components_new/horizontal_order_history.dart';
import 'package:haloapp/components/search_bar_input.dart';
import 'package:haloapp/components_new/service_button_container.dart';

import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/promo_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/food_history_networking.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/networkings/home_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/screens/boarding/location_access_page.dart';
// import 'package:haloapp/screens/delivery/delivery_main_page.dart';
import 'package:haloapp/screens/main/delivery_main_page.dart';
import 'package:haloapp/screens/food/food_main_page.dart';
import 'package:haloapp/screens/general/find_address_page.dart';
import 'package:haloapp/screens/general/language_selector_page.dart';
import 'package:haloapp/screens/main/food_history_details_page.dart';
import 'package:haloapp/screens/main/food_main_page.dart';
import 'package:haloapp/screens/main/shop_list_page.dart';
import 'package:haloapp/screens/main/shop_menu_page.dart';
import 'package:haloapp/screens/main/update_server_update.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/app_translations/application.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/utils/utils.dart';
import 'package:haloapp/widget/measure_size_widget.dart';
import 'package:huawei_location/location/location.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  static const String id = 'homePage';
  final TabController tabController;

  HomePage({this.tabController});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<int> _orders = [1, 2, 3, 4, 5, 6];
  ScrollController _controller = ScrollController();
  ScrollController _horizontalController = ScrollController();

  String _selectedLanguageCode = "";
  bool _showSpinner = true;
  List<PromoModel> _promos = [];

  // double coreServiceHeight = 100.0;
  List<ShopModel> _shops = [];
  List<ShopModel> _promoteItem = [];
  List<FoodHistoryModel> _foodHistories = [];
  FoodHistoryModel _onGoingFood;

  Object _err;
  StreamSubscription _sub;
  bool _initialUriIsHandled = false;

  @override
  void initState() {
    init();

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      resumeCallBack: () async {
        // if (User().getAuthToken() != null){
        //   var position = await LocationService.getLastKnownLocation();
        //   if(position!=null){
        if (FoodOrderModel().getDeliveryAddress() != null) {
          await HomeNetworking.initAppConfig({
            "latitude": FoodOrderModel().getDeliveryAddress().lat,
            "longitude": FoodOrderModel().getDeliveryAddress().lng,
          });
        } else {
          await HomeNetworking.initAppConfig();
        }

        if (AppConfig.isUnderMaintenance.value &&
            !AppConfig.isShowMaintenancePage) {
          AppConfig.isShowMaintenancePage = true;
          Navigator.pushNamed(context, UpdateServerPage.id);
        }
        // }

        // }
      },
    ));
    FoodOrderModel.deliverAddressNotifier.addListener(() {
      init();
    });

    _handleIncomingLinks();
    _handleInitialUri();
    super.initState();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  init() async {
    bool locationPermissionGranted = await LocationService().checkPermission();
    if (locationPermissionGranted) {
      await Future.wait([
        initiateLanguage(),
        if (User().getAuthToken() != null) loadNearbyAddress(),
        loadHomeInfo(),
        loadFoodHistory(),
        getNearbyPromoItem()
      ]);
    } else {
      await Navigator.pushNamed(context, LocationPage.id);
      init();
    }

    //Show loading if changing language
    SharedPrefService.isLoadingLanguage.addListener(() {
      if (SharedPrefService.isLoadingLanguage.value) {
        if (mounted) {
          _showSpinner = true;
          setState(() {});
        }
      } else {
        if (mounted) {
          _showSpinner = false;
          setState(() {});
        }
      }
    });
    if (mounted) {
      _showSpinner = false;
      setState(() {});
    }
  }

  Future<void> loadFoodHistory() async {
    if (User().getAuthToken() != null) {
      if (mounted) {
        setState(() {
          _showSpinner = true;
        });
      }

      try {
        var data = await FoodHistoryNetworking().getFoodOrderHistory({});

        print("DATA -- $data");
        setState(() {
          if (data is List<FoodHistoryModel>) {
            _foodHistories = data;

            try {
              _onGoingFood = data.firstWhere((element) =>
                  element.orderStatus == 'ontheway' ||
                  element.orderStatus == 'pickedUp ' ||
                  element.orderStatus == 'started');
            } catch (e) {
              print(e);
            }
          }
        });
      } catch (e) {
        if (mounted) {
          showSimpleFlushBar(e.toString(), context);
        }
      } finally {
        if (mounted) {
          setState(() {
            _showSpinner = false;
          });
        }
      }
    }
  }

  Future<void> initiateLanguage() async {
    String languageCode = await SharedPrefService().getLanguage();
    print('### ' + _selectedLanguageCode);
    var language = Application.languagesMap.keys.firstWhere(
        (k) => Application.languagesMap[k] == languageCode,
        orElse: () => null);
    if (mounted) {
      setState(() {
        _selectedLanguageCode = language != null ? language : languageCode;
      });
    }
  }

  void _handleIncomingLinks() {
    print('_handleIncomingLinks###############');
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    _sub = uriLinkStream.listen((Uri uri) {
      if (!mounted) return;
      if (uri != null) {
        String lastParamInUrl = uri.toString().split('/').last;
        print(lastParamInUrl);
        print('got uri: $uri');
        getShopDetails(lastParamInUrl);
      }
      // setState(() {
      //   _latestUri = uri;
      //   _err = null;
      // });
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
    });
  }

  Future<void> _handleInitialUri() async {
    print('_handleIncomingLinks###############');
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a widget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          print('got initial uri: $uri');
          String lastParamInUrl = uri.toString().split('/').last;
          print(lastParamInUrl);
          print('got uri: $uri');
          getShopDetails(lastParamInUrl);
        }
        if (!mounted) return;
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri');
        setState(() => _err = err);
      }
    }
  }

  Future getShopDetails(String codeUniqueCode) async {
    AddressModel orderAddress = FoodOrderModel().getDeliveryAddress();

    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "lng": orderAddress != null ? orderAddress.lat : '0',
        "lat": orderAddress != null ? orderAddress.lng : '0',
        "shopUniqueCode": codeUniqueCode,
      }
    };
    print(params);

    // setState(() {
    //   //_showSpinner = true;
    // });

    try {
      var data = await FoodNetworking().getShopDetails(params);

      ShopModel shop = data;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShopMenuPage(
            shopUniqueCode: shop.uniqueCode,
            shopInfo: shop,
          ),
        ),
      );

      return null;
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
      return null;
    } finally {
      // setState(() {
      //  // _showSpinner = false;
      // });
    }
  }

  _displayLanguageDialog() {
    showDialog(context: context, builder: (context) => LanguageSelectorPage())
        .then((value) {
      initiateLanguage();
    });
  }

  void checkLocationPermission() async {
    bool locationPermissionGranted = await LocationService().checkPermission();
  }

  Future<void> getNearbyShopList() async {
    print('getSHOP at home:');
    // print(FoodOrderModel().getDeliveryAddress()..lat);
    // print(FoodOrderModel().getDeliveryAddress()..lng);
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "lat": FoodOrderModel().getDeliveryAddress() != null
            ? FoodOrderModel().getDeliveryAddress().lat
            : 0.0,
        "lng": FoodOrderModel().getDeliveryAddress() != null
            ? FoodOrderModel().getDeliveryAddress().lng
            : 0.0,
      }
    };
    print(params);

    // setState(() {
    //   _showSpinner = true;
    // });

    try {
      var data = await FoodNetworking().getNearbyFeaturedShops(params);
      // if(data.length == 0) return;
      // if(data.length <= 0) return;
      setState(() {
        _shops = data;
      });
    } catch (e) {
      print(e.toString());
      if (mounted) {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _showSpinner = false;
        });
      }
    }
  }

  Future<void> getNearbyPromoItem() async {
    print('getSHOP at home:');
    // print(FoodOrderModel().getDeliveryAddress()..lat);
    // print(FoodOrderModel().getDeliveryAddress()..lng);
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "lat": FoodOrderModel().getDeliveryAddress() != null
            ? FoodOrderModel().getDeliveryAddress().lat
            : 0.0,
        "lng": FoodOrderModel().getDeliveryAddress() != null
            ? FoodOrderModel().getDeliveryAddress().lng
            : 0.0,
      }
    };
    print(params);

    // setState(() {
    //   _showSpinner = true;
    // });

    try {
      var data = await FoodNetworking().getNearbyPromoteItem(params);
      // if(data.length == 0) return;
      // if(data.length <= 0) return;
      setState(() {
        _promoteItem = data;
      });
    } catch (e) {
      // print(e.toString());
      if (mounted) {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _showSpinner = false;
        });
      }
    }
  }

  _serviceBtnPressed(String service) {
    // print("3333${service}");
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
        FoodOption foodOption = FoodOption(searchName: "", shopType: service);
        FoodOrderModel().foodOption = foodOption;
        Navigator.pushNamed(context, FoodMainPage.id);
        // Navigator.pushNamed(context, FindAddressPage.id);
        break;
    }
  }

  Future<void> loadHomeInfo() async {
    Map<String, dynamic> params = {};
    if (FoodOrderModel().getDeliveryAddress() != null) {
      params = {
        "apiKey": APIUrls().getFoodApiKey(),
        'lat': FoodOrderModel().getDeliveryAddress().lat.toString(),
        'lng': FoodOrderModel().getDeliveryAddress().lng.toString()
      };
    } else {
      Location position = await LocationService.getLastKnownLocation();
      params = {
        "apiKey": APIUrls().getFoodApiKey(),
        if (position != null && position.latitude != null) ...{
          'lat': position.latitude.toString(),
          'lng': position.longitude.toString()
        }
      };
    }
    // Position position = await LocationService.getLastKnownLocation();
    // Map<String, dynamic> params = {
    //   "apiKey": APIUrls().getFoodApiKey(),
    //   if (position != null && position.latitude != null) ...{
    //     'lat': position.latitude.toString(),
    //     'lng': position.longitude.toString()
    //   }
    // };

    try {
      var data = await HomeNetworking().getHomeInfo(params);

      setState(() {
        _promos = data;
      });
    } catch (e) {
      print(e.toString());
      if (mounted) {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _showSpinner = false;
        });
      }
    }
  }

  Future<void> loadNearbyAddress() async {
    if (FoodOrderModel().getDeliveryAddress() == null) {
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
          // 'latitude': 3.249357,
          // 'longitude': 102.4163103,
        });

        if (AppConfig.isUnderMaintenance.value &&
            !AppConfig.isShowMaintenancePage) {
          AppConfig.isShowMaintenancePage = true;
          Navigator.pushNamed(context, UpdateServerPage.id);
        }
        // afterSave('saved');
      }
    } else if (FoodOrderModel().getDeliveryAddress() != null) {
      await HomeNetworking.initAppConfig({
        "latitude": FoodOrderModel().getDeliveryAddress().lat,
        "longitude": FoodOrderModel().getDeliveryAddress().lng,
        // 'latitude': 3.249357,
        // 'longitude': 102.4163103,
      });

      if (AppConfig.isUnderMaintenance.value &&
          !AppConfig.isShowMaintenancePage) {
        AppConfig.isShowMaintenancePage = true;
        Navigator.pushNamed(context, UpdateServerPage.id);
      }
    }

    //getNearbyPromoItem();
    getNearbyShopList();
    if (mounted) {
      setState(() {});
    }
  }

  _buildWhatsNewWidget() {
    List<Widget> promoViews = [];

    if (_promos.length > 0) {
      promoViews.add(Container(
        padding: EdgeInsets.only(left: 0.0, bottom: 6.0),
        child: Text(
          AppTranslations.of(context).text('my_news'),
          style: kTitleBoldTextStyle,
        ),
      ));
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
                    height: (MediaQuery.of(context).size.width - 20.0) / 3,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _onGoingFood != null
          ? GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FoodHistoryDetailsPage(history: _onGoingFood),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.white,
                    boxShadow: [elevation]),
                child: Row(
                  children: [
                    Image.asset(
                      "images/ic_bell.png",
                      width: 30.0,
                      height: 30.0,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppTranslations.of(context).text('on_going_order'),
                        style: TextStyle(fontFamily: poppinsRegular),
                      ),
                    )
                  ],
                ),
              ))
          : null,
      body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: CustomSliverAppBarDelegate(
                      expandedHeight: (AppConfig.operatingTime != null
                          ? 260 - 55.0
                          : 210 - 70.0),
                      topSafeArea: kToolbarHeight,
                      topChild: Container(
                        padding: EdgeInsets.only(top: kTextTabBarHeight - 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Image.asset(
                                    'images/haloje_title.png',
                                    width: 100,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          _displayLanguageDialog();
                                        },
                                        child: Container(
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                Application()
                                                    .getLanguageShortName(
                                                        _selectedLanguageCode)
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: poppinsRegular,
                                                    fontSize: 16),
                                              ),
                                              Icon(
                                                Icons.arrow_drop_down_rounded,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Utils.getEnvironment()
                                  ],
                                ),
                              ],
                            ),
                            // Input search Bar
                            // SearchBarInput(
                            //   isAutoFocus: false,
                            //   onTap: () {
                            //     FoodOption foodOption = FoodOption(
                            //         searchName: AppTranslations.of(context)
                            //             .text("food"),
                            //         shopType: "food");
                            //     FoodOrderModel().foodOption = foodOption;
                            //     Navigator.pushNamed(context, ShopListPage.id);
                            //   },
                            // ),
                            GestureDetector(
                              onTap: () {},
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5.0),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [elevation],
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _showSpinner = true;
                                    });
                                    await Navigator.pushNamed(
                                        context, FindAddressPage.id,
                                        arguments: {'popMode': true});
                                    FoodOrderModel().clearFoodOrderData();

                                    if (FoodOrderModel()
                                            .getDeliveryAddress()
                                            ?.lat !=
                                        null)
                                      await HomeNetworking.initAppConfig({
                                        "latitude": FoodOrderModel()
                                            .getDeliveryAddress()
                                            .lat,
                                        "longitude": FoodOrderModel()
                                            .getDeliveryAddress()
                                            .lng,
                                      });

                                    await getNearbyShopList();
                                    if (mounted) {
                                      setState(() {
                                        _showSpinner = false;
                                      });
                                    }
                                    // editAddress();
                                  },
                                  child: ValueListenableBuilder<AddressModel>(
                                    valueListenable:
                                        FoodOrderModel.deliverAddressNotifier,
                                    builder: (BuildContext context,
                                        AddressModel value, Widget child) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'images/ic_pin_location.png',
                                            width: 25.0,
                                            height: 25.0,
                                          ),
                                          SizedBox(width: 10.0),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.5,
                                            child: Text(
                                              (value?.fullAddress != null)
                                                  ? value.fullAddress
                                                  : AppTranslations.of(context)
                                                      .text(
                                                          'home_address_bar_placeholder'),
                                              style: kTitleBoldTextStyle,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            if (AppConfig.operatingTime != null)
                              getOperationgTime(),
                          ],
                        ),
                      )),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Visibility(
                          visible: (AppConfig.promoTextStatus == 'true')
                              ? true
                              : false,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            width: double.infinity,
                            color: kColorLightRed5.withOpacity(0.2),
                            child: Row(
                              children: [
                                Image.asset(
                                  'images/ic_megaphone.png',
                                  width: 50.0,
                                  height: 50.0,
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: Text(
                                    AppConfig.promoText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: kColorRed),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // Service Container
                        if (AppConfig.promoBanner.length != 0)
                          BannerSlider(
                            promoBanner: AppConfig.promoBanner,
                          ),
                        if (AppConfig.services != null)
                          Container(
                            child: MeasureSize(
                              onChange: (Size size) {
                                // setState(() {
                                //   coreServiceHeight = size.height;
                                // });
                              },
                              child: ServiceButtonContainer(
                                services: AppConfig.services,
                                onServiceClick: _serviceBtnPressed,
                              ),
                            ),
                            margin: EdgeInsets.only(top: 3.0),
                          ),
                        getWidget(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget getWidget() {
    List<Widget> widgets = [];

    for (var i = 0; i < AppConfig.consumerConfig.servicesPos.length; i++) {
      switch (AppConfig.consumerConfig.servicesPos[i]) {
        case "craving":
          if (AppConfig.foodOptions != null &&
              AppConfig.foodOptions.length > 0) {
            // what are you craving for
            widgets.add(Container(
              margin: EdgeInsets.only(top: 5),
              child: FoodTypeContainer(
                foodOptions: AppConfig.foodOptions,
                onClickIcon: (foodOptions) {
                  FoodOrderModel().foodOption = foodOptions;
                  Navigator.pushNamed(context, ShopListPage.id);
                },
              ),
            ));
          }
          break;

        case "featured":
          if (_shops != null && _shops.length > 0) {
            widgets.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.only(left: 10.0, bottom: 6.0),
                  child: Text(AppTranslations.of(context).text('feature_shop'),
                      style: kTitleBoldTextStyle),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10.0),
                  height: 90.0 + 60.0,
                  child: ListView.separated(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _shops.length,
                    itemBuilder: (BuildContext context, int index) =>
                        HorizontalMerchantCard2(
                      headerImgUrl: _shops[index].headerImgUrl,
                      logoUrl: _shops[index].logoUrl,
                      shopInfo: _shops[index],
                      cardHeight: 90.0,
                      cardWidth: 90.0,
                      isHideShowFeatureTag: true,
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopMenuPage(
                              shopUniqueCode: _shops[index].uniqueCode,
                              shopInfo: _shops[index],
                            ),
                          ),
                        );
                      },
                    ),
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        width: 6.0,
                      );
                    },
                  ),
                ),
              ],
            ));
          }
          break;

        case "promo_item":
          if (_promoteItem != null && _promoteItem.length > 0) {
            widgets.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.only(left: 10.0, bottom: 6.0),
                  child: Text(AppTranslations.of(context).text('super_jimat'),
                      style: kTitleBoldTextStyle),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10.0),
                  height: 90.0 + 60.0,
                  child: ListView.separated(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _promoteItem.length,
                    itemBuilder: (BuildContext context, int index) =>
                        HorizontalMerchantCard2(
                      headerImgUrl: _promoteItem[index].headerImgUrl,
                      logoUrl: _promoteItem[index].logoUrl,
                      shopInfo: _promoteItem[index],
                      cardHeight: 90.0,
                      cardWidth: 90.0,
                      isHideShowFeatureTag: true,
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopMenuPage(
                              shopUniqueCode: _promoteItem[index].uniqueCode,
                              shopInfo: _promoteItem[index],
                            ),
                          ),
                        );
                      },
                    ),
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        width: 6.0,
                      );
                    },
                  ),
                ),
              ],
            ));
          }
          break;

        case "order_again":
          if (AppConfig.histories != null && AppConfig.histories.length > 0) {
            widgets.add(HorizontalOrderList(
              orders: AppConfig.histories,
              controller: _horizontalController,
            ));
          }
          break;

        case "mynews":
          widgets.add(Container(
            padding: EdgeInsets.symmetric(
              vertical: 0.0,
              horizontal: 10.0,
            ),
            child: _buildWhatsNewWidget(),
          ));
          break;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget getOperationgTime() {
    // if (AppConfig.operatingTime.zone_online_status == "true") {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [elevation],
        ),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                AppTranslations.of(context).text('open'),
                style: kTitleBoldTextStyle,
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                DatetimeFormatter.dateAmPmWithoutDate(
                    AppConfig.operatingTime.zone_open_time),
                style: kTitleBoldTextStyle,
              ),
              Text(
                " - ",
                style: kTitleBoldTextStyle,
              ),
              Text(
                DatetimeFormatter.dateAmPmWithoutDate(
                    AppConfig.operatingTime.zone_close_time),
                style: kTitleBoldTextStyle,
              ),
              Visibility(
                visible:
                    AppConfig.operatingTime.zone_remark != '' ? true : false,
                child: Text(
                  AppConfig.operatingTime.zone_remark,
                  style: kTitleBoldTextStyle,
                ),
              ),
              if (AppConfig.operatingTime.zone_raining_icon_status == "show")
                Container(
                    margin: EdgeInsets.only(left: 6.0),
                    child: Image.asset(
                      "images/ic_raining.png",
                      width: 20.0,
                      height: 20.0,
                    ))
            ],
          ),
        ),
      ),
    );
    // } else {
    //   return GestureDetector(
    //     onTap: (){
    //
    //     },
    //     behavior: HitTestBehavior.opaque,
    //     child: Container(
    //       width: MediaQuery.of(context).size.width,
    //       margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5.0),
    //       padding: EdgeInsets.symmetric(vertical: 10),
    //       decoration: BoxDecoration(
    //         color: Colors.white,
    //         borderRadius: BorderRadius.all(Radius.circular(10)),
    //         boxShadow: [elevation],
    //       ),
    //       child: Center(
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Text(
    //               AppTranslations.of(context).text('open'),
    //               style: kTitleBoldTextStyle,
    //             ),
    //             SizedBox(
    //               width: 6,
    //             ),
    //             Text(
    //               DatetimeFormatter.dateAmPmWithoutDate(
    //                   AppConfig.operatingTime.zone_open_time),
    //               style: kTitleBoldTextStyle,
    //             ),
    //             Text(
    //               " - ",
    //               style: kTitleBoldTextStyle,
    //             ),
    //             Text(
    //               DatetimeFormatter.dateAmPmWithoutDate(
    //                   AppConfig.operatingTime.zone_close_time),
    //               style: kTitleBoldTextStyle,
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}
