import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';

import 'package:haloapp/models/banner_model.dart';
import 'package:haloapp/models/coupon_model.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/food_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/order_for_later_model.dart';
import 'package:haloapp/models/shop_menu_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/models/top_up_method_model.dart';
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
import 'package:haloapp/screens/main/ramadan/charity_success_page.dart';
import 'package:haloapp/screens/main/ramadan/order_response_model.dart';
import 'package:haloapp/screens/main/ramadan/payment_method_selection_box.dart';
import 'package:haloapp/screens/main/ramadan/payment_method_selection_dialog.dart';
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

class RamadanPayment extends StatefulWidget {
  String shopType;
  FoodModel food;
  String price;
  String orderUniqueKey;
  List<PaymentMethodWithIcon> pMethods;
  RamadanPayment(
      {this.shop,
      this.shopType,
      this.orderUniqueKey,
      this.price,
      this.food,
      this.pMethods});
  final ShopModel shop;

  @override
  _RamadanPaymentState createState() => _RamadanPaymentState();
}

class _RamadanPaymentState extends State<RamadanPayment> {
  bool _showSpinner = false;
  String _validatedCouponCode = '';
  String _couponCodeTFValue;
  String _remarksTFValue;
  TextEditingController remarksController = TextEditingController();
  String _cartUserName = User().getUsername();
  String _cartUserEmail = User().getUserEmail();
  String _cartUserPhone = User().getUserPhone();

  String _selectedPaymentMethod = "";
  String _selectedBookDate = '';
  String _selectedPaymentCode = '';

  String _selectedBookTime = '';
  Map _validatedCoupon = {};
  bool _forceSelectPaymentType = true;
  List<Coupon> _coupons = [];
  BannerModel _bannerModel = BannerModel();
  List<PaymentMethodWithIcon> _paymentMethods = [];
  int selectedPaymentMethod = 0;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.pMethods.first.methodDisplayName;
    _paymentMethods = widget.pMethods;
    // _initPaymentMethods();
    // _initWalletBalance();
    _initWalletBalance();

    // _paymentMethods.addAll(AppConfig.paymentMethods);
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

  bool isInSufficientBalance() {
    return User().walletTransactionsResponse != null &&
        double.parse(User()
                .walletTransactionsResponse
                .response
                .walletBalance
                .replaceAll(",", "")) <
            double.parse(getFinalPrice());
  }

  /// Check whether applied coupon or not
  String getFinalPrice() {
    return widget.price;
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

      double requiredAmount = double.parse(widget.price) -
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

    _confirmOrder();
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
        "orderUniqueKey": widget.orderUniqueKey,
        "remark": remarksController.text ?? '',
        "paymentMethod": _selectedPaymentCode,
        "userPhone": _cartUserPhone,
        "userEmail": _cartUserEmail,
        "userName": _cartUserName,
        "preDate": "",
        "preTime": "",
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
        print("7777 ${data}");
        if (data['paymentUrl'].isEmpty) {
          _showSuccessOrderPopup();
        } else {
          proceedToOnlinePayment(data['paymentUrl']);
        }
      } else {
        _showSuccessOrderPopup();
      }
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e.toString(), context);
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
      "data": {"orderUniqueKey": widget.orderUniqueKey}
    });
    FoodOrderModel().clearFoodOrderData();
    Navigator.popUntil(context, ModalRoute.withName(TabBarPage.id));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CharitySucessPage(success: true, history: fhm)));
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
      builder: (context) => DonationPaymentMethodSelectionDialog(
        pMethods: _paymentMethods,
        bookingType: 'donation',
        selectedMethod: _selectedPaymentMethod,
        onChanged: (value) {
          _selectedPaymentMethod = value;
          print(_selectedPaymentMethod);
          widget.pMethods.forEach(
            (element) {
              if (element.methodDisplayName == _selectedPaymentMethod) {
                print(element.methodName);
                _selectedPaymentCode = element.methodName;
              }
            },
          );
          setState(() {});
          // FoodOrderModel().setPaymentMethod(value);
          // createOrder();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.pMethods[1].methodName);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: arrowBack,
            onPressed: () => {Navigator.pop(context)},
          ),
          title: Text(
            AppTranslations.of(context).text('Review Donation'),
            style: kAppBarTextStyle,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  DonationPaymentMethodSelectionBox(
                    // paymentMethod: PaymentMethod()
                    //     .getPaymentMethod(_selectedPaymentMethod),
                    paymentMethod: _paymentMethods.firstWhere(
                        (e) => e.methodDisplayName == _selectedPaymentMethod),
                    isShowBalance: true,
                    onPressed: () {
                      _openPaymentMethodDialog();
                    },
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(AppTranslations.of(context).text('Remarks'),
                                  style: kAddressTextStyle),
                            ],
                          ),
                          SizedBox(height: 10),
                          InputTextFormField(
                            controller: remarksController,
                          ),
                        ],
                      )),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(vertical: marginBot, horizontal: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            AppTranslations.of(context).text('Donation Amount'),
                            style: kDetailsTextStyle,
                          ),
                          Text(
                            '${AppTranslations.of(context).text('currency_my')} ' +
                                widget.price,
                            style: kTitleTextStyle,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ActionButton(
                      buttonText: AppTranslations.of(context).text('Book'),
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
}
