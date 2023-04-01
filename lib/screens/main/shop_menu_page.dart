import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components_new/date_time_selection_view.dart';
import 'package:haloapp/components_new/shop_info_card.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/food_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/food_variant_model.dart';
import 'package:haloapp/models/order_for_later_model.dart';
import 'package:haloapp/models/payment_method_model.dart';
import 'package:haloapp/models/shop_menu_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/screens/auth/login_page.dart';
import 'package:haloapp/screens/general/find_address_page.dart';
import 'package:haloapp/screens/main/food_cart_page.dart';
import 'package:haloapp/screens/main/food_variant_details_popup.dart';
import 'package:haloapp/screens/main/ramadan/order_response_model.dart';
import 'package:haloapp/screens/main/ramadan/ramadan_payment.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/debouncer.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/widget/measure_size_widget.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:http/http.dart' as http;

class ShopMenuPageReturnResult {
  bool isFav;
  String shopUniqueCode;

  ShopMenuPageReturnResult(this.isFav, this.shopUniqueCode);
}

class ShopMenuPage extends StatefulWidget {
  ShopMenuPage({@required this.shopUniqueCode, this.shopType, this.shopInfo});

  final String shopUniqueCode;
  ShopModel shopInfo;
  String shopType;

  @override
  _ShopMenuPageState createState() => _ShopMenuPageState();
}

class _ShopMenuPageState extends State<ShopMenuPage>
    with SingleTickerProviderStateMixin {
  bool _showSpinner = true;
  bool _allowOrderAfterShopClose = false;
  bool _scrollDetection = false;
  List<ShopMenuModel> _shopMenu = [];
  List<FoodModel> _foods = [];

  TabController _tabController;
  AutoScrollController _scrollController;
  double _scrollOffset = 0;
  int _currentScrollIndex = 0;
  bool isMeasured = false;
  bool _shopFav = false;
  bool _notInAreaStatus = false;
  var _keys = {};
  var listViewKey = RectGetter.createGlobalKey();
  Size shopWidget = Size(400.0, 140.0);
  bool isUpdate = false;
  String _selectedBookDate;
  String _selectedBookTime;
  AddressModel orderAddress = FoodOrderModel().getDeliveryAddress();

  @override
  void initState() {
    super.initState();
    // print("mylat ${orderAddress.lat}");
    _scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical)
      ..addListener(() {});

    getShopDetails();
    isUpdate = false;
  }

  bool isPress = false;
  String foodPrice = "";
  String foodId = "";

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void getShopDetails() async {
    AddressModel orderAddress = FoodOrderModel().getDeliveryAddress();
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "shopUniqueCode": widget.shopUniqueCode,
        "lat": orderAddress != null ? orderAddress.lat : '0',
        "lng": orderAddress != null ? orderAddress.lng : '0'
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().getShopDetails(params);
      _tabController = TabController(vsync: this, length: data.shopMenu.length);
      _scrollDetection = true;
      setState(() {
        widget.shopInfo = data;
        _shopMenu = data.shopMenu;
        _allowOrderAfterShopClose = data.shopClosePreOrder;
        _showSpinner = false;
        _shopFav = data.shopUserFavourite;
        _notInAreaStatus = data.notInAreaStatus;
        FoodOrderModel()
            .setDeliveryInterval(int.tryParse(data.shopDeliveryInterval));
        FoodOrderModel().setAvailableDates(data.availableDates);
      });
      if (_allowOrderAfterShopClose) {
        _initiateSelectedDateAndTime();
        OrderForLaterModel().selectedDate = _selectedBookDate;
        OrderForLaterModel().selectedTime = _selectedBookTime;
        OrderForLaterModel().orderForLater = data.shopClosePreOrder;
        await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => StatefulBuilder(builder: (context, setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 10.0,
                            ),
                            color: Colors.white,
                            child: DateTimeSelectionView(
                              dateTitle: AppTranslations.of(context)
                                  .text('delivery_date'),
                              timeTitle: AppTranslations.of(context)
                                  .text('delivery_time'),
                              dateSelections:
                                  FoodOrderModel().getAvailableDates(),
                              timeSelections: getTimesForSelectedDate(),
                              interval: FoodOrderModel().getDeliveryInterval(),
                              onDateSelected: (date) {
                                setState(() {
                                  _selectedBookDate = date;
                                  OrderForLaterModel().selectedDate = date;
                                });
                              },
                              onTimeSelected: (time) {
                                setState(() {
                                  _selectedBookTime = time;
                                  OrderForLaterModel().selectedTime = time;
                                });
                              },
                              selectedDate: _selectedBookDate,
                              selectedTime: _selectedBookTime,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 10.0,
                            ),
                            child: ActionButton(
                              buttonText:
                                  AppTranslations.of(context).text('confirm'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }));
      } else {
        OrderForLaterModel().orderForLater = false;
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  _foodItemOnPressed(ShopMenuModel menu, FoodModel food) {
    // print(food.);
    if (food.status &&
        menu.categoryStatus &&
        (widget.shopInfo.shopStatus == 'open' || _allowOrderAfterShopClose)) {
      _proceedToFoodVariantsPage(food, null);
    }
  }

  _proceedToFoodVariantsPage(
      FoodModel food, List<FoodVariantItemModel> orderVariants) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodVariantDetailsPopup(
          food: food,
          shop: widget.shopInfo,
          prevOrderedFoodVariants: orderVariants,
        ),
      ),
    ).then((value) {
      if (value != null && value == 'refresh') {
        setState(() {});
      }
    });
  }

////////////

  Future<OrderResponse> redeemPoints(String foodId, String foodPrice) async {
    print(
        "unique code ${orderAddress.lat},${orderAddress.lng},${orderAddress.fullAddress},${orderAddress.zip},");
    OrderResponse orderResponse;
    try {
      setState(() {
        _showSpinner = true;
      });

      var headers = {
        'Authorization': '${User().getAuthToken()}',
        'Content-Type': 'application/json; charset=UTF-8',
      };
      http.Response response = await http.post(
          Uri.parse('https://foodapi.halo.express/Consumer/order/create'),
          headers: headers,
          body: json.encode({
            "apiKey": APIUrls().getFoodApiKey(),
            "data": {
              "lat": "${orderAddress.lat}",
              "lng": "${orderAddress.lng}",
              "note": "whatsapp before delivery",
              "fullAddress": "${orderAddress.fullAddress}",
              "buildingName": "",
              "buildingUnit":
                  "pos 43 batu 3 jalan masjid parit bunga, Tangkak, Johor",
              "street": "",
              "zip": "${orderAddress.zip}",
              "city": "${orderAddress.city}",
              "state": "",
              "orderCart": [
                {
                  "foodId": "$foodId",
                  "quantity": "1",
                  "options": [],
                  "remark": ""
                }
              ],
              "shopUniqueCode": "${widget.shopUniqueCode}",
              "orderUniqueKey": DateTime.now().millisecondsSinceEpoch,
              "paymentMethod": null
            }
          }));

      switch (response.statusCode) {
        case 200:
          Map<String, dynamic> data = json.decode(response.body);
          print(data['response']['orderUniqueKey']);
          print(response.statusCode);
          List payments = data['response']['paymentMethodWithIcon'];
          List<PaymentMethodWithIcon> pp = payments
              .map(
                (e) => PaymentMethodWithIcon.fromJson(e),
              )
              .toList();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RamadanPayment(
                        pMethods: pp,
                        price: foodPrice,
                        orderUniqueKey: data['response']['orderUniqueKey'],
                      )));
          print(pp.first.methodDisplayName);

          // Response rr = Response.fromJson(data['response']);
          // print(rr);
          // orderResponse = OrderResponse.fromJson(data);

          // pm = PointsModel.fromJson(data);

          setState(() {
            _showSpinner = false;
          });

          break;
        case 400:
          print(response.statusCode);

          break;
        case 514:
          print(response.statusCode);

          break;
        case 500:
          print(response.statusCode);

          break;
        case 504:
          print(response.statusCode);

          break;
        default:
          print("something error");
      }
    } catch (e) {
      setState(() {
        _showSpinner = false;
      });
    }
    return orderResponse;
  }

  _donfoodItemOnPressed(ShopMenuModel menu, FoodModel food) {
    // print(food.);
    if (food.status &&
        menu.categoryStatus &&
        (widget.shopInfo.shopStatus == 'open' || _allowOrderAfterShopClose)) {
      _donproceedToFoodVariantsPage(food, null);
    }
  }

  _donproceedToFoodVariantsPage(
      FoodModel food, List<FoodVariantItemModel> orderVariants) {
    FoodOrderModel().setShop(widget.shopInfo);
    FoodOrderModel().setOrderCart([]);
    setState(() {
      foodId = food.foodId;
      foodPrice = food.price;
      isPress = !isPress;
    });
    // print(foodId);
  }

  void createOrder() async {
    if (User().getAuthToken() == null) {
      Navigator.pushNamed(context, LoginPage.id);
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

  void toggleFavShop() async {
    print('toggle favorite shop');
    if (User().getAuthToken() == null) {
      Navigator.pushNamed(context, LoginPage.id);
      return;
    }

    Map<String, dynamic> params = {
      "data": {
        "shopUniqueCode": widget.shopUniqueCode,
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      if (_shopFav) {
        await FoodNetworking().removeFavShop(params);
      } else {
        await FoodNetworking().addFavShop(params);
      }

      setState(() {
        _shopFav = !_shopFav;
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

  _viewCartPopup() {
    print('shop: ');
    print(widget.shopInfo);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodCartPage(shop: widget.shopInfo),
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
    // print("8888${widget.shopType}");

    Widget _buildMenuFoodListInCategory(ShopMenuModel menu) {
      List<Widget> foodList = [];
      List<FoodModel> foods = menu.foods;

      for (int i = 0; i < foods.length; i++) {
        FoodModel food = foods[i];

        Widget itemView = GestureDetector(
          onTap: () {
            print("okkkk");
            // FoodOrderModel().add
            if (widget.shopType == "donation") {
              _donfoodItemOnPressed(menu, food);
              // checkPoints();
            } else {
              _foodItemOnPressed(menu, food);
            }
          },
          behavior: HitTestBehavior.translucent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                (food.imageUrl != '')
                    ? Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (_) => ImageDialog(
                                            imageUrl: food.imageUrl));
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: food.imageUrl,
                                    placeholder: (context, url) => Image.asset(
                                      "images/haloje_placeholder.png",
                                      width: 100,
                                      height: 100,
                                    ),
                                    //                                CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                    bottom: 0,
                                    // left: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (_) => ImageDialog(
                                                imageUrl: food.imageUrl));
                                      },
                                      child: Container(
                                        child: Icon(
                                          Icons.zoom_in,
                                          size: 30,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                        color: Colors.transparent,
                                      ),
                                    )),
                                food.imgPromoTag
                                    ? Positioned(
                                        top: 8.0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 3.0, horizontal: 8.0),
                                          color: kColorLightRed,
                                          child: Text(
                                            food.imgPromoTagText,
                                            style: TextStyle(
                                                fontFamily: poppinsMedium,
                                                fontSize: 11,
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          (!food.status ||
                                  !menu.categoryStatus ||
                                  (widget.shopInfo.shopStatus != 'open' &&
                                      !_allowOrderAfterShopClose))
                              ? Container(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 100,
                                  height: 100,
                                )
                              : Container()
                        ],
                      )
                    : Container(),
                SizedBox(width: 0.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        food.name,
                        style: (!food.status ||
                                !menu.categoryStatus ||
                                (widget.shopInfo.shopStatus != 'open' &&
                                    !_allowOrderAfterShopClose))
                            ? kDetailsTextStyle.copyWith(
                                color: Colors.grey[400])
                            : kDetailsTextStyle,
                      ),
                      SizedBox(height: 5.0),
                      food.description != ""
                          ? Text(
                              food.description,
                              // style: kDetailsTextStyle,
                            )
                          : Row(),
                      (!food.status || !menu.categoryStatus)
                          ? Text(
                              AppTranslations.of(context).text('not_available'),
                              style: kSmallLabelTextStyle.copyWith(
                                  fontFamily: poppinsMedium,
                                  color: Colors.grey[400]),
                            )
                          : Container()
                    ],
                  ),
                ),
                SizedBox(width: 10.0),
                Column(
                  children: [
                    Text(
                      '${AppTranslations.of(context).text('currency_my')} ${food.price}',
                      style: (!food.status ||
                              !menu.categoryStatus ||
                              (widget.shopInfo.shopStatus != 'open' &&
                                  !_allowOrderAfterShopClose))
                          ? TextStyle(
                                  decorationColor: Colors.red,
                                  decorationThickness: 2,
                                  decoration: food.priceDiscountStatus
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontFamily: poppinsSemiBold,
                                  fontSize: 16)
                              .copyWith(color: Colors.grey[400])
                          : TextStyle(
                              decorationColor: Colors.red,
                              decorationThickness: 2,
                              decoration: food.priceDiscountStatus
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontFamily: poppinsSemiBold,
                              fontSize: 16),
                    ),
                    Visibility(
                      visible: food.priceDiscountStatus ? true : false,
                      child: Text(
                        '${AppTranslations.of(context).text('currency_my')} ${food.priceDiscounted}',
                        style: (!food.status ||
                                !menu.categoryStatus ||
                                (widget.shopInfo.shopStatus != 'open' &&
                                    !_allowOrderAfterShopClose))
                            ? TextStyle(
                                    fontFamily: poppinsSemiBold, fontSize: 16)
                                .copyWith(color: Colors.grey[400])
                            : TextStyle(
                                    fontFamily: poppinsSemiBold, fontSize: 16)
                                .copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        foodList.add(itemView);

        if (i < foods.length - 1) {
          foodList.add(Divider(
            color: kColorRed.withOpacity(.5),
          ));
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: foodList,
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          bottomNavigationBar: widget.shopType == "donation"
              ? Visibility(
                  visible: foodPrice.isEmpty ? false : true,
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 15.0,
                        bottom:
                            MediaQuery.of(context).padding.bottom + marginBot),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        redeemPoints(foodId, foodPrice);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                            color: kColorRed,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(width: 8.0),
                                Text(
                                  AppTranslations.of(context).text('Donate'),
                                  style: TextStyle(
                                      fontFamily: poppinsMedium,
                                      fontSize: 15,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            Text(
                              '${AppTranslations.of(context).text('currency_my')} ${foodPrice ?? '0'}',
                              style: TextStyle(
                                  fontFamily: poppinsMedium,
                                  fontSize: 18,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : (FoodOrderModel().getOrderCart() != null &&
                      FoodOrderModel().getOrderCart().length > 0)
                  ? Container(
                      padding: EdgeInsets.only(
                          top: 15.0,
                          bottom: MediaQuery.of(context).padding.bottom +
                              marginBot),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          if (!_showSpinner) {
                            AddressModel orderAddress =
                                FoodOrderModel().getDeliveryAddress();
                            if (orderAddress == null) {
                              Navigator.pushNamed(context, FindAddressPage.id,
                                  arguments: {'popMode': true});
                            } else {
                              createOrder();
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                              color: kColorRed,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 25,
                                      minHeight: 25,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors.white,
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Text(
                                        '${FoodOrderModel().getOrderCart().length}',
                                        style: kDetailsTextStyle.copyWith(
                                            color: kColorRed, fontSize: 15),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    AppTranslations.of(context)
                                        .text('view_your_cart'),
                                    style: TextStyle(
                                        fontFamily: poppinsMedium,
                                        fontSize: 15,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Text(
                                '${AppTranslations.of(context).text('currency_my')} ${FoodOrderModel().getFoodFinalPrice() ?? '0'}',
                                style: TextStyle(
                                    fontFamily: poppinsMedium,
                                    fontSize: 18,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ))
                  : null,
          body: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            child: NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                if (!_scrollDetection) return true;

                setState(() {
                  int index = getFirstItem();

                  if (_currentScrollIndex != index) {
                    if (index != null) {
                      _currentScrollIndex = index;
                    }
                    _tabController.animateTo(_currentScrollIndex,
                        duration: Duration(milliseconds: 400));
                  }

                  _scrollOffset = _scrollController.offset;
                });
                return true;
              },
              child: RectGetter(
                key: listViewKey,
                child: Container(
                  padding: EdgeInsets.only(
                      top: _scrollOffset < 230
                          ? 0.0
                          : MediaQuery.of(context).padding.top + 35,
                      bottom: MediaQuery.of(context).padding.bottom),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: widget.shopInfo.shopTag.isNotEmpty
                              ? 350.0
                              : 330.0,
                          child: Stack(
                            children: [
                              (widget.shopInfo.headerImgUrl != '')
                                  ? CachedNetworkImage(
                                      width: MediaQuery.of(context).size.width,
                                      height: 230,
                                      imageUrl: widget.shopInfo.headerImgUrl,
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      width: MediaQuery.of(context).size.width,
                                      height: 230,
                                      imageUrl: widget.shopInfo.logoUrl,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                              Container(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top),
                                child: IconButton(
                                  icon: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(
                                        left: 8, right: 3, bottom: 5, top: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      size: 26,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(
                                        context,
                                        ShopMenuPageReturnResult(
                                            _shopFav, widget.shopUniqueCode));
                                  },
                                ),
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top),
                                child: IconButton(
                                  icon: Icon(
                                    _shopFav
                                        ? Icons.favorite
                                        : Icons.favorite_border_outlined,
                                    size: 30,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    toggleFavShop();
                                  },
                                ),
                              ),
                              Positioned(
                                top: 170,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: MeasureSize(
                                  onChange: (size) {
                                    print("size12 $size");
                                    if (!isUpdate) {
                                      setState(() {
                                        isUpdate = true;
                                        shopWidget = size;
                                      });
                                    }
                                  },
                                  child: ShopInfoCard(
                                    shop: widget.shopInfo,
                                    isShopInfo: false,
                                    shopType: widget.shopType,
                                    shopUniqueCode: widget.shopUniqueCode,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Visibility(
                          visible: _notInAreaStatus,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  'Out of delivery zone',
                                  style: TextStyle(
                                      fontFamily: poppinsBold,
                                      fontSize: 16,
                                      color: kColorRed),
                                ),
                                Spacer(),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  onPressed: () async {
                                    await Navigator.pushNamed(
                                        context, FindAddressPage.id,
                                        arguments: {'popMode': true});
                                    AddressModel orderAddress =
                                        FoodOrderModel().getDeliveryAddress();
                                    //TODO need to call api here because setState issue
                                    Map<String, dynamic> params = {
                                      "apiKey": APIUrls().getFoodApiKey(),
                                      "data": {
                                        "shopUniqueCode": widget.shopUniqueCode,
                                        "lat": orderAddress != null
                                            ? orderAddress.lat
                                            : '0',
                                        "lng": orderAddress != null
                                            ? orderAddress.lng
                                            : '0'
                                      }
                                    };
                                    var data = await FoodNetworking()
                                        .getShopDetails(params);
                                    setState(() {
                                      widget.shopInfo = data;
                                      _shopMenu = data.shopMenu;
                                      _notInAreaStatus = data.notInAreaStatus;
                                      _allowOrderAfterShopClose =
                                          data.shopClosePreOrder;
                                      _showSpinner = false;
                                      _shopFav = data.shopUserFavourite;
                                    });
                                  },
                                  color: kColorRed,
                                  textColor: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppTranslations.of(context)
                                            .text('change_address'),
                                        style: TextStyle(
                                          fontFamily: poppinsMedium,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            ShopMenuModel menu = _shopMenu[index];
                            _keys[index] = RectGetter.createGlobalKey();

                            return AutoScrollTag(
                              key: ValueKey(index),
                              controller: _scrollController,
                              index: index,
                              child: RectGetter(
                                key: _keys[index],
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 5.0,
                                        color: Colors.grey[100],
                                      ),
                                    ),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        menu.categoryName,
                                        style: kTitleTextStyle,
                                      ),
                                      SizedBox(height: 15.0),
                                      _buildMenuFoodListInCategory(menu),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _shopMenu.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!_showSpinner && _scrollOffset > 230)
          Positioned(
            left: 0.0,
            right: 0.0,
            child: AnimatedOpacity(
              opacity: _scrollOffset < 230 ? 0.0 : 1.0,
              duration: Duration(milliseconds: 100),
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                color: Colors.white,
                // height: 130,
                child: Material(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.pop(
                                    context,
                                    ShopMenuPageReturnResult(
                                        _shopFav, widget.shopUniqueCode));
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: EdgeInsets.only(left: 25, right: 25),
                              child: Text(
                                widget.shopInfo.shopName,
                                style: kAppBarTextStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: kColorRed,
                        // controller: _tabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black54,
                        onTap: (index) {
                          _scrollDetection = false;
                          Future.delayed(const Duration(milliseconds: 500), () {
                            // Here you can write your code
                            _scrollDetection = true;
                          });
                          _scrollController.scrollToIndex(index,
                              preferPosition: AutoScrollPosition.begin);
                        },
                        tabs: [
                          ..._shopMenu
                              .map((item) => Tab(text: item.categoryName)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<int> getVisible() {
    /// First, get the rect of ListView, and then traver the _keys
    /// get rect of each item by keys in _keys, and if this rect in the range of ListView's rect,
    /// add the index into result list.
    var rect = RectGetter.getRectFromKey(listViewKey);
    var _items = <int>[];
    _keys.forEach((index, key) {
      var itemRect = RectGetter.getRectFromKey(key);
      if (itemRect != null &&
          !(itemRect.top > rect.bottom || itemRect.bottom < rect.top))
        _items.add(index);
    });

    /// so all visible item's index are in this _items.
    return _items;
  }

  int getFirstItem() {
    var visibles = getVisible();
    return visibles.first;
  }

  int getLastItem() {
    var visibles = getVisible();
    return visibles.last;
  }

  List<dynamic> getTimesForSelectedDate() {
    for (Map<String, dynamic> date in FoodOrderModel().getAvailableDates()) {
      String dateStr = date.keys.first;

      if (_selectedBookDate == dateStr) {
        return date[dateStr];
      }
    }

    return [];
  }

  void _initiateSelectedDateAndTime() {
    List<dynamic> _availableDates = FoodOrderModel().getAvailableDates();
    if (_availableDates.length > 0) {
      Map<String, dynamic> firstDateObj = _availableDates[0];
      String firstDate = firstDateObj.keys.first;

      List<dynamic> timeList = firstDateObj[firstDate];

      if (timeList.length == 0) {
        firstDateObj = _availableDates[1];
        firstDate = firstDateObj.keys.first;
      }

      print('first date: $firstDate');
      setState(() {
        _selectedBookDate = firstDate;
        _selectedBookTime = firstDateObj[firstDate][0];
      });
    }
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  ShowImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.white,
        child: Image.network(imageUrl),
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  final String imageUrl;

  ImageDialog({this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      )),
    );
  }
}
