import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components_new/address_detail.dart';
import 'package:haloapp/components_new/driver_card.dart';
import 'package:haloapp/components_new/order_food_widget.dart';
import 'package:haloapp/components_new/order_progress_indicator.dart';
import 'package:haloapp/components_new/payment_method_selection_dialog.dart';
import 'package:haloapp/components_new/repay_method_selection_dialog.dart';
import 'package:haloapp/models/activity_model.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/food_rider_tacking.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/networkings/history_networking.dart';
import 'package:haloapp/screens/boarding/login_page.dart';
import 'package:haloapp/screens/history/delivery_cancel_booking_dialog.dart';
import 'package:haloapp/screens/main/activity_support_details_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/job_status.dart';
import 'package:haloapp/utils/constants/payment_method.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:huawei_map/map.dart' as huaweiMap;

class FoodHistoryDetailsPage extends StatefulWidget {
  FoodHistoryDetailsPage({@required this.history, this.success = false});

  final FoodHistoryModel history;
  final bool success;

  @override
  _FoodHistoryDetailsPageState createState() => _FoodHistoryDetailsPageState();
}

class _FoodHistoryDetailsPageState extends State<FoodHistoryDetailsPage>
    with TickerProviderStateMixin {
  // BitmapDescriptor pickupIcon;
  // BitmapDescriptor dropoffIcon;
  // BitmapDescriptor motorIcon;
  // LatLng customerCoordinates;
  // LatLng merchantCoordinates;

  //Huawei Map
  huaweiMap.BitmapDescriptor huaweiMapPickupIcon;
  huaweiMap.BitmapDescriptor huaweiMapDropoffIcon;
  huaweiMap.BitmapDescriptor huaweiMotorIcon;
  huaweiMap.LatLng huaweiMapCustomerCoordinates;
  huaweiMap.LatLng huaweiMapMerchantCoordinates;

  bool _showMap = false;
  bool isRiderTrackingAvailable = false;
  Duration riderTrackingInterval = const Duration(seconds: 5);
  FoodRiderTracking riderTracking = FoodRiderTracking();
  Timer _timer;
  final _controller = ScrollController();
  AnimationController _animController;
  List<AddressModel> _addresses = [];
  TextEditingController _bankName = TextEditingController();
  TextEditingController _bankNum = TextEditingController();
  TextEditingController _bankAccountName = TextEditingController();

  @override
  void initState() {
    _animController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat(reverse: true);

    // customerCoordinates = LatLng(double.parse(widget.history.shopLat),
    //     double.parse(widget.history.shopLng));
    //
    // merchantCoordinates = LatLng(double.parse(widget.history.customerLat),
    //     double.parse(widget.history.customerLng));

    huaweiMapCustomerCoordinates = huaweiMap.LatLng(
        double.parse(widget.history.shopLat),
        double.parse(widget.history.shopLng));

    huaweiMapMerchantCoordinates = huaweiMap.LatLng(
        double.parse(widget.history.customerLat),
        double.parse(widget.history.customerLng));

    _addresses.add(AddressModel(
      receiverName: widget.history.shopName,
      receiverPhone: widget.history.shopPhone,
      fullAddress: widget.history.shopFullAddress,
    ));

    _addresses.add(AddressModel(
      receiverName: widget.history.userName,
      receiverPhone: widget.history.userPhone,
      fullAddress: widget.history.orderDeliveryAddress,
    ));

    initRiderTracking();
    setupIcons();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void refundApiCall() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {
        "bookingUniqueKey": widget.history.orderUniqueKey,
        "refundType": 'bankTransfer',
        "refundBankName": _bankName.text,
        "refundBankAccountNo": _bankNum.text,
        "refundBankAccountName": _bankAccountName.text
      },
    };

    try {
      var data = await HistoryNetworking().getBookingRefund(params);
      showSimpleFlushBar(data, context, isError: false);
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {}
  }

  void showCancelBookingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DeliveryCancelBookingDialog(
              bookingUniqueKey: widget.history.orderUniqueKey,
            )).then((value) {
      if (value != null) {
        if (value is PopWithResults) {
          PopWithResults popResult = value;

          if (popResult.toPage == 'login') {
            SharedPrefService().removeLoginInfo();
            Navigator.popUntil(context, ModalRoute.withName(LoginPage.id));
          }
        } else {
          showSimpleFlushBar(value, context, isError: false);
        }
      }
    });
  }

  void showRefundConfirmationDialog(
    BuildContext context,
    Function() callBack,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Text(
                      'Refund order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: poppinsSemiBold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Please enter your refund details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: poppinsRegular,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _bankName,
                decoration: InputDecoration(hintText: 'Bank name'),
                keyboardType: TextInputType.text,
                style: TextStyle(),
              ),
              TextField(
                controller: _bankNum,
                decoration: InputDecoration(hintText: 'Bank account number'),
                keyboardType: TextInputType.number,
                style: TextStyle(),
              ),
              TextField(
                controller: _bankAccountName,
                decoration: InputDecoration(hintText: 'Bank account name'),
                keyboardType: TextInputType.text,
                style: TextStyle(),
              ),
              SizedBox(
                height: 32,
              ),
              Row(
                children: [
                  Container(
                    child: ActionButton(
                      onPressed: () {
                        if (_bankAccountName.text == '') {
                          return showSimpleFlushBar(
                              'Please enter bank account name', context);
                        }

                        if (_bankNum.text == '') {
                          return showSimpleFlushBar(
                              'Please enter bank number', context);
                        }

                        if (_bankName.text == '') {
                          return showSimpleFlushBar(
                              'Please enter bank name', context);
                        }
                        callBack();
                        Navigator.pop(context);
                      },
                      buttonText: 'SUBMIT',
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: ActionButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      buttonText: 'CANCEL',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _openPaymentMethodDialog() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (context) => RepayMethodSelectionDialog(
        orderUniqueKey: widget.history.orderUniqueKey,
        bookingType: 'food',
      ),
    );
  }

  void initRiderTracking() {
    trackRider();
    _timer = Timer.periodic(riderTrackingInterval, (Timer t) {
      trackRider();
    });
  }

  void trackRider() async {
    var _riderTracking = await FoodNetworking.getFoodRiderTracking(
        widget.history.orderUniqueKey);
    print('### RIP');

    widget.history.orderStatus = _riderTracking.orderStatus;
    setState(() {
      // isRiderTrackingAvailable = _riderTracking.isJobCompleted;
      riderTracking = _riderTracking;
    });
    if (_riderTracking.isJobCompleted) _timer.cancel();
    print(riderTracking.toJson());
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future<Uint8List> getBytesFromNetwork(String url, int width) async {
    Uint8List icon = (await NetworkAssetBundle(Uri.parse(url)).load(url))
        .buffer
        .asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(icon, targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void setupIcons() async {
    final Uint8List pickupIconRaw =
        await getBytesFromNetwork(widget.history.shopLogoUrl, 120);

    final Uint8List motorIconRaw =
        await getBytesFromAsset('images/motorcycle.png', 100);
    // final Uint8List pickupIconRaw =
    //     await getBytesFromAsset('images/pin_blue.png', 100);
    final Uint8List dropoffIconRaw =
        await getBytesFromAsset('images/pin_red.png', 100);

    // motorIcon = BitmapDescriptor.fromBytes(motorIconRaw);
    // pickupIcon = BitmapDescriptor.fromBytes(pickupIconRaw);
    // dropoffIcon = BitmapDescriptor.fromBytes(dropoffIconRaw);

    huaweiMotorIcon = huaweiMap.BitmapDescriptor.fromBytes(motorIconRaw);
    huaweiMapPickupIcon = huaweiMap.BitmapDescriptor.fromBytes(pickupIconRaw);
    huaweiMapDropoffIcon = huaweiMap.BitmapDescriptor.fromBytes(dropoffIconRaw);

    setState(() {
      _showMap = true;
    });
  }

  switchRenderTop(String status) {
    switch (status) {
      case JobStatus.otwPickedUp:
      case JobStatus.otw:
        return _showMap ? getMap() : SizedBox.shrink();
      case JobStatus.pending:
      default:
        return Image.asset(
          'images/ic_preparing.png',
          width: MediaQuery.of(context).size.width,
          height: 200,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.history.orderUniqueKey);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: arrowBack,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: (!widget.success)
            ? Text(
                widget.history.orderNum,
                style: kAppBarTextStyle,
              )
            : Text(
                AppTranslations.of(context).text('your_order'),
                style: kAppBarTextStyle,
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _controller,
          child: Container(
            color: Colors.grey[100],
            // height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (!riderTracking.isJobCompleted)
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          child: switchRenderTop(riderTracking.orderStatus),
                        ),
                        OrderProgressIndicator(
                            status: riderTracking.orderStatus),
                        Divider(),
                        if (riderTracking.orderStatus != JobStatus.pending &&
                            riderTracking.orderStatus != JobStatus.delivered)
                          DriverCard(
                            driverName: riderTracking.riderName,
                            driverPhoneNumber: riderTracking.riderPhone,
                          )
                      ],
                    ),
                  ),
                if (!riderTracking.isJobCompleted) SizedBox(height: 20),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppTranslations.of(context)
                                .text("delivery_details"),
                            style: TextStyle(fontFamily: poppinsSemiBold),
                          ),
                          Text(
                            // '${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM yyyy hh:mm a', datetime: widget.history.orderPickupDatetime)}',
                            '${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM yyyy', datetime: widget.history.orderPickupDatetime)}  ${DatetimeFormatter().getFormattedDisplayTime(widget.history.orderPickupDatetime)} - ${DatetimeFormatter().getFormattedDisplayTime(DateTime.parse(widget.history.orderPickupDatetime).add(Duration(minutes: widget.history.shopDeliveryInterval)).toString())}',
                            style: TextStyle(
                              fontFamily: poppinsRegular,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      AddressDetail(addresses: _addresses),
                      SizedBox(height: 4),
                      Text(
                        '${AppTranslations.of(context).text('remarks')}: ${(widget.history.orderRemarks == null || widget.history.orderRemarks.isEmpty) ? "-" : widget.history.orderRemarks}',
                        style: kSmallLabelTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.history.orderStatus == 'new' ||
                          widget.history.orderStatus == 'pending' ||
                          widget.history.orderStatus == "newPendingAccept")
                        Visibility(
                          visible: riderTracking.cancelStatus,
                          child: MaterialButton(
                            onPressed: () {
                              showCancelBookingDialog();
                            },
                            color: kColorRed,
                            textColor: Colors.white,
                            child: Text(
                              AppTranslations.of(context)
                                  .text('cancel_booking'),
                              style: TextStyle(
                                  fontFamily: poppinsMedium, fontSize: 15),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppTranslations.of(context).text('order_summary'),
                            style: TextStyle(fontFamily: poppinsSemiBold),
                          ),
                          Text(
                            '#${widget.history.orderNum}',
                            style: TextStyle(
                              fontFamily: poppinsRegular,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: kColorRed.withOpacity(.1)),
                        child: Text(
                          AppTranslations.of(context)
                              .text('order_' + widget.history.orderStatus),
                          style: kSmallLabelTextStyle.copyWith(
                              color: kColorRed, fontFamily: poppinsMedium),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          ListView.separated(
                            itemCount: widget.history.orderItems.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              FoodOrderCart order =
                                  widget.history.orderItems[index];
                              return Container(
                                child: OrderFoodListWidget(order: order),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider();
                            },
                          ),
                          Divider(),
                          SizedBox(height: 10),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FoodPricingWidget(
                                  title: 'delivery_fee',
                                  amount:
                                      widget.history.orderDeliveryFee ?? '0.00',
                                ),
                                (widget.history.orderPriceDiscount != '0' &&
                                        widget.history.orderPriceDiscount !=
                                            '0.00')
                                    ? FoodPricingWidget(
                                        title: 'discounted_price',
                                        amount:
                                            widget.history.orderPriceDiscount ??
                                                '0.00',
                                        isDiscount: true,
                                      )
                                    : Container(),
                                (widget.history.orderAutoDiscount != '0' &&
                                        widget.history.orderAutoDiscount !=
                                            '0.00')
                                    ? FoodPricingWidget(
                                        title: 'special_promo_label',
                                        amount:
                                            widget.history.orderAutoDiscount ??
                                                '0.00',
                                        isDiscount: true,
                                      )
                                    : Container(),
                                (widget.history.minimumCharges != '0' &&
                                        widget.history.minimumCharges != '0.00')
                                    ? FoodPricingWidget(
                                        title: 'minimum_fee',
                                        amount: widget.history.minimumCharges ??
                                            '0.00',
                                      )
                                    : Container(),
                                (widget.history.orderPackingFee != '0' &&
                                        widget.history.orderPackingFee !=
                                            '0.00')
                                    ? FoodPricingWidget(
                                        title: 'packing_fee',
                                        amount:
                                            widget.history.orderPackingFee ??
                                                '0.00',
                                      )
                                    : Container(),
                                (widget.history.paymentCharges != '0' &&
                                        widget.history.paymentCharges != '0.00')
                                    ? FoodPricingWidget(
                                        title: 'payment_fee',
                                        amount: widget.history.paymentCharges ??
                                            '0.00',
                                      )
                                    : Container(),
                                (widget.history.orderFoodSST != '0' &&
                                        widget.history.orderFoodSST != '0.00')
                                    ? FoodPricingWidget(
                                        title: 'sst',
                                        amount: widget.history.orderFoodSST ??
                                            '0.00',
                                      )
                                    : Container(),
                                if (widget.history.paymentMethod ==
                                    "haloWalletCod")
                                  FoodPricingWidget(
                                    title: 'haloWallet',
                                    amount:
                                        widget.history.orderHaloWalletAmount ??
                                            '0.00',
                                  ),
                                if (widget.history.paymentMethod ==
                                    "haloWalletCod")
                                  FoodPricingWidget(
                                    title: 'cod',
                                    amount:
                                        widget.history.orderCodAmount ?? '0.00',
                                  ),
                                FoodPricingWidget(
                                  title: 'total_price',
                                  amount: widget.history.orderPrice ?? '0.00',
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Image.asset(
                                      PaymentMethod()
                                          .getPaymentMethod(
                                            widget.history.paymentMethod,
                                          )
                                          .image,
                                      width: 36,
                                      height: 36,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      AppTranslations.of(context)
                                          .text(widget.history.paymentMethod),
                                      style: kDetailsTextStyle,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${AppTranslations.of(context).text('currency_my')} ${widget.history.orderPrice}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontFamily: poppinsMedium,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                (widget.history.customerPayRiderCash != '0' &&
                                        widget.history.customerPayRiderCash !=
                                            '0.00')
                                    ? FoodPricingWidget(
                                        title: 'customer_pay_rider',
                                        amount: widget
                                                .history.customerPayRiderCash ??
                                            '0.00',
                                      )
                                    : Container(),
                                (widget.history.orderMerchantRemark != '')
                                    ? Text(
                                        AppTranslations.of(context).text(
                                            'merchant_remark' +
                                                ': ' +
                                                widget.history
                                                    .orderMerchantRemark),
                                        textAlign: TextAlign.start,
                                        style: kSmallLabelTextStyle,
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                          visible:
                              widget.history.showRefundDetailStatus == 'true'
                                  ? true
                                  : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(),
                              Text(
                                AppTranslations.of(context)
                                    .text('refund_summary'),
                                style: TextStyle(fontFamily: poppinsSemiBold),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTranslations.of(context)
                                        .text('refund_status'),
                                    style: TextStyle(
                                        fontFamily: poppinsRegular,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    AppTranslations.of(context).text(
                                        "refund_${widget.history.bookingRefundStatus}"),
                                    style: TextStyle(
                                        fontFamily: poppinsMedium,
                                        fontSize: 15),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTranslations.of(context)
                                        .text('refund_remark'),
                                    style: TextStyle(
                                        fontFamily: poppinsRegular,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    widget.history.bookingRefundRemark,
                                    style: TextStyle(
                                        fontFamily: poppinsMedium,
                                        fontSize: 15),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTranslations.of(context)
                                        .text('refund_create_datetime'),
                                    style: TextStyle(
                                        fontFamily: poppinsRegular,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    widget.history
                                                .bookingRefundCreatedDatetime ==
                                            ''
                                        ? ''
                                        : DatetimeFormatter()
                                            .getFormattedDisplayDateTime(widget
                                                .history
                                                .bookingRefundCreatedDatetime),
                                    style: TextStyle(
                                        fontFamily: poppinsMedium,
                                        fontSize: 15),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTranslations.of(context)
                                        .text('refund_update_datetime'),
                                    style: TextStyle(
                                        fontFamily: poppinsRegular,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    widget.history
                                                .bookingRefundUpdateDatetime ==
                                            ''
                                        ? ''
                                        : DatetimeFormatter()
                                            .getFormattedDisplayDateTime(widget
                                                .history
                                                .bookingRefundUpdateDatetime),
                                    style: TextStyle(
                                        fontFamily: poppinsMedium,
                                        fontSize: 15),
                                  )
                                ],
                              ),
                              // Visibility(
                              //   visible:
                              //       widget.history.bookingRefundReceiptUrl == ''
                              //           ? false
                              //           : true,
                              //   child: Container(
                              //     width: double.infinity,
                              //     child: FlatButton(
                              //       onPressed: () {
                              //         showDialog(
                              //           context: context,
                              //           builder: (_) => Dialog(
                              //             child: Container(
                              //               width: 200,
                              //               height: 200,
                              //               child: Image.network(widget.history
                              //                   .bookingRefundReceiptUrl),
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //       color: kColorRed,
                              //       textColor: Colors.white,
                              //       child: Text(
                              //         AppTranslations.of(context)
                              //                 .text('refund') +
                              //             ' ' +
                              //             AppTranslations.of(context)
                              //                 .text('image'),
                              //         style: TextStyle(
                              //             fontFamily: poppinsMedium,
                              //             fontSize: 15),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              Divider(),
                            ],
                          )),
                      Container(
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () {
                            BookingDetail bookingDetail = new BookingDetail();
                            List<BookingAddress> bookingAddressList = [];
                            BookingAddress bookingAddress =
                                new BookingAddress();
                            bookingAddress.recipientName =
                                widget.history.shopName;
                            bookingAddressList.add(bookingAddress);
                            bookingDetail.bookingNumber =
                                widget.history.orderNum;
                            bookingDetail.orderStatus =
                                widget.history.orderStatus;
                            bookingDetail.totalPrice =
                                widget.history.orderPrice;
                            bookingDetail.bookingAddress = bookingAddressList;
                            bookingDetail.itemType = 'Food';
                            bookingDetail.bookingDate =
                                widget.history.orderPickupDatetime;
                            Navigator.pushNamed(
                                context, ActivitySupportDetailsPage.id,
                                arguments: bookingDetail);
                          },
                          color: kColorRed,
                          textColor: Colors.white,
                          child: Text(
                            AppTranslations.of(context).text('contact_us'),
                            style: TextStyle(
                                fontFamily: poppinsMedium, fontSize: 15),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.history.refundAvailableStatus == 'true'
                            ? true
                            : false,
                        child: Container(
                          width: double.infinity,
                          child: MaterialButton(
                            onPressed: () {
                              showRefundConfirmationDialog(
                                  context, refundApiCall);
                            },
                            color: kColorRed,
                            textColor: Colors.white,
                            child: Text(
                              AppTranslations.of(context).text('refund'),
                              style: TextStyle(
                                  fontFamily: poppinsMedium, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.history.payAgainStatus == 'true'
                            ? true
                            : false,
                        child: Container(
                          width: double.infinity,
                          child: MaterialButton(
                            onPressed: () {
                              _openPaymentMethodDialog();
                            },
                            color: kColorRed,
                            textColor: Colors.white,
                            child: Text(
                              AppTranslations.of(context).text('pay_again'),
                              style: TextStyle(
                                  fontFamily: poppinsMedium, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
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

  Widget getMap() {
    return huaweiMap.HuaweiMap(
      onMapCreated: (huaweiMap.HuaweiMapController controller) {
        final huaweiMap.LatLng southwest = huaweiMap.LatLng(
          min(huaweiMapMerchantCoordinates.lat,
              huaweiMapCustomerCoordinates.lat),
          min(huaweiMapMerchantCoordinates.lng,
              huaweiMapCustomerCoordinates.lng),
        );

        final huaweiMap.LatLng northeast = huaweiMap.LatLng(
          max(huaweiMapMerchantCoordinates.lat,
              huaweiMapCustomerCoordinates.lat),
          max(huaweiMapMerchantCoordinates.lng,
              huaweiMapCustomerCoordinates.lng),
        );

        huaweiMap.LatLngBounds bounds = huaweiMap.LatLngBounds(
          southwest: southwest,
          northeast: northeast,
        );

        // huaweiMap.LatLngBounds bound = huaweiMap.LatLngBounds(
        //     southwest: huaweiMapMerchantCoordinates,
        //     northeast: huaweiMapCustomerCoordinates
        // );
        huaweiMap.CameraUpdate u2 =
            huaweiMap.CameraUpdate.newLatLngBounds(bounds, 70);
        controller.animateCamera(u2);
      },
      gestureRecognizers: Set()
        ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
        ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
        ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
        ..add(Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer())),
      zoomControlsEnabled: false,
      initialCameraPosition: huaweiMap.CameraPosition(
        target: huaweiMapCustomerCoordinates,
        zoom: 15,
      ),
      markers: [
        if (riderTracking.lat != null)
          huaweiMap.Marker(
              icon: huaweiMotorIcon,
              markerId: huaweiMap.MarkerId('0'),
              position: huaweiMap.LatLng(riderTracking.lat, riderTracking.lng)),
        huaweiMap.Marker(
            // icon: dropoffIcon,
            markerId: huaweiMap.MarkerId('1'),
            infoWindow: huaweiMap.InfoWindow(
                title: 'Customer Address',
                snippet: widget.history.orderDeliveryAddress),
            position: huaweiMapMerchantCoordinates),
        huaweiMap.Marker(
            icon: huaweiMapPickupIcon,
            markerId: huaweiMap.MarkerId('2'),
            infoWindow: huaweiMap.InfoWindow(
                title: 'Shop Address', snippet: widget.history.shopFullAddress),
            position: huaweiMapCustomerCoordinates),
      ].toSet(),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
    );

    // return GoogleMap(
    //   onMapCreated: (GoogleMapController controller) {
    //     LatLngBounds bound = LatLngBounds(
    //         southwest: merchantCoordinates, northeast: customerCoordinates);
    //     CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 100);
    //     controller.animateCamera(u2);
    //   },
    //   gestureRecognizers: Set()
    //     ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
    //     ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
    //     ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
    //     ..add(Factory<VerticalDragGestureRecognizer>(
    //         () => VerticalDragGestureRecognizer())),
    //   zoomControlsEnabled: false,
    //   initialCameraPosition: CameraPosition(
    //     target: customerCoordinates,
    //     zoom: 15,
    //   ),
    //   markers: [
    //     if (riderTracking.lat != null)
    //       Marker(
    //           icon: motorIcon,
    //           markerId: MarkerId('0'),
    //           position: LatLng(riderTracking.lat, riderTracking.lng)),
    //     Marker(
    //         // icon: dropoffIcon,
    //         markerId: MarkerId('1'),
    //         infoWindow: InfoWindow(
    //             title: 'Customer Address',
    //             snippet: widget.history.orderDeliveryAddress),
    //         position: merchantCoordinates),
    //     Marker(
    //         icon: pickupIcon,
    //         markerId: MarkerId('2'),
    //         infoWindow: InfoWindow(
    //             title: 'Shop Address', snippet: widget.history.shopFullAddress),
    //         position: customerCoordinates),
    //   ].toSet(),
    //   myLocationEnabled: false,
    //   myLocationButtonEnabled: false,
    // );
  }
}
