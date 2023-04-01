import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/components/remarks_textbox.dart';
import 'package:haloapp/components_new/address_icon.dart';
import 'package:haloapp/components_new/date_selection_view.dart';
import 'package:haloapp/components_new/date_time_selection_view.dart';
import 'package:haloapp/components_new/order_food_widget.dart';
import 'package:haloapp/components_new/payment_method_selection_box.dart';
import 'package:haloapp/components_new/payment_method_selection_dialog.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/banner_model.dart';
import 'package:haloapp/models/coupon_model.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/food_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/order_for_later_model.dart';
import 'package:haloapp/models/shop_menu_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/models/payment_method_model.dart';
import 'package:haloapp/networkings/ewallet_networking.dart';
import 'package:haloapp/networkings/food_history_networking.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/screens/boarding/login_page.dart';
import 'package:haloapp/screens/food/food_variant_details_popup.dart';
import 'package:haloapp/screens/general/banner_dialog.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/screens/general/custom_alert_dialog.dart';
import 'package:haloapp/screens/general/custom_buttons_dialog.dart';
import 'package:haloapp/screens/general/online_payment_page.dart';
import 'package:haloapp/screens/general/small_fee_dialog.dart';
import 'package:haloapp/screens/main/confirm_order_page.dart';
import 'package:haloapp/screens/main/ewallet_top_up_page.dart';
import 'package:haloapp/screens/main/food_history_details_page.dart';
import 'package:haloapp/screens/main/voucher_list_page.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/payment_method.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'dart:math' as math;

import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';

class FoodCartPage extends StatefulWidget {
  FoodCartPage({
    @required this.shop,
  });

  final ShopModel shop;

  @override
  _FoodCartPageState createState() => _FoodCartPageState();
}

class _FoodCartPageState extends State<FoodCartPage> {
  bool _showSpinner = false;
  String _validatedCouponCode = '';
  String _couponCodeTFValue;
  String _remarksTFValue;
  String _cartUserName = User().getUsername();
  String _cartUserEmail = User().getUserEmail();
  String _cartUserPhone = User().getUserPhone();

  String _selectedPaymentMethod = FoodOrderModel().getPaymentMethodSelected();
  String _selectedBookDate = '';
  String _selectedBookTime = '';
  Map _validatedCoupon = {};
  bool _forceSelectPaymentType = true;
  List<Coupon> _coupons = [];
  BannerModel _bannerModel = BannerModel();
  List<DynamicPaymentMethodModel> _paymentMethods = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showNoticeDialog();
      if (FoodOrderModel().getMinFee() != '0.00')
        showDialog(
            context: context,
            builder: (context) => SmallFeeAlertDialog(
                  title: AppTranslations.of(context).text("small_order_fee"),
                  message:
                      AppTranslations.of(context).text("small_order_fee_desc"),
                  buttonText: AppTranslations.of(context).text("proceed"),
                ));
    });
    super.initState();
    _initiateSelectedDateAndTime();

    _initCouponList();
    _initPaymentMethods();
    _initWalletBalance();
  }

  _initPaymentMethods() async {
    FoodOrderModel().getPaymentMethods().forEach((element) {
      _paymentMethods.add(DynamicPaymentMethodModel(
        name: element['method_name'],
        title: element['method_display_name'],
        image: element['method_icon_url'],
      ));
    });
  }

  _initWalletBalance() async {
    setState(() {
      _showSpinner = true;
    });

    Map<String, dynamic> params = {
      "data": {
        "userToken": User().getUserToken(),
      }
    };
    print(params);

    try {
      var data = await EwalletNetworking().getEwalletTransaction(params);
      setState(() {
        User().setEwalletTransaction(data);
      });
    } catch (e) {
      print(e.toString());
      if (e is Map<String, dynamic>) {
        if (e['status_code'] == 514) {
          SharedPrefService().removeLoginInfo();
          Navigator.popUntil(context, ModalRoute.withName(LoginPage.id));
        }
      } else {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void showNoticeDialog() async {
    Map<String, dynamic> params = {};

    try {
      _bannerModel = await UserNetworking().getReviewBanner(params);
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

  void _initiateSelectedDateAndTime() {
    if (OrderForLaterModel().orderForLater) {
      _selectedBookDate = OrderForLaterModel().selectedDate;
      _selectedBookTime = OrderForLaterModel().selectedTime;
    } else {
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

  _initCouponList() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "orderUniqueKey": FoodOrderModel().getOrderUniqueKey(),
        "preDate": _selectedBookDate,
        "preTime": _selectedBookTime,
      }
    };
    print(params);
    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().foodCouponList(params);
      _coupons = data;
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void validateCoupon() async {
    setState(() {
      _showSpinner = true;
    });
    print('halo');
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "orderUniqueKey": FoodOrderModel().getOrderUniqueKey(),
        "couponName": _couponCodeTFValue,
        "preDate": _selectedBookDate,
        "preTime": _selectedBookTime,
      }
    };

    Map data = await FoodNetworking().validateCoupon(params);
    print(data);
    if (data['status'] == 200) {
      _validatedCoupon = data['json']['return'];
    }

    showSimpleFlushBar(data['json']['msg'], context,
        isError: (data['status'] != 200));

    setState(() {
      _showSpinner = false;
    });
  }

  bool isInSufficientBalance() {
    return User().walletTransactionsResponse != null &&
        double.parse(User().walletTransactionsResponse.response.walletBalance) <
            double.parse(getFinalPrice());
  }

  /// Check whether applied coupon or not
  String getFinalPrice() {
    return ((_validatedCoupon.length > 0)
        ? _validatedCoupon['totalPrice']
        : FoodOrderModel().getFinalPrice());
  }

  double roundDouble(double value, int places) {
    double mod = math.pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  void _placeOrder() async {
    if (_selectedPaymentMethod == 'haloWallet' && isInSufficientBalance()) {
      var confirm = await showDialog(
          context: context,
          builder: (context) => CustomButtonAlertDialog(
                title: AppTranslations.of(context).text('insufficient_title'),
                message: AppTranslations.of(context).text('insufficient_desc'),
                buttonText: AppTranslations.of(context).text("cancel"),
                buttonOnClick: () {
                  Navigator.pop(context);
                },
                buttonText2: AppTranslations.of(context).text("top_up"),
                buttonOnClick2: () {
                  Navigator.pop(context, 'confirm');
                },
              ));
      if (confirm != "confirm") {
        return;
      }

      double requiredAmount = double.parse(FoodOrderModel().getFinalPrice()) -
          double.parse(
              User().walletTransactionsResponse.response.walletBalance);

      var isTopUp = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EwalletTopUpPage(
            requiredAmount: roundDouble(requiredAmount, 2),
          ),
        ),
      );

      if (isTopUp) {
        _initWalletBalance();
      }
      return;
    }

    if (AppConfig.consumerConfig.isConfirmOrderDelay) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmOrderPage(
            shop: widget.shop,
            couponCodeTFValue: _couponCodeTFValue,
            remarksTFValue: _remarksTFValue,
            cartUserEmail: _cartUserEmail,
            cartUserPhone: _cartUserPhone,
            cartUserName: _cartUserName,
            selectedBookDate: _selectedBookDate,
            selectedBookTime: _selectedBookTime,
            validatedCoupon: _validatedCoupon,
            paymentMethod: _paymentMethods
                .firstWhere((e) => e.name == _selectedPaymentMethod),
          ),
        ),
      );
    } else {
      _confirmOrder();
    }
  }

  void _confirmOrder() async {
    String validationError = '';
    validationError = (_cartUserPhone.length <= 0) ? 'Phone is required.' : '';
    validationError = (_cartUserEmail.length <= 0) ? 'Email is required.' : '';
//    validationError = (_cartUserName.length <= 0) ? 'Name is required.' : '';
    if (validationError.length > 0)
      return showSimpleFlushBar(validationError, context);

    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "couponName": _couponCodeTFValue ?? '',
        "orderUniqueKey": FoodOrderModel().getOrderUniqueKey(),
        "remark": _remarksTFValue ?? '',
        "paymentMethod": _selectedPaymentMethod,
        "userPhone": _cartUserPhone,
        "userEmail": _cartUserEmail,
        "userName": _cartUserName,
        "preDate": _selectedBookDate,
        "preTime": _selectedBookTime,
      },
    };
    print(params);
//    printWrapped(params.toString());

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().confirmOrder(params);

      if (data is Map<String, String>) {
        // Online payment
        proceedToOnlinePayment(data['paymentUrl']);
      } else {
        _showSuccessOrderPopup();
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

  void proceedToOnlinePayment(String paymentLink) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OnlinePaymentPage(paymentLink: paymentLink)),
    ).then((value) async {
      if (value != null && value == 'onlinePaymentSuccess') {
        _showSuccessOrderPopup();
      } else {
        Navigator.popUntil(context, ModalRoute.withName(TabBarPage.id));
        FoodOrderModel().clearFoodOrderData();
      }
    });
  }

  _showSuccessOrderPopup() async {
    FoodHistoryModel fhm =
        await FoodHistoryNetworking().getFoodOrderHistoryDetails({
      "data": {"orderUniqueKey": FoodOrderModel().getOrderUniqueKey()}
    });
    FoodOrderModel().clearFoodOrderData();
    Navigator.popUntil(context, ModalRoute.withName(TabBarPage.id));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                FoodHistoryDetailsPage(success: true, history: fhm)));
  }

  Future<FoodModel> getFoodDetails(FoodOrderCart order) async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": {
        "lng": FoodOrderModel().getDeliveryAddress().lng,
        "lat": FoodOrderModel().getDeliveryAddress().lat,
        "shopUniqueCode": FoodOrderModel().getShopUniqueCode(),
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().getShopDetails(params);

      ShopModel shop = data;

      for (ShopMenuModel menu in shop.shopMenu) {
        if (menu.foods.length > 0) {
          for (FoodModel food in menu.foods) {
            if (food.foodId == order.foodId) {
              return food;
            }
          }
        }
      }

      return null;
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
      return null;
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  _editOrder(FoodOrderCart order, int index) async {
    FoodModel food = await getFoodDetails(order);

    if (food != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodVariantDetailsPopup(
            food: food,
            shop: FoodOrderModel().getShop(),
            prevOrderedFoodVariants: order.options,
            editingIndex: index,
            remark: order.remark,
          ),
        ),
      ).then((value) {
        if (value != null && value == 'refresh') {
          if (FoodOrderModel().getOrderCart().length > 0) {
            print('yay');
            createOrder();
          } else {
            setState(() {});
          }
        }
      });
    } else {
      showSimpleFlushBar('Something went wrong', context);
    }
  }

  _deleteOrder(FoodOrderCart order, int index) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ConfirmationDialog(
              title: AppTranslations.of(context).text('remove_order_item'),
              message: AppTranslations.of(context)
                  .text('are_you_sure_to_remove_the_item_ques'),
            )).then((value) {
      if (value != null && value == 'confirm') {
        setState(() {
          FoodOrderModel().removeFoodFromCart(index);
        });
        createOrder();
      }
    });
  }

  void createOrder() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getFoodApiKey(),
      "data": FoodOrderModel().getCreateOrderParam()
    };
    print(params);

    setState(() {
      _couponCodeTFValue = '';
      _validatedCoupon = {};
      _showSpinner = true;
    });

    try {
      var data = await FoodNetworking().createOrder(params);

      if (data) {
        setState(() {});
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

  _openPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (context) => PaymentMethodSelectionDialog(
        bookingType: 'food',
        selectedMethod: _selectedPaymentMethod,
        onChanged: (value) {
          _selectedPaymentMethod = value;
          FoodOrderModel().setPaymentMethod(value);
          createOrder();
        },
      ),
    );
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
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  FoodOrderModel().getShopName() ?? '',
                  style: kTitleTextStyle.copyWith(fontSize: 15),
                ),
              ),
              Center(
                child: Text(
                  '${widget.shop.category.join(', ')} | ${widget.shop.distance.toStringAsFixed(1)} KM',
                  style: kSmallLabelTextStyle.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(
          //       Icons.chevron_left,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: SafeArea(
            bottom: false,
            child: (FoodOrderModel().getOrderCart().length == 0)
                ? Container(
                    padding: EdgeInsets.only(
                        left: 35.0,
                        right: 35.0,
                        top: 35.0,
                        bottom:
                            MediaQuery.of(context).padding.bottom + marginBot),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                          "images/ic_no_order.png",
                          width: 250.0,
                          height: 250.0,
                        ),
                        SizedBox(height: 30.0),
                        Text(
                          AppTranslations.of(context)
                              .text('no_order_in_your_cart'),
                          textAlign: TextAlign.center,
                          style: kTitleSemiBoldTextStyle,
                        ),
                        Spacer(),
                        ActionButton(
                          onPressed: () {
                            Navigator.pop(context, 'refresh');
                          },
                          buttonText: AppTranslations.of(context)
                              .text('back_to_food_menu'),
                        )
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            color: Colors.grey[100],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 10.0,
                                    ),
                                    color: Colors.white,
                                    child: widget.shop.showPreOrderStatus
                                        ? DateTimeSelectionView(
                                            dateTitle:
                                                AppTranslations.of(context)
                                                    .text('delivery_date'),
                                            timeTitle:
                                                AppTranslations.of(context)
                                                    .text('delivery_time'),
                                            dateSelections: FoodOrderModel()
                                                .getAvailableDates(),
                                            timeSelections:
                                                getTimesForSelectedDate(),
                                            interval: FoodOrderModel()
                                                .getDeliveryInterval(),
                                            onDateSelected: (date) {
                                              setState(() {
                                                _selectedBookDate = date;
                                                _couponCodeTFValue = '';
                                                _validatedCoupon = {};
                                              });
                                            },
                                            onTimeSelected: (time) {
                                              setState(() {
                                                _selectedBookTime = time;
                                                _couponCodeTFValue = '';
                                                _validatedCoupon = {};
                                              });
                                            },
                                            selectedDate: _selectedBookDate,
                                            selectedTime: _selectedBookTime,
                                          )
                                        : Container()
                                    // DateSelectionView(
                                    //   dateTitle: AppTranslations.of(context).text('delivery_date'),
                                    //   timeTitle: AppTranslations.of(context).text('delivery_time'),
                                    //   dateSelections: FoodOrderModel().getAvailableDates(),
                                    //   timeSelections: getTimesForSelectedDate(),
                                    //   interval: FoodOrderModel().getDeliveryInterval(),
                                    //   onDateSelected: (date) {
                                    //     setState(() {
                                    //       _selectedBookDate = date;
                                    //       _couponCodeTFValue = '';
                                    //       _validatedCoupon = {};
                                    //     });
                                    //   },
                                    //   onTimeSelected: (time) {
                                    //     setState(() {
                                    //       _selectedBookTime = '';
                                    //       _couponCodeTFValue = '';
                                    //       _validatedCoupon = {};
                                    //     });
                                    //   },
                                    //   selectedDate: _selectedBookDate,
                                    //   selectedTime: '',)
                                    ),
                                Visibility(
                                  visible:
                                      FoodOrderModel().getOverTimeStatus() ==
                                              'true'
                                          ? true
                                          : false,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 10.0,
                                    ),
                                    color: Colors.white,
                                    child: Text(
                                      AppTranslations.of(context).text(
                                          'delivery_may_take_longer_time'),
                                      style: TextStyle(
                                          color: kColorRed,
                                          fontFamily: poppinsMedium,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20.0),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                    vertical: 10.0,
                                  ),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        AppTranslations.of(context)
                                            .text('deliver_to'),
                                        style: kAddressTextStyle,
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        children: <Widget>[
                                          AddressIcon(),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                            child: Text(
                                              FoodOrderModel()
                                                  .getDeliveryAddress()
                                                  .fullAddress,
                                              style: TextStyle(
                                                  fontFamily: poppinsRegular,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.0),
                                      (FoodOrderModel().getEstDuration() !=
                                                  null &&
                                              FoodOrderModel()
                                                      .getEstDuration() !=
                                                  '0')
                                          ? Text(
                                              '${AppTranslations.of(context).text('estimate_duration')}: ${FoodOrderModel().getEstDuration()} ${AppTranslations.of(context).text('minutes')}',
                                              style: TextStyle(
                                                  fontFamily: poppinsRegular,
                                                  fontSize: 13),
                                            )
                                          : Container(),
                                      // Container(
                                      //   margin: EdgeInsets.only(
                                      //     left: 20,
                                      //     right: 10,
                                      //   ),
                                      //   padding: EdgeInsets.symmetric(
                                      //       vertical: 10, horizontal: 10),
                                      //   decoration:
                                      //       BoxDecoration(color: lightGrey),
                                      //   child: Text(
                                      //     '${AppTranslations.of(context).text('remarks')}: -',
                                      //     style: TextStyle(color: Colors.grey),
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppTranslations.of(context)
                                                .text('order_summary'),
                                            style: kAddressTextStyle,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              AppTranslations.of(context)
                                                  .text('add_item'),
                                              style: TextStyle(
                                                fontFamily: poppinsMedium,
                                                fontSize: 15,
                                                color: kColorRed,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: (FoodOrderModel()
                                                    .getOrderCart()
                                                    .length >
                                                0)
                                            ? List.generate(
                                                FoodOrderModel()
                                                    .getOrderCart()
                                                    .length, (index) {
                                                FoodOrderCart order =
                                                    FoodOrderModel()
                                                        .getOrderCart()[index];

                                                return GestureDetector(
                                                  onTap: () {
                                                    _editOrder(order, index);
                                                  },
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                      bottom: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          width: 1,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    margin: EdgeInsets.only(
                                                        bottom: 10.0),
                                                    child: OrderFoodListWidget(
                                                      order: order,
                                                      editable: true,
                                                      orderOnDelete: () {
                                                        _deleteOrder(
                                                          order,
                                                          index,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              })
                                            : [Container()],
                                      ),
                                      SizedBox(height: 20.0),
                                      Container(
                                        child: Column(
                                          children: <Widget>[
                                            FoodPricingWidget(
                                              title: 'total_price',
                                              amount: FoodOrderModel()
                                                  .getFoodFinalPrice(),
                                            ),
                                            FoodPricingWidget(
                                              title: 'delivery_fee',
                                              amount: FoodOrderModel()
                                                  .getDeliveryFee(),
                                            ),
                                            (FoodOrderModel().getMinFee() !=
                                                    '0.00')
                                                ? FoodPricingWidget(
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              SmallFeeAlertDialog(
                                                                title: AppTranslations.of(
                                                                        context)
                                                                    .text(
                                                                        "small_order_fee"),
                                                                message: AppTranslations.of(
                                                                        context)
                                                                    .text(
                                                                        "small_order_fee_desc"),
                                                                buttonText: AppTranslations.of(
                                                                        context)
                                                                    .text(
                                                                        "proceed"),
                                                              ));
                                                    },
                                                    title: 'minimum_fee',
                                                    amount: FoodOrderModel()
                                                        .getMinFee(),
                                                  )
                                                : Container(),
                                            (FoodOrderModel().getPackingFee() !=
                                                    '0.00')
                                                ? FoodPricingWidget(
                                                    title: 'packing_fee',
                                                    amount: FoodOrderModel()
                                                        .getPackingFee(),
                                                  )
                                                : Container(),
                                            (FoodOrderModel().getPaymentFee() !=
                                                    '0.00')
                                                ? FoodPricingWidget(
                                                    title: 'payment_fee',
                                                    amount: FoodOrderModel()
                                                        .getPaymentFee(),
                                                  )
                                                : Container(),
                                            (FoodOrderModel()
                                                        .getOrderFoodSST() !=
                                                    '0.00')
                                                ? FoodPricingWidget(
                                                    title: 'sst',
                                                    amount: FoodOrderModel()
                                                        .getOrderFoodSST(),
                                                  )
                                                : Container(),
                                            (FoodOrderModel()
                                                        .getAutoDiscount() !=
                                                    '0.00')
                                                ? FoodPricingWidget(
                                                    title: AppTranslations.of(
                                                            context)
                                                        .text(
                                                            "special_promo_label"),
                                                    amount: FoodOrderModel()
                                                        .getAutoDiscount(),
                                                    isDiscount: true,
                                                  )
                                                : Container(),
                                            if (_validatedCoupon.length > 0)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 10.0),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        '${AppTranslations.of(context).text('promo_code')}: ' +
                                                            _validatedCoupon[
                                                                'couponName'],
                                                        style:
                                                            kDetailsTextStyle,
                                                      ),
                                                      SizedBox(width: 10.0),
                                                      Text(
                                                        '- RM ' +
                                                            _validatedCoupon[
                                                                'discountedPrice'],
                                                        style:
                                                            kDetailsTextStyle,
                                                      )
                                                    ],
                                                  ),
                                                  Text(
                                                    _validatedCoupon[
                                                        'couponDesc'],
                                                    style: TextStyle(
                                                        fontFamily:
                                                            poppinsItalic,
                                                        fontSize: 16),
                                                  ),
                                                  SizedBox(height: 10.0),
                                                ],
                                              ),
                                            FoodPricingWidget(
                                              title: 'final_price',
                                              amount: getFinalPrice(),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ), // Order Summary
                                SizedBox(height: 20.0),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  color: Colors.white,
                                  child: promoCodeWidget(),
                                ),
                                SizedBox(height: 20.0),
                                PaymentMethodSelectionBox(
                                  // paymentMethod: PaymentMethod()
                                  //     .getPaymentMethod(_selectedPaymentMethod),
                                  paymentMethod: _paymentMethods.firstWhere(
                                      (e) => e.name == _selectedPaymentMethod),
                                  isShowBalance: true,
                                  onPressed: () {
                                    _openPaymentMethodDialog();
                                  },
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  color: Colors.white,
                                  child: userInfo(),
                                ),
                                SizedBox(height: 80.0)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: marginBot, horizontal: 15.0),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 25,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      AppTranslations.of(context)
                                          .text('final_price'),
                                      style: kDetailsTextStyle,
                                    ),
                                    Text(
                                      '${AppTranslations.of(context).text('currency_my')} ' +
                                          getFinalPrice(),
                                      style: kTitleTextStyle,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0),
                              ActionButtonGreen(
                                buttonText: AppTranslations.of(context)
                                    .text('place_order'),
                                onPressed: () {
                                  _placeOrder();
                                },
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
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

  Widget userInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTranslations.of(context).text('remarks'),
          style: kAddressTextStyle,
        ),
        SizedBox(height: 10.0),
        RemarksTextBox(
          hintText: AppTranslations.of(context).text('write_your_remark_here'),
          onChanged: (value) {
            _remarksTFValue = value;
          },
        ),
        SizedBox(height: 10.0),
        Text(
          AppTranslations.of(context).text('name'),
          style: kAddressTextStyle,
        ),
        InputTextField(
          initText: _cartUserName,
          onChange: (value) {
            _cartUserName = value;
          },
        ),
        SizedBox(height: 10.0),
        Text(
          AppTranslations.of(context).text('email'),
          style: kAddressTextStyle,
        ),
        InputTextField(
          initText: _cartUserEmail,
          onChange: (value) {
            _cartUserEmail = value;
          },
        ),
        SizedBox(height: 10.0),
        Text(
          AppTranslations.of(context).text('phone'),
          style: kAddressTextStyle,
        ),
        InputTextField(
          initText: _cartUserPhone,
          onChange: (value) {
            _cartUserPhone = value;
          },
        ),
      ],
    );
  }

  Widget promoCodeWidget() {
    if (_validatedCoupon.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.of(context).text('promo_code'),
                style: kAddressTextStyle,
              ),
              GestureDetector(
                onTap: () async {
                  await _initCouponList();
                  var data = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VoucherListPage(
                        coupons: _coupons,
                      ),
                    ),
                  );
                  if (data != null) {
                    Coupon coupon = data;
                    setState(() {
                      _couponCodeTFValue = coupon.couponName;
                    });
                    validateCoupon();
                  }
                },
                child: Text(
                  '${_coupons.length} ${AppTranslations.of(context).text('available_voucher')}',
                  style: TextStyle(
                    fontFamily: poppinsSemiBold,
                    fontSize: 12,
                    color: kColorRed,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            height: 45.0,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.grey)),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _couponCodeTFValue,
                    style: TextStyle(fontFamily: poppinsItalic, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      _couponCodeTFValue = '';
                      _validatedCoupon = {};
                    });
                  },
                  color: kColorRed,
                  textColor: Colors.white,
                  child: Icon(Icons.clear),
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // *** Don't remove, it is for Voucher listing **
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.of(context).text('promo_code'),
                style: TextStyle(fontFamily: poppinsMedium, fontSize: 16),
              ),
              GestureDetector(
                onTap: () async {
                  await _initCouponList();
                  var data = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VoucherListPage(
                        coupons: _coupons,
                      ),
                    ),
                  );
                  if (data != null) {
                    Coupon coupon = data;
                    setState(() {
                      _couponCodeTFValue = coupon.couponName;
                    });
                    validateCoupon();
                  }
                },
                child: Text(
                  '${_coupons.length} ${AppTranslations.of(context).text('available_voucher')}',
                  style: TextStyle(
                    fontFamily: poppinsSemiBold,
                    fontSize: 12,
                    color: kColorRed,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Row(
            children: <Widget>[
              Expanded(
                child: InputTextField(
                  textAlign: TextAlign.center,
                  onChange: (value) {
                    _couponCodeTFValue = value;
                  },
                ),
              ),
              SizedBox(width: 10.0),
              MaterialButton(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0)),
                onPressed: () {
                  validateCoupon();
                },
                color: kColorRed,
                textColor: Colors.white,
                child: Text(
                  AppTranslations.of(context).text('validate'),
                  style: TextStyle(fontFamily: poppinsMedium, fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
