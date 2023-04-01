import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/search_bar_input.dart';
import 'package:haloapp/components_new/food_type_container.dart';
import 'package:haloapp/components_new/custom_back_button.dart';
import 'package:haloapp/components_new/custom_sliver_app_bar_food.dart';
import 'package:haloapp/components_new/horizontal_order_history.dart';
import 'package:haloapp/components_new/shop_card.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/google_places_component_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/food_history_networking.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/networkings/home_networking.dart';
import 'package:haloapp/screens/boarding/login_page.dart';
import 'package:haloapp/screens/food/food_delivery_address_page.dart';
import 'package:haloapp/screens/food/food_rating_popup.dart';
import 'package:haloapp/screens/food/shop_menu_page.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/screens/general/custom_alert_dialog.dart';
import 'package:haloapp/screens/general/find_address_page.dart';
import 'package:haloapp/screens/main/food_cart_page.dart';
import 'package:haloapp/screens/main/shop_list_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/debouncer.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:huawei_location/location/location.dart';

class FoodMainPage extends StatefulWidget {
  static const String id = 'foodMainPage';

  @override
  _FoodMainPageState createState() => _FoodMainPageState();
}

class _FoodMainPageState extends State<FoodMainPage> {
  bool _showSpinner = true;
  AddressModel _currentAddress = FoodOrderModel().getDeliveryAddress();
  List<ShopModel> _shops = [];
  List<ShopModel> _allShops = [];
  List<String> _filters = [];

  String _selectedCategory = 'All';
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();

    if (_currentAddress?.lat == null)
      return setState(() {
        _showSpinner = false;
      });

    Future.wait([
      // _getUserLocation(),
      initAddress(),
      checkCompletedOrderToRate()
    ]).then((value) {
      setState(() {
        _showSpinner = false;
      });
    });
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _showSpinner = true;
    });
    print('getting location');
    Location position = await LocationService.getLastKnownLocation();

    bool locationPermissionGranted = await LocationService().checkPermission();
    if (!locationPermissionGranted) {
      showSimpleFlushBar(
          AppTranslations.of(context)
              .text('please_enable_location_service_in_phone_settings'),
          context);

      setState(() {
        _showSpinner = false;
      });
      return;
    }

    position = await LocationService.getLastKnownLocation();
    print('got location');

    if (position != null) {
      GooglePlacesComponentModel component = GooglePlacesComponentModel();
      component.lat = position.latitude;
      component.lng = position.longitude;
      storeAddressDetails(component, 'Current Location');
      await getNearbyShopList();
      setState(() {
        _showSpinner = false;
      });
    }

    return;
  }

  void storeAddressDetails(
      GooglePlacesComponentModel component, String fullAddress) {
    String street = '';
    if (component.street != null && component.street != '') {
      street = component.street;
    }

    if (component.route != null && component.route != '') {
      if (street != null && street != '') {
        street = street + ', ' + component.route;
      } else {
        street = component.route;
      }
    }

    AddressModel address = AddressModel(
      lat: component.lat.toString(),
      lng: component.lng.toString(),
      fullAddress: fullAddress,
      zip: component.zip,
      city: component.city,
      state: component.state,
      street: street,
    );
    _currentAddress = address;

    FoodOrderModel().setDeliverAddress(address);
    print(FoodOrderModel().getDeliveryAddress().street);
  }

  Future<void> getNearbyShopList([keyword]) async {
    print('### ' + FoodOrderModel().foodOption.shopType);
    print('getSHOP at:');
    // print(_currentAddress.lat);
    // print(_currentAddress.lng);
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "lat": _currentAddress != null ? _currentAddress.lat : 0.0,
        "lng": _currentAddress != null ? _currentAddress.lng : 0.0,
        "shopType": FoodOrderModel().foodOption.shopType
      }
    };
    if (keyword != null) params['data']['keyword'] = keyword;
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().getNearbyShops(params);
      // if(data.length == 0) return;
      // if(data.length <= 0) return;
      setState(() {
        _shops = data;
        _allShops = data;

        _filters = data
            .fold<List<String>>(
              ["All"],
              (prev, element) => [...prev, ...element.category],
            )
            .toSet()
            .toList();
      });
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e.toString(), context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  Future<void> listOnRefresh() async {
    _selectedCategory = "All";
    getNearbyShopList();
  }

  Future<void> initAddress() async {
    await getNearbyShopList();
  }

  void editAddressOld() {
    print("_currentAddress ${_currentAddress}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDeliveryAddressPage(
          address: _currentAddress,
        ),
      ),
    ).then((value) {
      if (value != null && value == 'refresh') {
        print('refresh');
        AddressModel orderAddress = FoodOrderModel().getDeliveryAddress();

        setState(() {
          _currentAddress = AddressModel(
            lat: orderAddress.lat,
            lng: orderAddress.lng,
            fullAddress: orderAddress.fullAddress,
            zip: orderAddress.zip,
            city: orderAddress.city,
            state: orderAddress.state,
            street: orderAddress.street,
            buildingName: orderAddress.buildingName,
            unitNo: orderAddress.unitNo,
          );

          getNearbyShopList();
        });
      }
    });
  }

  Future<void> checkCompletedOrderToRate() async {
    if (User().getAuthToken() == null) return;
    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodHistoryNetworking().getFoodOrderHistory({});

      setState(() {
        if (data is List<FoodHistoryModel>) {
          for (FoodHistoryModel history in data) {
            if (history.orderStatus == 'delivered' &&
                history.orderRating == '0') {
              showGoToRateDialog(history);
              return;
            }
          }
        }
      });
    } catch (e) {
      print(e.toString());
      if (mounted) showSimpleFlushBar(e.toString(), context);
    } finally {
      // if (mounted)
      setState(() {
        _showSpinner = false;
      });
    }

    return;
  }

  void showGoToRateDialog(FoodHistoryModel history) {
    showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
              title: AppTranslations.of(context).text('rate_our_service'),
              message: AppTranslations.of(context)
                  .text('there_is_completed_booking_to_rate'),
            )).then((value) {
      if (value != null && value == 'confirm') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodRatingPage(
              history: history,
            ),
          ),
        );
      }
    });
  }

  Widget renderFilter() {
    return SizedBox(
      height: 23,
      child: ListView.builder(
        padding: EdgeInsets.only(left: 16),
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
          onTap: () {
            print(" ${_filters[index]}");
            if (_filters[index] == "All")
              _shops = _allShops;
            else
              _shops = _allShops
                  .where((e) => e.category.contains(_filters[index]))
                  .toList();
            setState(() {
              _shops = _shops;
              _selectedCategory = _filters[index];
            });
          },
          child: Container(
            margin: EdgeInsets.only(right: 4),
            padding: EdgeInsets.symmetric(
              vertical: 1,
              horizontal: 5,
            ),
            decoration: BoxDecoration(
              color: _selectedCategory == _filters[index]
                  ? kColorLightRed
                  : Colors.white,
              border: Border.all(width: 1, color: Colors.white),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _filters[index],
              style: TextStyle(
                fontSize: 12,
                color: _selectedCategory == _filters[index]
                    ? Colors.white
                    : kColorLightRed,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void createOrder() async {
    if (User().getAuthToken() == null) {
      Navigator.pushNamed(context, LoginPage.id);
      return;
    }

    if (FoodOrderModel().getOrderCart().length < 1) {
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Inform',
          message: 'There is not item in the cart',
        ),
      );
      return;
    }

    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": FoodOrderModel().getCreateOrderParam()
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().createOrder(params);

      if (data) {
        _viewCartPopup();
      }
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  _viewCartPopup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodCartPage(shop: FoodOrderModel().getShop()),
      ),
    ).then((value) {
      if (value != null) {
        if (value is PopWithResults) {
          PopWithResults popResult = value;
          if (popResult.toPage == 'shopMenu') {
          } else {
            // pop to previous page
            Navigator.of(context).pop(value);
          }
        } else if (value == 'refresh') {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FoodOrderModel().foodOption.shopType == "donation"
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: IconButton(
                icon: arrowBack,
                onPressed: () => {Navigator.pop(context)},
              ),
              title: Text(
                AppTranslations.of(context).text('charity'),
                style: kAppBarTextStyle,
              ),
            ),
            body: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              child: ListView.builder(
                itemCount: _shops.length,
                itemBuilder: (BuildContext context, int index) {
                  return ShopCard(
                    shopType: FoodOrderModel().foodOption.shopType,
                    shop: _shops[index],
                    callbackMethod: () {
                      getNearbyShopList();
                      Future.delayed(Duration(seconds: 2), () {
                        print("3434 ${_shops[index].city}");
                      });
                    },
                  );
                },
              ),
            ),
          )
        : Scaffold(
            body: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              child: SafeArea(
                top: false,
                child: RefreshIndicator(
                  onRefresh: listOnRefresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: CustomSliverAppBarFoodDelegate(
                          expandedHeight:
                              MediaQuery.of(context).padding.top + 150,
                          topSafeArea: MediaQuery.of(context).padding.top + 100,
                          topChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    CustomBackButton(),
                                    Expanded(
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
                                            _currentAddress = FoodOrderModel()
                                                .getDeliveryAddress();
                                          await initAddress();
                                          await HomeNetworking.initAppConfig({
                                            "latitude": FoodOrderModel()
                                                .getDeliveryAddress()
                                                ?.lat,
                                            "longitude": FoodOrderModel()
                                                .getDeliveryAddress()
                                                ?.lng,
                                          });
                                          setState(() {
                                            _showSpinner = false;
                                          });
                                          // editAddress();
                                        },
                                        child: Text(
                                          (FoodOrderModel()
                                                      .getDeliveryAddress()
                                                      ?.fullAddress !=
                                                  null)
                                              ? FoodOrderModel()
                                                  .getDeliveryAddress()
                                                  .fullAddress
                                              : AppTranslations.of(context).text(
                                                  'home_address_bar_placeholder'),
                                          style: TextStyle(color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        createOrder();
                                      },
                                      icon: Stack(
                                        children: [
                                          Image.asset(
                                            'images/ic_cart.png',
                                            width: 36,
                                          ),
                                          ValueListenableBuilder<
                                                  List<FoodOrderCart>>(
                                              valueListenable: FoodOrderModel
                                                  .orderCartNotifier,
                                              builder: (BuildContext context,
                                                  List<FoodOrderCart> value,
                                                  Widget child) {
                                                print(value);
                                                if (value.length > 0) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors.black),
                                                    ),
                                                    alignment: Alignment.center,
                                                    width: 16,
                                                    height: 16,
                                                    child: Text(
                                                      value.length.toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              })
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SearchBarInput(
                                  onChange: (key) {
                                    _debouncer
                                        .run(() => getNearbyShopList(key));
                                  },
                                  isAutoFocus: true),
                              renderFilter(),
                            ],
                          ),
                          botChild: null,
                          // botChild: Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     FoodTypeContainer(
                          //       foodOptions: AppConfig.foodOptions,
                          //       titleColor: Colors.white,
                          //       onClickIcon: (foodOptions) {
                          //         FoodOrderModel().foodOption = foodOptions;
                          //         Navigator.pushNamed(context, ShopListPage.id);
                          //       },
                          //     )
                          //   ],
                          // ),
                        ),
                      ),
                      if (AppConfig.histories.length > 0)
                        SliverToBoxAdapter(
                          child: HorizontalOrderList(
                            orders: AppConfig.histories,
                          ),
                        ),
                      _shops != null && _shops.length > 0
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return ShopCard(
                                    shopType:
                                        FoodOrderModel().foodOption.shopType,
                                    shop: _shops[index],
                                    callbackMethod: () {
                                      getNearbyShopList();
                                      Future.delayed(Duration(seconds: 2), () {
                                        print("3434 ${_shops[index].city}");
                                      });
                                    },
                                  );
                                },
                                childCount: _shops.length, // 1000 list items
                              ),
                            )
                          : SliverToBoxAdapter(
                              child: Center(
                                child: Text(AppTranslations.of(context)
                                    .text('no_shop_nearby')),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
