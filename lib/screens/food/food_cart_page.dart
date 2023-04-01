import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/components/labeled_checkbox.dart';
import 'package:haloapp/components/remarks_textbox.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/food_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/food_variant_model.dart';
import 'package:haloapp/models/shop_menu_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/food_history_networking.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/screens/food/food_order_success_page.dart';
import 'package:haloapp/screens/food/food_variant_details_popup.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/screens/general/custom_alert_dialog.dart';
import 'package:haloapp/screens/general/online_payment_page.dart';
import 'package:haloapp/screens/general/payment_method_selection_dialog.dart';
import 'package:haloapp/screens/history/food_history_details_page.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';

class FoodCartPage extends StatefulWidget {
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

  String _selectedPaymentMethod = FoodOrderModel().getPaymentMethod() ?? 'cod';
  String _selectedBookDate;
  String _selectedBookTime;
  Map _validatedCoupon = {};
  bool _forceSelectPaymentType = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FoodOrderModel().getMinFee() != '0.00')
        showDialog(
            context: context,
            builder: (context) => CustomAlertDialog(
                  title: 'Small order fee RM' + FoodOrderModel().getMinFee(),
                  message:
                      'A small order fee only applies to orders less than shop minimum order amount. Add more item to remove the fee',
                ));
    });
    super.initState();
    _initiateSelectedDateAndTime();
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

  void _placeOrder() {
    // if (_forceSelectPaymentType) {
    //   _openPaymentMethodDialog();
    //   _forceSelectPaymentType = false;
    //   return;
    // }

    showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
              title: AppTranslations.of(context)
                  .text('confirm_to_place_order_ques'),
              message: AppTranslations.of(context)
                      .text('are_you_sure_to_place_the_order_ques') +
                  ' at ' +
                  _selectedBookDate +
                  ' ' +
                  _selectedBookTime +
                  '?',
            )).then((value) {
      if (value != null && value == 'confirm') {
        _confirmOrder();
      }
    });
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

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => FoodOrderSuccessPage(),
    //   ),
    // ).then((value) {
    //   if (value != null && value == 'close') {
    //     Navigator.pop(
    //         context,
    //         PopWithResults(fromPage: 'foodCart', toPage: 'foodMain', results: {
    //           'clearBooking': true,
    //         }));
    //   }
    // });
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
    showDialog(
        context: context,
        builder: (context) =>
            PaymentMethodSelectionDialog(bookingType: 'food')).then((value) {
      if (value != null && value != '') {
        setState(() {
          _selectedPaymentMethod = value;
          FoodOrderModel().setPaymentMethod(value);
          createOrder();
        });
      }
    });
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
          title: Text(
            FoodOrderModel().getShopName() ?? '',
            style: kAppBarTextStyle.copyWith(fontSize: 15),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: SafeArea(
            bottom: false,
            child: (FoodOrderModel().getOrderCart().length == 0)
                ? Padding(
                    padding: EdgeInsets.all(35.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context)
                              .text('no_order_in_your_cart'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: poppinsSemiBold, fontSize: 20),
                        ),
                        SizedBox(height: 15.0),
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context, 'refresh');
                          },
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 30.0),
                          color: kColorRed,
                          child: Text(
                            AppTranslations.of(context)
                                .text('back_to_food_menu'),
                            style: TextStyle(
                                fontFamily: poppinsMedium,
                                fontSize: 16,
                                color: Colors.white),
                          ),
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
                            padding: EdgeInsets.only(top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        AppTranslations.of(context)
                                            .text('select_date_and_time'),
                                        style: kDetailsTextStyle,
                                      ),
                                      SizedBox(height: 10.0),
                                      dateAndTimeSelectionView()
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        AppTranslations.of(context)
                                            .text('deliver_to'),
                                        style: TextStyle(
                                            fontFamily: poppinsMedium,
                                            fontSize: 15),
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        children: <Widget>[
                                          Image.asset(
                                            'images/pin_red.png',
                                            height: 25,
                                          ),
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
                                          : Container()
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
                                      Text(
                                        AppTranslations.of(context)
                                            .text('order_summary'),
                                        style: TextStyle(
                                            fontFamily: poppinsMedium,
                                            fontSize: 15),
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
                                                    margin: EdgeInsets.only(
                                                        bottom: 10.0),
                                                    child: OrderFoodListWidget(
                                                      order: order,
                                                      editable: true,
                                                      orderOnDelete: () {
                                                        _deleteOrder(
                                                            order, index);
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
                                            if((FoodOrderModel().getShop()?.shopPartner == true))
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
                                                              CustomAlertDialog(
                                                                title:
                                                                    'Small order fee',
                                                                message:
                                                                    'A small order fee only applies to orders less than shop minimum order amount. Add more item to remove the fee',
                                                              ));
                                                    },
                                                    title: 'Minimum Fee',
                                                    amount: FoodOrderModel()
                                                        .getMinFee(),
                                                  )
                                                : Container(),
                                            (FoodOrderModel().getPackingFee() !=
                                                    '0.00')
                                                ? FoodPricingWidget(
                                                    title: 'Packing Fee',
                                                    amount: FoodOrderModel()
                                                        .getPackingFee(),
                                                  )
                                                : Container(),
                                            (FoodOrderModel().getPaymentFee() !=
                                                    '0.00')
                                                ? FoodPricingWidget(
                                                    title: 'Payment Fee',
                                                    amount: FoodOrderModel()
                                                        .getPaymentFee(),
                                                  )
                                                : Container(),
                                            (FoodOrderModel()
                                                        .getOrderFoodSST() !=
                                                    '0.00')
                                                ? FoodPricingWidget(
                                                    title: 'SST',
                                                    amount: FoodOrderModel()
                                                        .getOrderFoodSST(),
                                                  )
                                                : Container(),
                                            (FoodOrderModel()
                                                .getAutoDiscount() !=
                                                '0.00')
                                                ? FoodPricingWidget(
                                              title: AppTranslations.of(context).text("special_promo_label"),
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
                                              title: "${(FoodOrderModel().getShop()?.shopPartner == true)? "final_price" :"final_price_non_partner"}",
                                              amount:
                                                  (_validatedCoupon.length > 0)
                                                      ? _validatedCoupon[
                                                          'totalPrice']
                                                      : FoodOrderModel()
                                                          .getFinalPrice(),
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
                                    child: promoCodeWidget()),
                                SizedBox(height: 20.0),

//                      Container(
//                        padding: EdgeInsets.symmetric(
//                            horizontal: 15.0, vertical: 10.0),
//                        color: Colors.white,
//                        child: Column(
//                          crossAxisAlignment: CrossAxisAlignment.stretch,
//                          children: <Widget>[
//                            Text(
//                              AppTranslations.of(context)
//                                  .text('payment_method'),
//                              style: kDetailsTextStyle,
//                            ),
//                            SizedBox(height: 10.0),
//                            CheckboxWithContents(
//                              content: Text(
//                                  AppTranslations.of(context).text('cash')),
//                              padding: EdgeInsets.symmetric(),
//                              value: _payByCOD,
//                              onChanged: (value) {
//                                setState(() {
//                                  _payByCOD = !_payByCOD;
//                                });
//                              },
//                            ),
//                            CheckboxWithContents(
//                              content: Text(AppTranslations.of(context)
//                                  .text('online_payment')),
//                              padding: EdgeInsets.symmetric(),
//                              value: !_payByCOD,
//                              onChanged: (value) {
//                                setState(() {
//                                  _payByCOD = !_payByCOD;
//                                });
//                              },
//                            )
//                          ],
//                        ),
//                      ),
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
                                        children: [
                                          Text(
                                            AppTranslations.of(context)
                                                    .text('payment_method') +
                                                ' : ',
                                            style: TextStyle(
                                              fontFamily: poppinsMedium,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            AppTranslations.of(context)
                                                .text(_selectedPaymentMethod),
                                            style: TextStyle(
                                                fontFamily: poppinsMedium,
                                                fontSize: 16,
                                                color: kColorRed),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10.0),
                                      ActionButton(
                                          buttonText: 'Change Payment Method',
                                          onPressed: () {
                                            _openPaymentMethodDialog();
                                          }),

                                      // GestureDetector(
                                      //   onTap: () {
                                      //     _openPaymentMethodDialog();
                                      //   },
                                      //   behavior: HitTestBehavior.translucent,
                                      //   child: Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: <Widget>[
                                      //       Text(
                                      //         '${AppTranslations.of(context).text(_selectedPaymentMethod)}',
                                      //         style: TextStyle(
                                      //             fontFamily: poppinsMedium),
                                      //       ),
                                      //       Text(
                                      //         'change',
                                      //         style: kSmallLabelTextStyle
                                      //             .copyWith(color: kColorRed),
                                      //       )
                                      //     ],
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
                                      Text(
                                        AppTranslations.of(context)
                                            .text('remarks'),
                                        style: kDetailsTextStyle,
                                      ),
                                      SizedBox(height: 10.0),
                                      RemarksTextBox(
                                        hintText: AppTranslations.of(context)
                                            .text('write_your_remark_here'),
                                        onChanged: (value) {
                                          _remarksTFValue = value;
                                        },
                                      ),
                                      SizedBox(height: 10.0),
                                      Text(
                                        AppTranslations.of(context)
                                            .text('name'),
                                        style: kDetailsTextStyle,
                                      ),
                                      InputTextField(
                                        initText: _cartUserName,
                                        onChange: (value) {
                                          _cartUserName = value;
                                        },
                                      ),
                                      SizedBox(height: 10.0),
                                      Text(
                                        AppTranslations.of(context)
                                            .text('email'),
                                        style: kDetailsTextStyle,
                                      ),
                                      InputTextField(
                                        initText: _cartUserEmail,
                                        onChange: (value) {
                                          _cartUserEmail = value;
                                        },
                                      ),
                                      SizedBox(height: 10.0),
                                      Text(
                                        AppTranslations.of(context)
                                            .text('phone'),
                                        style: kDetailsTextStyle,
                                      ),
                                      InputTextField(
                                        initText: _cartUserPhone,
                                        onChange: (value) {
                                          _cartUserPhone = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 80.0)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
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
                                          ((_validatedCoupon.length > 0)
                                              ? _validatedCoupon['totalPrice']
                                              : FoodOrderModel()
                                                  .getFinalPrice()),
                                      style: kTitleTextStyle,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0),
                              ActionButton(
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

  Widget dateAndTimeSelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 80,
          child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> dateData =
                  FoodOrderModel().getAvailableDates()[index];
              String date = dateData.keys.first;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBookDate = date;
                  });
                  clearCoupon();
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: kColorRed, width: 1.0, style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color:
                        (_selectedBookDate == date) ? kColorRed : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      '${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM', datetime: '$date 00:00:00')}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: (_selectedBookDate == date)
                              ? poppinsSemiBold
                              : poppinsRegular,
                          fontSize: 16,
                          color: (_selectedBookDate == date)
                              ? Colors.white
                              : kColorRed),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(width: 10.0);
            },
            itemCount: FoodOrderModel().getAvailableDates().length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
          ),
        ),
        SizedBox(height: 20.0),
        Container(
          height: 200,
          child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              List<dynamic> times = getTimesForSelectedDate();

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBookTime = times[index];
                  });
                  clearCoupon();
                },
                child: Container(
                  height: 45.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: kColorRed, width: 1.0, style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: (_selectedBookTime == times[index])
                        ? kColorRed
                        : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      '${times[index]} - ${DatetimeFormatter().getStrTimeAfterMinute(time: times[index], interval: FoodOrderModel().getDeliveryInterval())}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: (_selectedBookTime == times[index])
                            ? poppinsSemiBold
                            : poppinsRegular,
                        fontSize: 16,
                        color: (_selectedBookTime == times[index])
                            ? Colors.white
                            : kColorRed,
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: 10.0);
            },
            itemCount: getTimesForSelectedDate().length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          ),
        ),
      ],
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

  Widget promoCodeWidget() {
    if (_validatedCoupon.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppTranslations.of(context).text('promo_code'),
            style: TextStyle(fontFamily: poppinsMedium, fontSize: 16),
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
                    clearCoupon();
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
          Text(
            AppTranslations.of(context).text('promo_code'),
            style: TextStyle(fontFamily: poppinsMedium, fontSize: 16),
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

  void clearCoupon(){
    setState(() {
      _couponCodeTFValue = '';
      _validatedCoupon = {};
    });
  }
}

class OrderFoodListWidget extends StatelessWidget {
  const OrderFoodListWidget({
    Key key,
    @required this.order,
    this.editable = false,
    this.orderOnDelete,
  }) : super(key: key);

  final FoodOrderCart order;
  final bool editable;
  final Function orderOnDelete;

  @override
  Widget build(BuildContext context) {
    Widget _buildOrderList(FoodOrderCart order) {
      List<Widget> list = [];

      list.add(Text(
        order.name,
        style: TextStyle(fontFamily: poppinsMedium, fontSize: 15),
        overflow: TextOverflow.ellipsis,
      ));

      if (order.options.length > 0) {
        for (FoodVariantItemModel item in order.options) {
          list.add(Text(
            item.name,
            style: kSmallLabelTextStyle,
          ));
        }
      }

      list.add(SizedBox(height: 8.0));

      if (editable ?? false) {
        list.add(Text(
          AppTranslations.of(context).text('edit'),
          style: kSmallLabelTextStyle.copyWith(color: kColorRed),
        ));
      }

//      double width = MediaQuery.of(context).size.width * 0.75;

      return Container(
//        width: width,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list,
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(1.0),
          child: Text('${order.quantity}x',
              style: kSmallLabelTextStyle.copyWith(
                  fontSize: 14, color: kColorRed)),
        ),
        SizedBox(width: 10.0),
        _buildOrderList(order),
        SizedBox(width: 10.0),
        Text(
          '${order.finalPrice}',
          style: TextStyle(fontFamily: poppinsMedium, fontSize: 15),
        ),
        SizedBox(width: 10.0),
        (editable)
            ? GestureDetector(
                onTap: orderOnDelete,
                child: Icon(
                  Icons.delete_forever,
                  color: kColorRed,
                ),
              )
            : Container()
      ],
    );
  }
}

class FoodPricingWidget extends StatelessWidget {
  const FoodPricingWidget({
    @required this.title,
    @required this.amount,
    this.onPressed,
    this.isDiscount = false,
    Key key,
  }) : super(key: key);

  final String title;
  final String amount;
  final bool isDiscount;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                AppTranslations.of(context).text(title),
                style: TextStyle(fontFamily: poppinsRegular, fontSize: 14),
              ),
              if (onPressed != null)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Icon(
                    Icons.info_outline,
                    size: 15,
                  ),
                )
            ],
          ),
          Text(
            '${(isDiscount) ? '-' : ''}RM $amount',
            style: TextStyle(fontFamily: poppinsMedium, fontSize: 15),
          )
        ],
      ),
    );
  }
}
